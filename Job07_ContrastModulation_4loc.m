function [a_cen, a_sur, b_cen, b_sur] = Job07_ContrastModulation_4loc(myseed, n, whichPop, typeStim, withlong)
% This routine executes the function ContrastModulation_4loc, which 
% computes the response of unit n in the network to a center stimulus of 
% varying contrast (sinusoidal grating with ori, sp. freq and size set as 
% the cell's preferred ones) in two conditions 
% - no surround
% - surround = concentric sinusoidal grating at high contrast (with the 
% same spatial frequency and orientation as the center)
% 
% INPUT
% myseed    [integer] seed for random number generator; should match the seed selected to learn the connectivity (PHI/C)
% n         [integer] index of the recorded cell
% whichPop  [string] {'a', 'b'}
% typeStim  [integer] index that selects the type of stimulus
%           1: surround = collinear flanks
%           2: surround = orthogonal flanks
% whitlong  [flag variable] 
%           1 implements the model with long-range interactions, 0 without
% 
% USAGE EXAMPLE
% myseed = 4; n = 1; whichPop = 'a'; typeStim = 1; withlong = 1;
% [a_cen,a_sur,b_cen,b_sur]=Job07_ContrastModulation_4loc(myseed,n,whichPop,typeStim,withlong);

%%% Create folder where to store results
CurrentFolder = pwd;
D_C_path = strcat(CurrentFolder, '/dict_and_corr/');
IntermediateFolder = 'contextual_modulation_4locations';
ResFolder = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/Paradigm_3/');

if typeStim==2
    ResFolder = strcat(ResFolder, 'Ortho/');
end
if 7~=exist(ResFolder, 'dir')
    fprintf('Creating folder %s\n', ResFolder)
    mkdir(ResFolder)
end
switch whichPop
    case 'a'
        FileNameAux = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/opt_param_small_radius_long_drifting_A.mat');
        ResFile = sprintf('pop_a_n_%04.0f', n);
    case 'b'
        FileNameAux = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/opt_param_small_radius_long_drifting_B.mat');
        ResFile = sprintf('pop_b_n_%04.0f', n);
end
if withlong
    ResFileComplete = strcat(ResFolder, ResFile, '.mat');
    fprintf('WITH long-range\n')
else
    ResFileComplete = strcat(ResFolder, ResFile, '_nolong.mat');
    fprintf('WITHOUT long-range\n')
end

%%% Add library
addpath(strcat(CurrentFolder, '/lib_context/'));

%%% Load dictionary and long-range interaction matrix
load(strcat(D_C_path, 'D', num2str(myseed), '.mat'), 'D');
load(strcat(D_C_path, 'C', num2str(myseed), '.mat'), 'C');
load(strcat(D_C_path, 'V', num2str(myseed), '.mat'), 'V');
if ~withlong
    C = zeros(size(C)); %#ok<NODEF>
    V = zeros(size(V)); %#ok<NODEF>
end
load(FileNameAux, 'index_sel', 's_max', 'r_max', 'o_max');

%%% Execute experiment
if ismember(n, index_sel)
    if exist(ResFileComplete, 'file')==2
        fprintf('You already have results for seed %d, cell %d!\n', myseed, n)
        a_cen = [];
        b_cen = [];
        a_sur = [];
        b_sur = [];
    else
        fprintf('Running simulation for seed %d, cell %d\n', myseed, n)
        o = o_max(n);
        s = s_max(n);
        r = r_max(n);
        [a_cen, a_sur, b_cen, b_sur] = ContrastModulation_4loc(D, C, V, n, o, s, r, typeStim);
        %%% Save results
        fprintf('Saving resuluts...\n')
        save(ResFileComplete, 'a_cen', 'a_sur', 'b_cen', 'b_sur')
        fprintf('...%s saved!\n', ResFileComplete)
    end
else
    a_cen = [];
    b_cen = [];
    a_sur = [];
    b_sur = [];
    fprintf('Cell %d (seed %d) is not responsive nor tuned, it will not be tested with paradigm 3\n', n, myseed)
end
