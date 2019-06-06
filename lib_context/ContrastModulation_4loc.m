function [a_cen, a_sur, b_cen, b_sur] = ContrastModulation_4loc(D, C, V, n, o, s, r, typeStim)
% This function ContrastModulation_4loc computes the response of unit n in 
% the network to a center stimulus of varying contrast (sinusoidal grating 
% with ori, sp. freq and size set as the cell's preferred ones) in two
% conditions:
% - no surround
% - surround = concentric sinusoidal grating at high contrast (with the 
% same spatial frequency and orientation as the center)

%%% Aux vars
[M, N] = size(D);
resolution = sqrt(M);
patchsize = [3*resolution 3*resolution];
m = 3*resolution*(3*resolution-1)/2;
[ci, cj] = ind2sub([3*resolution 3*resolution], m); c_row = ci-0.5; c_col = cj-0.5;
ori_vect = (0:5:179)*pi/180;
spfr_vect = 0.05:0.025:0.35; % [number of cycles/pixel]
rad_vect = 2:1:(2*resolution);
contrast_vect = [0.1:0.1:0.9 1]; % [0.3 1]; %
smoothing_slope = 8*0.5;

%%% Model parameters
lambda_a = 0.6; % dyn.reco.lambda;
tau_deep = 10; %[ms] % b coeffs
tau_sup  = 10; %[ms] % a coeffs
T = 600; % [ms]
tempFreq = 3/1000; % [mHz]
from_ms = (T - 1/tempFreq);

%%% Parameters of the stimulus
ori_cen     = ori_vect(o);
switch typeStim
    case 1
        ori_sur = ori_vect(o);
    case 2
        ori_sur = ori_vect(o) + pi/2;
end
r_cen       = [0 rad_vect(r)];
r_sur       = [rad_vect(r) Inf];
lambda      = 1/spfr_vect(s);
contr_sur   = 1;

%%% Initialize output
a_cen = zeros(numel(contrast_vect), 1);
b_cen = zeros(numel(contrast_vect), 1);
a_sur = zeros(numel(contrast_vect), 1);
b_sur = zeros(numel(contrast_vect), 1);

for c=1:numel(contrast_vect)
    contr_cen = contrast_vect(c);
    fprintf('Contrast level: %d of %d\n', c, numel(contrast_vect))
    
    %%% Center-only
    % silly = @(t) EgoCentricGratings(patchsize(1), patchsize(2), resolution/2, resolution/2, ori_cen, ori_sur, r_cen, [Inf Inf], 2*pi*tempFreq*t, 2*pi*tempFreq*t, lambda,contr_cen,0);
    silly = @(t) SmoothConcentricGratings(patchsize(1),patchsize(2),c_row,c_col,ori_cen,ori_sur,r_cen,[Inf Inf],2*pi*tempFreq*t,2*pi*tempFreq*t,lambda,smoothing_slope,contr_cen,0); % how ?
    [t,a,b] = DynamicsRoutine_4surround(M, N, T, tau_sup, tau_deep, lambda_a, D, C, V, silly);
    from = find(t>from_ms, 1); %[time steps]
    a_cen(c) = mean(a(from:end, n));
    b_cen(c) = mean(b(from:end, n));
    
    %%% Center+surround
    silly = @(t) SmoothConcentricGratings(patchsize(1),patchsize(2),c_row,c_col,ori_cen,ori_sur,r_cen,r_sur,2*pi*tempFreq*t,2*pi*tempFreq*t,lambda,smoothing_slope,contr_cen,contr_sur); % how ?
    [t,a,b] = DynamicsRoutine_4surround(M, N, T, tau_sup, tau_deep, lambda_a, D, C, V, silly);
    from = find(t>from_ms, 1); %[time steps]
    a_sur(c) = mean(a(from:end, n));
    b_sur(c) = mean(b(from:end, n));
end
