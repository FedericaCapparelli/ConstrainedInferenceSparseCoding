function [an, bn] = OrientationModulation_4loc(D, C, V, n, o, s, r)
% This function computes the response of unit n in the network to a
% compound stimulus where the center is a sinusoidal grating with ori, sp.
% freq and size set as the cell's preferred ones and the surround is a
% concentric sinusoidal grating with the same spatial frequency and
% varying orientation.
% 
% INPUT
% D         dictionary/input fields
% C         long-range connections (learned from image patches in an
%           horizontal configuration)
% V         long-range connections (learned from image patches in an
%           vertical configuration)
% n         index of the recorded cell
% o         [integer] index that selects the orientation of the stimulus
% s         [integer] index that selects the spatial frequency of the stimulus
%           range 1:13
% r         [integer] index that selects the radius of the stimulus
%           range 1:31
% 
% OUTPUT
% ya        response of cells in population a
% yb        response of cells in population b

%%% Aux vars
[M, N] = size(D);
resolution = sqrt(M);
patchsize = [3*resolution 3*resolution];
m = 3*resolution*(3*resolution-1)/2;

[ci, cj] = ind2sub([3*resolution 3*resolution], m); c_row = ci-0.5; c_col = cj-0.5;
ori_vect = (0:5:179)*pi/180;
spfr_vect= 0.05:0.025:0.35; % [number of cycles/pixel]
rad_vect = 2:1:(2*resolution);

NO = numel(ori_vect);
% NS = numel(spfr_vect);
% NR = numel(rad_vect);
% NP = numel(pha_vect);

%%% Model parameters
lambda_a = 0.6; % dyn.reco.lambda;
tau_deep = 10; %[ms] % b coeffs
tau_sup  = 10; %[ms] % a coeffs
T = 600; % [ms]
tempFreq = 3/1000; % [mHz]
from_ms = (T - 1/tempFreq);

%%% Stimulus parameters
smoothing_slope = 4;

ori_cen = ori_vect(o); % ori_pref;
spf_pref = spfr_vect(s);
rad_pref = rad_vect(r);

rad_cen = [-100 rad_pref];
rad_sur = [rad_pref Inf];

an = zeros(NO, 1);
bn = zeros(NO, 1);

for q=1:NO
    fprintf('\nStart sim for ori %d/%d (freq %d, radius %d, drifting phase)\n', q, NO, s, r)
    ori = ori_vect(q);
    ori_sur = ori;
    
    % Make stimulus
    silly = @(t) SmoothConcentricGratings(patchsize(1), patchsize(2), c_row, c_col, ori_cen, ori_sur, rad_cen, rad_sur, 2*pi*tempFreq*t, 2*pi*tempFreq*t, 1/spf_pref, smoothing_slope);
    
    % Run dynamics
	[t,a,b] = DynamicsRoutine_4surround(M, N, T, tau_sup, tau_deep, lambda_a, D, C, V, silly);

    % Save steady-states
    from = find(t>from_ms, 1); % [time steps]
    an(q) = mean(a(from:end, n));
    bn(q) = mean(b(from:end, n));
end

