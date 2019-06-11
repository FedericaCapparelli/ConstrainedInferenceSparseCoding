function [t,a,b,y] = DynamicsRoutine_1surround(M, N, T, tau_sup, tau_deep, lambda_a, D, C, stim, y0)

% Parameters for temporal dynamics
if nargin<10
    y0 = zeros(8*N, 1); % initial conditions
end
PHI_T = D';
PHI_T_PHI = D'*D;

% Long-range interactions
cplus = max(C, 0);
cminus = max(-C, 0);

tic
[t,y] = ode45( @(t, y) SparseCodingLongRange_Dynamics_ode45_1surround(t, y, M, N, tau_sup, tau_deep, lambda_a, stim, PHI_T, PHI_T_PHI, cplus, cminus), [0 T], y0 );
toc

a = max(y(:, 1:4*N)-lambda_a, 0);
b = max(y(:, (4*N+1):end), 0);
