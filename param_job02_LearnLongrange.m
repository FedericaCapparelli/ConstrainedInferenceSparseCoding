%% Parameters & paths defined by the user
%%% Define seed for random number generator
myseed = 4;

%%% Select type of input configuration (this choice is irrelevant is N_PATCH is set to 1)
% 'h'       % horizontal
% 'v'       % vertical
% 'd_NE_SW' % diagonal (45 deg)
% 'd_NW_SE' % diagonal (135 deg)
alignType = 'h';

%%% Create folder where to store results
CurrentFolder = pwd;
IntermediateFolder = 'dict_and_corr';
ResFolder = strcat(CurrentFolder, '/', IntermediateFolder, '/');
if 7~=exist(ResFolder, 'dir')
    fprintf('Creating folder %s\n', ResFolder)
    mkdir(ResFolder)
end
switch alignType
    case 'h'
        Prename = 'C'; % horizontal
    case 'v'
        Prename = 'V'; % vertical
    case 'd_NW_SE'
        Prename = 'W'; % diagonal from NW to SE (135 degrees)
    case 'd_NE_SW'
        Prename = 'E'; % diagonal from NE to SW (45 degrees)
end
ResFile = strcat(Prename, sprintf('%01.0f.mat', myseed));
ResFileComplete = strcat(ResFolder, ResFile);

%%% Add library path
addpath(strcat(CurrentFolder, '/lib_learning'));

%%% Define path from where dictionary needs to be loaded
DictPath = strcat(ResFolder, sprintf('D%01.0f.mat', myseed));

%%% Speficy path of images. Variable containing the images should have size (heigth x width x NumerOfImg)
% ImagePath = '/home/federica/Documents/MATLAB/Olshausen_Field_1996/sparsenet/IMAGES.mat';
ImagePath = '/0/federica/NatImageDataset/McGill/horizontal/IMAGES.mat';
% ImagePath = '/0/federica/NatImageDataset/Berkeley/IMAGES.mat'; % berkeley

%%% Other parameters
M = 256;            % number of pixels of a singl image patch (input nodes)
N = 1024;           % number of features (hidden nodes)
N_PATCH = 2;        % number of patches
a_eta = 0.01;       % learning rate (reconstruction step)
d_eta = 0;          % learning rate (dictionary update step)
c_eta = 0.1;        % learning rate (long-range)
lambda_a = 0.5;     % sparsenes constraint (a)
lambda_c = 2e-2;    % sparsenes constraint (C)
c_flag_l1 = 0;
N_BATCH = 100;      % number of image patches to be used in parallel for reconstruction
N_RECO = 5e3;       % number of iterations (reconstruction step)
N_FEAT = [];        % number of iterations (dictionary update step)
N_LEARN = 1;        % number of iterations (learning step)
N_ENSB = 5000;      % total number of iterations
N_SaveEvery = 250;  % a snapshot of learning is saved after SaveEvery iterations

%% Load images & Make structs for main routine
fprintf('Loading Images from %s...', ImagePath); 
load(ImagePath); 
fprintf('Images Loaded\n')

gen.images = IMAGES;
gen.RandomSeed = myseed;
gen.SaveEvery = N_SaveEvery;
gen.database_path = ImagePath;
gen.nameFromUser = ResFileComplete;
gen.dict_path = DictPath;

% specify the generative model...
model.N = N;
model.M = M;
model.patch_size = [sqrt(M) sqrt(M)];
model.n_patch = N_PATCH;
model.alignment = alignType;

% learning dictionary parameters
dyn.dict.eta = d_eta;
dyn.dict.n_iter = N_FEAT;

% reconstruction parameters
dyn.reco.lambda = lambda_a;
dyn.reco.eta = a_eta;
dyn.reco.n_samples = N_BATCH;
dyn.reco.n_iter = N_RECO;

% learning parameters
dyn.learn.flag_L1 = c_flag_l1;
dyn.learn.lambda = lambda_c;
dyn.learn.eta = c_eta;
dyn.learn.n_iter = N_LEARN;

dyn.n_ensembles = N_ENSB;