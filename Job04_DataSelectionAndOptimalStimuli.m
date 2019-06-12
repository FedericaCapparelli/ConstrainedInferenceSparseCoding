function [index_sel, o_max, s_max, r_max, SI] = Job04_DataSelectionAndOptimalStimuli(myseed, whichPop, nloc)
% This functions loads the results from Job03_SizeTuning; 
% selects the responsive and tuned cells (for the specified population and 
% for a particular seed) in the model with long-range interactions;
% returns their tuning preferences (ori, sp. freq) at a small fixed radius.
% It also computes their optimal size and their suppression index.
% Saves a file containing the output of the fuction.
% 
% INPUT
% myseed    [integer] seed for random number generator; should match the seed selected to learn the connectivity (PHI/C)
% whichPop  [string] {'a', 'b'}
% nloc      [integer] number of surround patches to be considered {1, 4}
% 
% USAGE EXAMPLE
% myseed = 4; whichPop = 'a';
% [index_sel, o_max, s_max, r_max, SI]=Job04_DataSelectionAndOptimalStimuli(myseed, whichPop);

%%% Create folder where to store results
CurrentFolder = pwd;
if nloc==1
    IntermediateFolder = 'contextual_modulation_4locations';
elseif nloc==4
    IntermediateFolder = 'contextual_modulation_1location';
end
ResFolder = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/Paradigm_1/'); pos = strfind(ResFolder, 'seed')-1;
if whichPop == 'a'
    FileName = strcat(ResFolder(1:pos),'opt_param_small_radius_long_drifting_A.mat');
else
    FileName = strcat(ResFolder(1:pos),'opt_param_small_radius_long_drifting_B.mat');
end

%%% Add library
addpath(strcat(CurrentFolder, '/lib_context/'));

%%% Aux variables
M = 256; N = 1024; resolution = sqrt(M);

ori_vect = (0:5:179)*pi/180;
spfr_vect= 0.05:0.025:0.35; % [number of cycles/pixel]
rad_vect = 2:(2*resolution);

NO = numel(ori_vect);
NS = numel(spfr_vect);
NR = numel(rad_vect);

thre_tuning = 0.77; % 0.85; % 0.7

%%% Get all activities
% act_short_only = zeros(NO, N, NS, NR);
act_short_long = zeros(NO, N, NS, NR);
fprintf('Loading results from %s...\n', ResFolder)
for s=1:NS
    for r=1:NR
        FileNameComplete = strcat(ResFolder, sprintf('s_%02.0f_r_%02.0f.mat', s, r));
        if exist(FileNameComplete, 'file')==2
            if whichPop == 'a'
                load(FileNameComplete, 'ya')
                act_short_long(:, :, s, r) = ya(1:N, :)'; %#ok<*NODEF>
            else
                load(FileNameComplete, 'yb')
                act_short_long(:, :, s, r) = yb(1:N, :)'; %#ok<*IDISVAR>
            end
        end
    end
end

%%% Select their best stimulus (o,s,p) at fixed small radius
r = 2;
a = zeros(N, NO);
a_max   = zeros(N, 1);
o_max   = zeros(N, 1);
s_max   = zeros(N, 1);
for n=1:N
    ya = squeeze(act_short_long(:, n, :, r));
    
    [val, pos] = max(ya(:));
    a_max(n) = val;
    [o, s] = ind2sub(size(ya), pos);
    o_max(n, 1) = o; % i don't really use it
    s_max(n, 1) = s;
    
    % a(n, :) = a_short_only(:, n, s,r);
    a(n, :) = act_short_long(:, n, s, r);
end

%%% Select cells
thresh_responsive = 10*max(a_max)/100;
index_responsive = find(a_max>thresh_responsive);
[index_n, index_ang, ~] = ReturnTunedCells(a', thre_tuning);
index_sel = intersect(index_responsive, index_n);
n_sel = numel(index_sel);

%%% Get activity of tuned cells at the best angle for all the radii
susu_short_long = zeros([NR n_sel]);
for k=1:n_sel
    susu_short_long(:, k) = squeeze(act_short_long(index_ang(index_sel(k)), index_sel(k), s_max(index_sel(k)), :));
end

%%% Compute Surround Suppression Index
SI = (max(susu_short_long, [], 1)-susu_short_long(end, :))./max(susu_short_long, [], 1); %#ok<*NASGU>

%%% Compute best radius (r)
[~, pos_max_long] = max(susu_short_long, [], 1);
r_max = zeros(size(o_max));
r_max(ismember(1:N, index_sel)) = pos_max_long;

%%% Save
save(FileName, 'index_sel', 'o_max', 's_max', 'r_max', 'SI')