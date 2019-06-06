function silly = SmoothConcentricGratings(n_v, n_h, c_v, c_h, ori_cen, ori_sur, r_cen, r_sur, phase_cen, phase_sur, lambda, slope, contr_cen, contr_sur)
if nargin==0
    n_v = 128; % height/number of rows/vertical dimension
    n_h = 128; % width/number of cols/horizontal dimension
    c_v = n_v/2;
    c_h = n_h/2;
    
    ori_cen = 0; % [rad]
    ori_sur = pi/4; % [rad]
    r_cen = [0 5];
    r_sur = [5 32]; % radius: from r_sur(1) to r_sur(2)
    phase_cen = 0; % [rad]
    phase_sur = 0; % [rad]
    lambda = 6; % 1/spatial_frequency
    slope = Inf; % Inf = not smooth at all
    contr_cen = 1;
    contr_sur = 1;
end
if nargin==12
    contr_cen = 1;
    contr_sur = 1;
end
% Aux variables
[v, h] = meshgrid((1:n_h)-0.5, (1:n_v)-0.5);
vc = v-c_v;
hc = h-c_h;

r2 = vc.^2+hc.^2;
r = sqrt(r2);

mask_cen = 0.5*(1+tanh(slope*(r-r_cen(1))))*0.5.*(1+tanh(slope*(r_cen(2)-r)));
mask_sur = 0.5*(1+tanh(slope*(r-r_sur(1))))*0.5.*(1+tanh(slope*(r_sur(2)-r)));

r_tan_cen = hc*cos(ori_cen)+vc*sin(ori_cen);
r_tan_sur = hc*cos(ori_sur)+vc*sin(ori_sur);

% Create output
silly = contr_cen*sin(r_tan_cen/lambda*2*pi+phase_cen).*mask_cen+ ...
        contr_sur*sin(r_tan_sur/lambda*2*pi+phase_sur).*mask_sur;
    


    