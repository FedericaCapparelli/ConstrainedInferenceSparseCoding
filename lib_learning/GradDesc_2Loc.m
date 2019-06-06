function [a, D, C, B] = GradDesc_2Loc(N, M, N_BATCH, N_RECO, N_FEAT, N_LEARN, D, C, B, a, x, C_flag_L1, a_lambda, C_lambda, a_eta, d_eta, c_eta)
% This function performs gradient descent to update a, D and C
% Auxiliary variables
Recotmp = B*a-x; % pre-computed for speed

% (1) Learn coefficients
if a_eta ~= 0
    [a, Recotmp] = GradDesc_Coefficients(N_RECO, Recotmp, x, a, B, a_lambda, a_eta);
end

% (2) Learn Dictionary
if d_eta ~= 0
    [D, B, Recotmp] = GradDesc_Dictionary(N_FEAT, M, N, Recotmp, x, a, D, C, d_eta);
end

% (3) Learn lateral interactions
if c_eta ~= 0
    [C, B] = GradDesc_Longrange(N_LEARN, N_BATCH, M, N, Recotmp, x, a, D, C, C_flag_L1, C_lambda, c_eta);
end