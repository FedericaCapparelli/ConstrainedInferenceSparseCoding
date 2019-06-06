function [yprime] = SparseCodingLongRange_Dynamics_ode45_4surround(t, y, M, N, tau_a, tau_b, lambda, InputSignal, PHI_T, PHI_T_PHI, ch_plus, cv_plus)
% Remember that...
% index 1 corresponds to neurons of pop a responding to the central patch
% index 2 corresponds to neurons of pop a responding to the right-hori patch
% index 3 corresponds to neurons of pop a responding to the left-hori patch
% index 4 corresponds to neurons of pop a responding to the vert-top patch
% index 5 corresponds to neurons of pop a responding to the vert-bottom patch
% index 6 corresponds to neurons of pop b responding to the central patch
% index 7 corresponds to neurons of pop b responding to the right-hori patch
% index 8 corresponds to neurons of pop b responding to the left-hori patch
% index 9 corresponds to neurons of pop b responding to the vert-top patch
% index 10 corresponds to neurons of pop b responding to the vert-bottom patch

%%% quantities at time (t-1)
h = reshape(y(1:(5*N)), [N 5]);
k = reshape(y((5*N+1):end), [N 5]);
a = max(h-lambda, 0);
b = max(k, 0);

%%% aux vars
if isnumeric(InputSignal)
    s = ReshapeNpatchStim(InputSignal, sqrt(M));
else
    s = ReshapeNpatchStim(InputSignal(t), sqrt(M));
end

%%% compute feed-forward input
inp = PHI_T*s;
% inp is a Mx9 matrix. 
% It can be visualized by running 
% for p=1:9, subplot(3,3,p); imagesc(reshape(s(:, p), [16 16])); title(num2str(p)); drawnow; end
% Each column of inp contains the stimulus of one of the 9 patches in which
% the visual field is divided.
% The visual field patches are numbered from left to right and top bottom,
% so that...
% ... column 5 correponds to central patch
% ... column 6 correponds to (right hori) right of the center
% ... column 4 correponds to (left hori) left of the center
% ... column 2 correponds to (top vert) top of the center
% ... column 8 correponds to (bottom vert) bottom of the center

%%% Compute local interactions
loc_1 = PHI_T_PHI*b(:, 1);
loc_2 = PHI_T_PHI*b(:, 2);
loc_3 = PHI_T_PHI*b(:, 3);
loc_4 = PHI_T_PHI*b(:, 4);
loc_5 = PHI_T_PHI*b(:, 5);

%%% Compute long-range interactions
long_1 = ch_plus*a(:, 2)+cv_plus'*a(:, 3) + ch_plus'*a(:, 4)+cv_plus*a(:, 5);
long_2 = ch_plus'*a(:, 1);
long_3 = cv_plus*a(:, 1);
long_4 = ch_plus*a(:, 1);
long_5 = cv_plus'*a(:, 1);

%%% Compute update at time (t)
yprime = zeros([N 2*5]); % 2pops * 5locations

yprime(:, 1) = ( -h(:, 1) + inp(:, 5) - loc_1 + a(:, 1) )/tau_a;	% 0+ (center)
yprime(:, 2) = ( -h(:, 2) + inp(:, 6) - loc_2 + a(:, 2) )/tau_a;	% HR+
yprime(:, 3) = ( -h(:, 3) + inp(:, 2) - loc_3 + a(:, 3) )/tau_a;	% VT+
yprime(:, 4) = ( -h(:, 4) + inp(:, 4) - loc_4 + a(:, 4) )/tau_a;	% HL+
yprime(:, 5) = ( -h(:, 5) + inp(:, 8) - loc_5 + a(:, 5) )/tau_a;	% VB+

yprime(:, 1+5) = ( -k(:, 1) + a(:, 1) + long_1 )/tau_b;
yprime(:, 2+5) = ( -k(:, 2) + a(:, 2) + long_2 )/tau_b;
yprime(:, 3+5) = ( -k(:, 3) + a(:, 3) + long_3 )/tau_b;
yprime(:, 4+5) = ( -k(:, 4) + a(:, 4) + long_4 )/tau_b;
yprime(:, 5+5) = ( -k(:, 5) + a(:, 5) + long_5 )/tau_b;

yprime = reshape(yprime, [10*N 1]);

