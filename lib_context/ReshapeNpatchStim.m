function y = ReshapeNpatchStim(x, res)
% This function reshapes a matrix x of size [NROW*res NCOL*res] into a
% matrix y of size [res*res NROW*NCOL] by extracting, from left to right and
% top to bottom, submatrices of size [res res] and putting them in the
% column of the ouput y

%%% Aux vars
p = 0;
NROW = size(x, 1)/res;
NCOL = size(x, 2)/res;

%%% Initialize output
y = zeros(res*res, NROW*NCOL);

%%% Create output
for i=1:NROW
    for j=1:NCOL
        p = p+1;
        patch = x((i-1)*res+(1:res), (j-1)*res+(1:res));
        y(:, p) = patch(:);
        % % % for debugging/visualizing
        % subplot(NROW, NCOL, p); imagesc(patch); drawnow;
    end
end

