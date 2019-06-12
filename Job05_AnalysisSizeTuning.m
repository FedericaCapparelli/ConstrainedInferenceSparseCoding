function [susu_short, susu_short_long] = Job05_AnalysisSizeTuning(myseed, whichPop, nloc)
% This function analyse the results from Job03_SizeTuning_4loc.
% It selects the responsive and tuned cells (for the specified population and 
% for a particular seed of both models with and withour long-range
% interactions) at returns their response at the preferred angle and preferred
% spatial frequency for all tested stimulus size.
% It saves a file containing the output of the fuction.
% 
% INPUT
% myseed    [integer] seed for random number generator; should match the seed selected to learn the connectivity (PHI/C)
% whichPop  [string] {'a', 'b'}
% nloc      [integer] number of surround patches to be considered {1, 4}
% 

%%% Create folder where to store results
CurrentFolder = pwd;
if nloc==1
    IntermediateFolder = 'contextual_modulation_4locations';
elseif nloc==4
    IntermediateFolder = 'contextual_modulation_1location';
end
ResFolder = strcat(CurrentFolder, '/', IntermediateFolder, '/seed_', sprintf('%02.0f', myseed), '/Paradigm_1/');
if whichPop == 'a'
    FileName = strcat(ResFolder, 'SuSu_VarForPlotting_A.mat');
else
    FileName = strcat(ResFolder, 'SuSu_VarForPlotting_B.mat');
end

%%% Add library
addpath(strcat(CurrentFolder, '/lib_context/'));

%%% Aux variables
M = 256; N = 1024; resolution = sqrt(M);

ori_vect = (0:5:179)*pi/180; % [rad]
spfr_vect= 0.05:0.025:0.35; % [number of cycles/pixel]
rad_vect = 2:(2*resolution); % [pixels]

NO = numel(ori_vect);
NS = numel(spfr_vect);
NR = numel(rad_vect);

thre_tuning = 0.77;

%%% Get all activities
fprintf('Loading results from %s...\n', ResFolder)
a_short_only = zeros(NO, N, NS, NR);
a_short_long = zeros(NO, N, NS, NR);
for s=1:NS
    for r=1:NR
        FileName        = strcat(ResFolder, sprintf('s_%02.0f_r_%02.0f.mat', s, r));
        FileName_nolong = strcat(ResFolder, sprintf('s_%02.0f_r_%02.0f_nolong.mat', s, r));
        if whichPop == 'a'
            load(FileName, 'ya')
            a_short_long(:, :, s, r) = ya(1:N, :)'; %#ok<*NODEF>
            load(FileName_nolong, 'ya')
            a_short_only(:, :, s, r) = ya(1:N, :)';
        else
            load(FileName, 'yb')
            a_short_long(:, :, s, r) = yb(1:N, :)'; %#ok<*IDISVAR>
            load(FileName_nolong, 'yb')
            a_short_only(:, :, s, r) = yb(1:N, :)';
        end
    end
end

%%% Select their best stimulus (at fixed small radius)
r = 2;
a = zeros(N, NO);
a_max   = zeros(N, 1);
o_max   = zeros(N, 1);
s_max   = zeros(N, 1);
for n=1:N
    ya = squeeze(a_short_long(:, n, :, r));

    [val, pos] = max(ya(:));
    a_max(n) = val;
    [o, s] = ind2sub(size(ya), pos);
    o_max(n, 1) = o; % i don't really use it
    s_max(n, 1) = s;
    
    % a(n, :) = a_short_only(:, n, s, r);
    a(n, :) = a_short_long(:, n, s, r);
end

%%% Select cells
thresh_responsive = 10*max(a_max)/100; 
index_responsive = find(a_max>thresh_responsive);
[index_n, index_ang, ~] = ReturnTunedCells(a', thre_tuning);
n_tuned = numel(index_n);
index_sel = intersect(index_responsive, index_n);
n_sel = numel(index_sel);

fprintf('(seed %d) There are \t%d cells whose response is greater that a rate-threshold,\n \t\t%d tuned cells,\n \t\t%d cells who are both\n\n', myseed, numel(index_responsive), n_tuned, n_sel)

%%% Get activity of tuned cells at the best angle for all the radii
% ...for the case of SHORT-RANGE interactions only
% ...for the case of SHORT-RANGE + LONG_RANGE interactions
susu_short = zeros([NR n_sel]);
susu_short_long = zeros([NR n_sel]);
for k=1:n_sel
    susu_short(:, k) = squeeze(a_short_only(index_ang(index_sel(k)), index_sel(k), s_max(index_sel(k)), :));
    susu_short_long(:, k) = squeeze(a_short_long(index_ang(index_sel(k)), index_sel(k), s_max(index_sel(k)), :));
end

%%% Save results
save(FileName, 'susu_short', 'susu_short_long')