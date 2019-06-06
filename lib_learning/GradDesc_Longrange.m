function [C, B] = GradDesc_Longrange(N_LEARN, N_BATCH, M, N, Recotmp, x, a, D, C, C_flag_L1, C_lambda, c_eta)


for kc = 1:N_LEARN
    % Compute the gradient w.r.t. C
    %         C_grad_reco = 2*[PHI' zeros(N, M); zeros(N,M) PHI']*Btmp*[a(N+1:end,:); a(1:N,:)]';
    %         C_grad_reco = C_grad_reco(1:N, 1:N)+C_grad_reco(N+1:end, N+1:end);
    %         C_grad_reco = C_grad_reco/N_BATCH;
    
    C_grad_reco = Recotmp*[a(N+1:end,:); a(1:N,:)]';
    C_grad_reco = 2*D'*C_grad_reco(1:M, 1:N) + (2*D'*C_grad_reco(M+1:end, N+1:end))';
    C_grad_reco = C_grad_reco/N_BATCH;
    
    % Note that you don't regularize if C_lambda = 0
    C_grad_spar = C_flag_L1*C_lambda*sign(C) + (1-C_flag_L1)*C_lambda*2*C;
    C_grad = C_grad_reco + C_grad_spar;
    
    C_change = c_eta*C_grad;
    C = C - C_change;
       
    % Update B
    B = [D D*C; D*C' D];
    Recotmp = B*a-x; % reconstruction
end

end % end of function