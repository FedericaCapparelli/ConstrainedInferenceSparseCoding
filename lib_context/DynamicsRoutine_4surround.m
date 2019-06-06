function [t,a,b] = DynamicsRoutine_4surround(M, N, T, tau_sup, tau_deep, lambda_a, D, CH, CV, stim, y0)
% This function calls the matlab in-built ode45 to solve the system of 
% differential equations that defines the neural dynamics.
% Such system is defined in SparseCodingLongRange_Dynamics_ode45_4surround
% 
% INPUT
% M         stimulus size
% N         numer of neurons per cortical location
% T         duration of stimulus presentation
% tau_sup   time constant of population b
% tau_deep  time constant of population a
% lambda_a  sparseness constraint
% D         dictionary/input fields
% CH        long-range connections (learned from horizontal configuraion)
% CV        long-range connections (learned from horizontal configuraion)
% stim      stimulus
% y0        [optional] initial conditions
% 
% OUTPUT
% t         time axis
% a         solution for neurons in population a at point in time contained in t
% b         solution for neurons in population b at point in time contained in t

if nargin<11
    y0 = zeros(10*N, 1); 
end

PHI_T = D';
PHI_T_PHI = D'*D;

tic
[t,y] = ode45( @(t, y) SparseCodingLongRange_Dynamics_ode45_4surround(t, y, M, N, tau_sup, tau_deep, lambda_a, stim, PHI_T, PHI_T_PHI, CH, CV), [0 T], y0);
toc

a = max(y(:, 1:5*N)-lambda_a, 0);
b = max(y(:, (5*N+1):end), 0);
