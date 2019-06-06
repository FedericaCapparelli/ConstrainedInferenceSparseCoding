function [ya, yb] = Job03_SizeTuning_4loc(myseed, s, r, withlong)
% This routine executes the function SizeTuning_4loc to get responses of all the
% cells from both populations (a & b) for all possible stimuli with or
% without long-range interactions
% 
% Execute it for myseed=1:8, s=1:13, r=1:31, withlong=0:1
% 
% INPUT
% myseed    [integer] seed for random number generator; should match the seed selected to learn the connectivity (PHI/C)
% s         [integer] index that selects the spatial frequency of the stimulus
%           range 1:13
% r         [integer] index that selects the radius of the stimulus
%           range 1:31
% whitlong  [flag variable] 
%           1 implements the model with long-range interactions, 0 without
% 
% USAGE EXAMPLE
% myseed = 4; s = 1; r = 2; withlong = 1;
% [ya, yb] = Run_01_SizeTuning_4loc(myseed, s, r, withlong);

%%% Create folder where to store results
CurrentFolder = pwd;

D_C_path = strcat(CurrentFolder, '/dict_and_corr/');
IntermediateFolder = 'contextual_modulation_4locations';
ResFolder = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/Paradigm_1/');
if 7~=exist(ResFolder, 'dir')
    fprintf('Creating folder %s\n', ResFolder)
    mkdir(ResFolder)
end
if withlong
    ResFile = sprintf('s_%02.0f_r_%02.0f.mat', s, r);
    fprintf('WITH long-range\n')
else
    ResFile = sprintf('s_%02.0f_r_%02.0f_nolong.mat', s, r);
    fprintf('WITHOUT long-range\n')
end
ResFileComplete = strcat(ResFolder, ResFile);

%%% Add library
addpath(strcat(CurrentFolder, '/lib_context/'));

%%% Run
if exist(ResFileComplete, 'file')==2
    fprintf('You already have results for seed %d, freq %d and radius %d!\n', myseed, s, r)
    ya = [];
    yb = [];
else
    %%% Load dictionary and long-range interaction matrix
    load(strcat(D_C_path, 'D', num2str(myseed), '.mat'), 'D');
    load(strcat(D_C_path, 'C', num2str(myseed), '.mat'), 'C'); % learned from image patches with horizontal configuration
    load(strcat(D_C_path, 'V', num2str(myseed), '.mat'), 'V'); % learned from image patches with vertical configuration

    if ~withlong
        C = zeros(size(C)); %#ok<NODEF>
        V = zeros(size(V)); %#ok<NODEF>
    end
    %%% Execute experiment
    fprintf('Running simulation for seed %d, freq %d and radius %d\n', myseed, s, r) 
    typeStim = 1;
    [ya, yb] = SizeTuning_4loc(D, C, V, s, r, typeStim);
    %%% Save results
    fprintf('\nSaving resuluts...\n')
    save(ResFileComplete, 'ya', 'yb')
    fprintf('...%s saved!\n', ResFileComplete)
end