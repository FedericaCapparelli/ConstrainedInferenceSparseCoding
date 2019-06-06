function [D, reconstruction, sparsity_a, reco_norm] = Job01_LearnDictionary(model, dyn, gen, D_init)
% This function solves the optimization problem
% min{ || D*a^u + D*C*a^v - x^u ||^2_2 + || D*a^v + D*C*a^u - x^v ||^2_2 + lambda_a*S_a(a) + lambda_C*S_C(C) }
% =
% min{ || [D 0; 0 D]*a + [D D*C; D*C D]*a^v - x ||^2_2 + lambda_a*S_a(a) + lambda_C*S_C(C)  }
%
% w.r.t. D and a

N = model.N;                    % number of features (hidden nodes)
M = model.M;                    % number of pixels (input nodes)
patch_size = model.patch_size;  % size of a single image patch
n_patch = model.n_patch;        % number of patches
alitp = model.alignment;        % alignment of image patches
N_ENSB = dyn.n_ensembles;       % total number of iterations
N_BATCH = dyn.reco.n_samples;   % number of image patches to be used in parallel for reconstruction
N_RECO = dyn.reco.n_iter;       % number of iterations (reconstruction step)
N_FEAT = dyn.dict.n_iter;       % number of iterations (dictionary update step)
a_eta = dyn.reco.eta;           % learning rate (reconstruction step)
d_eta = dyn.dict.eta;           % learning rate (dictionary update step)
a_lambda = dyn.reco.lambda;     % sparseness constraint (a)
RandomSeed = gen.RandomSeed;    % seed for random number generator
IMAGES = gen.images;            % Images dataset
nameFromUser = gen.nameFromUser; pos_str = strfind(nameFromUser, '.mat');

fprintf('Setting random seed to %d\n', RandomSeed)
rng(RandomSeed)

% Create auxiliary variables
[extract_size, num_im, height_im, width_im] = GetInfoPatches(IMAGES, alitp, patch_size, n_patch);
if ~exist('D_init', 'var')
    D_init = randn(M, N);
    D_init = D_init*diag(1./(sqrt(sum(D_init.^2)))); % normalize
end
x = zeros(n_patch*M, N_BATCH);

% Initialize output
reconstruction  = zeros(1, N_ENSB);
reco_norm       = zeros(1, N_ENSB);
sparsity_a      = zeros(1, N_ENSB);
D = D_init;

fprintf('Execution starts...\n')
tic
for j=1:N_ENSB
    fprintf('Iteration %d of %d\n', j, N_ENSB)
    % Extract a batch of image samples
    for b=1:N_BATCH
        start_ind = ceil(rand(1, 3).*[height_im, width_im, num_im]);
        x(:,b) = ExtractImagePatches(IMAGES, alitp, patch_size, start_ind, extract_size);
    end
    % Every time a new BATCH is drawn, reinitialize coefficients
    a = (1 + 0.1*rand(n_patch*N, N_BATCH))/N;
    % Optimization step
    [a, D] = GradDesc_1Loc(N_RECO, N_FEAT, D, a, x, a_lambda, a_eta, d_eta);
    % Compute energy function
    reconstruction(j) = mean(sum((x-D*a).^2, 1));
    reco_norm(j) = mean(sum((x-D*a).^2, 1)./sum(x.^2, 1));
    sparsity_a(j) = a_lambda*mean(sum(abs(a), 1));
    % Monitor learning
    if mod(j, gen.SaveEvery)==0
        tmp_name_D = strcat(nameFromUser(1:pos_str-1), '_ITER_', sprintf('%01.0f',j), nameFromUser((pos_str):end));
        tmp_name_obj = strcat(nameFromUser(1:pos_str-1), '_OBJFUN', nameFromUser((pos_str):end));
        fprintf('Saving snapshot...%s\n', tmp_name_D)
        save(tmp_name_D, 'D', '-v7.3')
        save(tmp_name_obj, 'j', 'reconstruction', 'reco_norm', 'sparsity_a', '-v7.3')
    end
end
fprintf('\n')

fprintf('Saving results...%s\n', gen.nameFromUser)
save(gen.nameFromUser, 'D', 'reconstruction', 'sparsity_a', 'reco_norm', '-v7.3')
fprintf('Results saved!\n\n')
toc

