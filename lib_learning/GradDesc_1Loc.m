function [a, D] = GradDesc_1Loc(N_RECO, N_FEAT, D, a, x, a_lambda, a_eta, d_eta)
% This function performs gradient descent to update a, PHI and C

% Auxiliary variables
Recotmp = D*a-x; % pre-computed for speed

% (1) Learn coefficients
if a_eta ~= 0
    [a, Recotmp] = GradDesc_Coefficients(N_RECO, Recotmp, x, a, D, a_lambda, a_eta);
end

% (2) Learn Dictionary
if d_eta ~= 0
    D = GradDesc_Dictionary_Only(N_FEAT, Recotmp, x, a, D, d_eta);
end

end % end of function
