function [D] = GradDesc_Dictionary_Only(N_FEAT, Recotmp, x, a, D, f_eta)
for kf = 1:N_FEAT
    % Compute gradient w.r.t. D
    D_grad =  2*Recotmp*a';

    % Update D (additive rule)
    D_change = f_eta*D_grad;
    D = D - D_change;
    
    % Regularization
    D = D*diag(1./(sqrt(sum(D.^2)))); % L2 norm of each feature is set to 1
    
    % Update reconstruction
    Recotmp = D*a-x; 
end
end % end of function

