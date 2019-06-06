function [a, Recotmp, a_his] = GradDesc_Coefficients(N_RECO, Recotmp, x, a, B, a_lambda, a_eta)

if nargout>2
    a_his = zeros([size(a), N_RECO]);
else
    a_his = [];
end

for ka = 1:N_RECO
    % debugging
    if sum(isnan(a(:)))>0
        disp([ka sum(isnan(a(:)))])
        return
    end
    
    if nargout>2
        a_his(:, :, ka) = a;
    end
    % Compute the gradient w.r.t. a
    a_grad_reco = 2*B'*Recotmp;
    a_grad_spar = a_lambda*sign(a);
    a_grad = a_grad_reco + a_grad_spar;
    
    % Update a (additive rule)
    a_change = a_eta*a_grad;
    a = a - a_change;
    
    % Update B
    Recotmp = B*a-x;
end