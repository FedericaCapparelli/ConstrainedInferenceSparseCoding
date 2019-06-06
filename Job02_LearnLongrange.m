function [C, sparsity_a, sparsity_C, reconstruction, reco_norm] = Job02_LearnLongrange(model, dyn, gen, C_init)
% This function solves the optimization problem
% min{ || PHI*a^u + PHI*C*a^v - x^u ||^2_2 + || PHI*a^v + PHI*C*a^u - x^v ||^2_2 + lambda_a*S_a(a) + lambda_C*S_C(C) }
% =
% min{ || [PHI 0; 0 PHI]*a + [PHI PHI*C; PHI*C PHI]*a^v - x ||^2_2 + lambda_a*S_a(a) + lambda_C*S_C(C)  }
%
% w.r.t. C and a

N = model.N;                    % number of features (hidden nodes)
M = model.M;                    % number of pixels (input nodes)
patch_size = model.patch_size;  % size of a single image patch
n_patch = model.n_patch;        % number of patches
alitp = model.alignment;        % alignment of image patches
N_ENSB = dyn.n_ensembles;       % total number of iterations
N_BATCH = dyn.reco.n_samples;   % number of image patches to be used in parallel for reconstruction
N_RECO = dyn.reco.n_iter;       % number of iterations (reconstruction step)
N_FEAT = dyn.dict.n_iter;       % number of iterations (dictionary update step)
N_LEARN = dyn.learn.n_iter;     % number of iterations (learning step)
a_eta = dyn.reco.eta;           % reconstruction rate
d_eta = dyn.dict.eta;           % learning rate (dictionary)
c_eta = dyn.learn.eta;          % learning rate (long-range)
a_lambda = dyn.reco.lambda;     % sparseness constraint (a)
C_lambda = dyn.learn.lambda;    % sparseness constraint (C)
C_flag_L1 = dyn.learn.flag_L1;  % L1 norm for learning C
RandomSeed = gen.RandomSeed;    % seed for random number generator
IMAGES = gen.images;            % Images dataset
nameFromUser = gen.nameFromUser; pos_str = strfind(nameFromUser, '.mat');

fprintf('Setting random seed to %d\n', RandomSeed)
rng(RandomSeed)

fprintf('Loading dictionary (N=%d features, M=%d pixels)...\n', N, M)
D = [];
load(gen.dict_path, 'D');

% Create auxiliary variables
if ~exist('C_init', 'var')
    C_init = 0.1*randn(N, N)/(N^2);
end
[extract_size, num_im, height_im, width_im] = GetInfoPatches(IMAGES, alitp, patch_size, n_patch);
x = zeros(n_patch*M, N_BATCH);

% Initialize output
reconstruction  = zeros(1, N_ENSB);
reco_norm       = zeros(1, N_ENSB);
sparsity_a      = zeros(1, N_ENSB);
sparsity_C      = zeros(1, N_ENSB);
C = C_init;
B = [D D*C; D*C' D];

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
    [a, D, C, B] = GradDesc_2Loc(N, M, N_BATCH, N_RECO, N_FEAT, N_LEARN, D, C, B, a, x, C_flag_L1, a_lambda, C_lambda, a_eta, d_eta, c_eta);
    % Compute energy function
    reconstruction(j) = mean(sum((x-B*a).^2, 1));
    reco_norm(j) = mean(sum((x-B*a).^2, 1)./sum(x.^2, 1));
    sparsity_a(j) = a_lambda*mean(sum(abs(a), 1));
    sparsity_C(j) = C_flag_L1*sum(abs(C(:))) + (1-C_flag_L1)*(sum(C(:).^2));
    % Monitor learning
    if mod(j, gen.SaveEvery)==0
        tmp_name_C = strcat(nameFromUser(1:pos_str-1), '_ITER_', sprintf('%01.0f',j), nameFromUser((pos_str):end));
        tmp_name_obj = strcat(nameFromUser(1:pos_str-1), '_OBJFUN', nameFromUser((pos_str):end));
        fprintf('Saving snapshot...%s (%s)\n', tmp_name_C, datestr(now))
        save(tmp_name_C, 'C', '-v7.3')
        save(tmp_name_obj, 'j', 'reconstruction', 'reco_norm', 'sparsity_a', 'sparsity_C', '-v7.3')
    end
end
fprintf('\n')

fprintf('Saving results...%s\n', gen.nameFromUser)
save(gen.nameFromUser, 'sparsity_a', 'sparsity_C', 'reconstruction', 'reco_norm', 'C', '-v7.3')
fprintf('Results saved!\n\n')
toc

