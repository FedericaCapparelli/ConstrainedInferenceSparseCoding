function [yprime] = SparseCodingLongRange_Dynamics_ode45_1surround(t, y, M, N, tau_a, tau_b, lambda, InputSignal, PHI_T, PHI_T_PHI, cplus, cminus)

% quantities at time (t-1)
h = reshape(y(1:(4*N)), [N 4]);
k = reshape(y((4*N+1):end), [N 4]);
a = max(h-lambda, 0);
b = max(k, 0);

% aux vars
if isnumeric(InputSignal)
    s = reshape(InputSignal, [M 2]);
else
    s = reshape(InputSignal(t), [M 2]);
end
inp = PHI_T*s;
tmp_u = PHI_T_PHI*(b(:, 1)-b(:, 2));
tmp_v = PHI_T_PHI*(b(:, 3)-b(:, 4));

% update at time (t)

yprime = zeros([N 8]);

yprime(:, 1) = (-h(:, 1)+inp(:, 1)-tmp_u+a(:, 1))/tau_a;			% u+
yprime(:, 2) = (-h(:, 2)-inp(:, 1)+tmp_u+a(:, 2))/tau_a;			% u-
yprime(:, 3) = (-h(:, 3)+inp(:, 2)-tmp_v+a(:, 3))/tau_a;			% v+
yprime(:, 4) = (-h(:, 4)-inp(:, 2)+tmp_v+a(:, 4))/tau_a;			% v+

yprime(:, 5) = (-k(:, 1)+a(:, 1)+cplus*a(:, 3)+cminus*a(:, 4))/tau_b;
yprime(:, 6) = (-k(:, 2)+a(:, 2)+cminus*a(:, 3)+cplus*a(:, 4))/tau_b;
yprime(:, 7) = (-k(:, 3)+a(:, 3)+cplus'*a(:, 1)+cminus'*a(:, 2))/tau_b;
yprime(:, 8) = (-k(:, 4)+a(:, 4)+cminus'*a(:, 1)+cplus'*a(:, 2))/tau_b;

yprime = reshape(yprime, [8*N 1]);