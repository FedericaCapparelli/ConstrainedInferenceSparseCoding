function [D, B, Recotmp] = GradDesc_Dictionary(N_FEAT, M, N, Recotmp, x, a, D, C, d_eta)
for kf = 1:N_FEAT
    % Compute gradient w.r.t. D
    %         D_grad1 =  -2*(x(1:M, :) - PHI*a(1:N, :) - PHI*C*a((N+1):end, :))*((a(1:N, :))' + (a((N+1):end, :))'*C') - ...
    %                     2*(x((M+1):end, :) - PHI*a((N+1):end, :) - PHI*C*a(1:N, :))*((a((N+1):end, :))' + (a(1:N, :))'*C');
    D_grad = 2*Recotmp*(a' + [C*a(N+1:end,:); C*a(1:N,:)]');
    D_grad = D_grad(1:M, 1:N) + D_grad(M+1:end, N+1:end);
    
    % Update D (additive rule)
    D_change = d_eta*D_grad;
    D = D - D_change;
    
    D = D*diag(1./(sqrt(sum(D.^2)))); % Regularization (length, variance...)
    
    % Update B
    B = [D D*C; D*C' D];
    Recotmp = B*a-x; % reconstruction
end


