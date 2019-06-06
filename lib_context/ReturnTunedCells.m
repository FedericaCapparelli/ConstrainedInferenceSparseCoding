function [index_n, index_ang, z_theta, check_thre] = ReturnTunedCells(a, thresh)
% INPUT 
% a     matrix containing the activity of cells; must be of szie n_ori x n_neu
%
% USE
% [index_n, index_ang, z_theta, check_thre] = ReturnTunedCells(a, 0.7);
% a_tuned = a(:, index_n);
% figure; imagesc(a); xlabel('neuron index'); ylabel('orientation'); title('not all cells are tuned')
% figure; 
% subplot(211); imagesc(a_tuned);xlabel('neuron index'); ylabel('orientation'); title('now only the tuned cells are shown')
% subplot(212); plot(a_tuned); title('all the tuning curves'); 

if nargin<2
    thresh = min(a(a>0));
end
[n_ori, ~] = size(a);

op_axis = (0:n_ori-1)/n_ori*4*pi; % orientation
dp_axis = (0:n_ori-1)/n_ori*2*pi; % direction

op = exp(1i*op_axis);
dp = exp(1i*dp_axis);

a_norm = sum(a, 1);
z_op = op*a./a_norm; % complex number
z_op(a_norm == 0) = 0;
z_dp = dp*a./a_norm; % complex number
z_dp(a_norm == 0) = 0;

z_theta = mod(angle(z_dp), 2*pi)/2; % This is the angle to which cells are tuned (divided by 2 because we pair modulo pi)
index_ang = 1+mod(round(z_theta/pi*n_ori), n_ori); % This is the index of angle to which cells are tuned

index_n = find(abs(z_op) > thresh);
check_thre = abs(z_op);