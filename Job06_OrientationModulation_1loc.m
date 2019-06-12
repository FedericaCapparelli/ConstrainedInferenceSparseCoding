function [an, bn] = Job06_OrientationModulation_1loc(myseed, n, whichPop, withlong)
% This routine executes the function OrientationModulation_1loc, which 
% computes the response of unit n in the network to a compound stimulus 
% where the center is a sinusoidal grating with ori, sp. freq and size set 
% as the cell's preferred ones and the surround is a concentric sinusoidal 
% grating with the same spatial frequency and varying orientation.
% 
% INPUT
% myseed    [integer] seed for random number generator; should match the seed selected to learn the connectivity (PHI/C)
% n         [integer] index of the recorded cell
% whichPop  [string] {'a', 'b'}
% whitlong  [flag variable] 
%           1 implements the model with long-range interactions, 0 without
% 
% USAGE EXAMPLE
% myseed = 4; whichPop = 'a'; n = 1007; withlong = 1;
% [an,bn]=Job06_OrientationModulation_4loc(myseed, n, whichPop, withlong);

%%% Create folder where to store results
CurrentFolder = pwd;
D_C_path = strcat(CurrentFolder, '/dict_and_corr/');
IntermediateFolder = 'contextual_modulation_location';
ResFolder = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/Paradigm_2/');
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
if ~withlong
    C = zeros(size(C)); %#ok<NODEF>
end
load(FileNameAux, 'index_sel', 's_max', 'r_max', 'o_max');

fprintf('\n')
if ismember(n, index_sel)
    if exist(ResFileComplete, 'file')==2
        fprintf('You already have results for seed %d, cell %d!\n', myseed, n)
        an = [];
        bn = [];
    else
        %%% Execute experiment
        fprintf('Running simulation for seed %d, cell %d\n', myseed, n)
        o = o_max(n);
        s = s_max(n);
        r = r_max(n);
        [an, bn] = OrientationModulation_1loc(D, C, n, o, s, r);
        %%% Save results
        fprintf('Saving resuluts...\n')
        save(ResFileComplete, 'an', 'bn')
        fprintf('...%s saved!\n', ResFileComplete)
    end
else
    an = [];
    bn = [];
    fprintf('Cell %d (seed %d) is not responsive nor tuned, it will not be tested for paradigm 2 (orientation tuning of the surround)\n', n, myseed)
end