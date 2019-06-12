function [ya, yb] = SizeTuning_1loc(D, C, s, r, typeStim)
% Auxiliary variables
[M, N] = size(D);
resolution = sqrt(M);
patchsize = [resolution 2*resolution];
m = resolution*(resolution-1)/2;

% Model parameters
lambda_a = 0.5; % dyn.reco.lambda;
tau_deep = 10; %[ms] % b coeffs
tau_sup  = 10; %[ms] % a coeffs
T = 600; % [ms]
tempFreq = 3/1000; % [mHz]
from_ms = (T - 1/tempFreq);

[ci, cj] = ind2sub([resolution resolution], m); c_row = ci-0.5; c_col = cj-0.5;
ori_vect   = (0:5:179)*pi/180; % [radian]
spfr_vect  = 0.05:0.025:0.35; % [number of cycles/pixel]
rad_vect   = 2:1:(2*resolution); % [pixel]
NO         = numel(ori_vect);
% NS       = numel(spfr_vect);
% NR       = numel(rad_vect);
% NP       = numel(pha_vect);

% Stimulus parameters
smoothing_slope = 0.5;
kc = 1; % contrast center

spf = spfr_vect(s);
rad = rad_vect(r);
switch typeStim
    case 1 % center-only
        rad_cen = [-100 rad];
        rad_sur = [Inf Inf];
    case 2 % surround-only
        rad_cen = [-100 -100];
        rad_sur = [rad Inf];
end

% Initialize output
ya = zeros(4*N, NO);
yb = zeros(4*N, NO);

% Compute output
for o=1:NO
    fprintf('\nStart sim for ori %d/%d, freq %d, radius %d\n', o, NO, s, r)
    ori = ori_vect(o);
    ori_sur = ori;
    ori_cen = ori;
    
    % Make stimulus
    silly = @(t) SmoothConcentricGratings(patchsize(1), patchsize(2), c_row, c_col, ori_cen, ori_sur, rad_cen, rad_sur, 2*pi*tempFreq*t, 2*pi*tempFreq*t, 1/spf, smoothing_slope, kc, 0);
    
    % Run dynamics
    % [t,a,b] = DynamicsRoutine(N, T, tau_sup, tau_deep, lambda_a, D, C, silly);
    [t,a,b] = DynamicsRoutine_1surround(M, N, T, tau_sup, tau_deep, lambda_a, D, C, silly);
    
    % Save steady-states
    from = find(t>from_ms, 1); % [time steps]
    ya(:, o) = mean(a(from:end, :));
    yb(:, o) = mean(b(from:end, :));
end