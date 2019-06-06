%% Parameters & paths defined by the user
%%% Define seed for random number generator
myseed = 4;

%%% Set threshold used to judge the goodness of the least-square-fitting
R2thres = 80;

%%% Create folder where to store results and where to find the learned dictionary
CurrentFolder = pwd;
addpath(strcat(CurrentFolder, '/lib_fitting'));
IntermediateFolder = 'dict_and_corr';

PathIn = strcat(CurrentFolder, '/', IntermediateFolder, '/');
PathOut = PathIn;
NameIn = sprintf('D%01.0f.mat', myseed); 
ResFile1 = strcat(PathOut,'Param_', NameIn);
ResFile2 = strcat(PathIn, NameIn);

%%% Load the dictionary learned with job01
load(strcat(PathIn, NameIn), 'D');

%%% Define useful variables
FLAG_PLOT = 0;
FLAG_VERBOSE = 0;
[M, N] = size(D);
resolution = sqrt(M); 
thetas = (0:22.5:160)*pi/180;
if FLAG_PLOT, [xx,yy] = meshgrid(1:resolution, resolution:-1:1); end

%% Run!
%%% Perform automatic fitting
FIT_PAR_learned = struct([]);
for n=6:N
    fprintf('\n *********************************************************** \n')
    fprintf('fitting element %i \n',n)
    % select a dictionary element
    z = reshape(D(:,n),resolution,resolution);
    % perform fitting (initial values non-specified)
    [params_estimated,R2,~] = FitGaborToDict_matlabLSQ(z, [], [], [], FLAG_VERBOSE);
    % store paramters
    FIT_PAR_learned = StoreParamsLongStruct(n, params_estimated, R2, FIT_PAR_learned);
end

%%% Check the goodness of the fitting
redo = find([FIT_PAR_learned.R2fit]<R2thres);

if FLAG_PLOT
    D_tmp = BuildDictFromLongStruc(D, FIT_PAR_learned);
    CfrDictionariesOverGivenIndexes(D, D_tmp, setdiff(1:N, redo), FIT_PAR_learned, 1) % good
    % CfrDictionariesOverGivenIndexes(D, Dmatlab, redo, FIT_PAR_matlab, 1) % bad
end

%%% Repeat the fitting for those dictionary elements whose R2 is smaller
%%% than a threshold.
%%% The routine FitGaborToDict_matlabLSQ is executed again, this time with
%%% hand-defined initial values boundaries for the parameters that need to be estimated 
for k=1:numel(redo)
    n = redo(k);
    fprintf('\nRe-fitting n=%d (%d of %d)\n', n, k, numel(redo))
    % select a dictionary element
    z = reshape(D(:,n),resolution,resolution);
    % initialize things
    R2s = zeros(size(thetas));
    param_theta = zeros(numel(thetas), 9);
    
    for j=1:numel(thetas)
        % define initial values ('forcing' the orientation parameter to vary in a small range)
        param = [0.22 ...                       FIT_PAR_start(n).spatialFrequency ...
            thetas(j) ...                       FIT_PAR_start(n).orientation ...
            0*pi/180 ...                        FIT_PAR_start(n).phase ...
            [resolution/2 resolution/2] ...     FIT_PAR_start(m).center ...
            resolution/2 ...                    FIT_PAR_start(n).width_x ...
            resolution/2 ...                    FIT_PAR_start(n).width_y ...
            0.15 ...                            FIT_PAR_start(n).contrast ...
            0 ...                               FIT_PAR_start(n).offset];
            ];
        % define boundaries
        %            cpu         ang     phase   mx          my          sd1 	sd2     contr   offset
        paramslb = [0           thetas(j)-pi/6   -Inf     0           0           0                 0           0       -Inf];
        paramsub = [1/2*sqrt(2) thetas(j)+pi/6    Inf     resolution  resolution  resolution     resolution     Inf     Inf ];
        % Perform fitting     
        [params_estimated, R2s(j), ~] = FitGaborToDict_matlabLSQ(z, param, paramslb, paramsub);
        param_theta(j, :) = params_estimated;
    end
    
    % Pick the best R2
    [~, j_best] = max(R2s);
    fprintf('Before: %.1f, now: %.1f\n', FIT_PAR_learned(n).R2fit, R2s(j_best))
    
    % store found params
    if R2s(j_best)>FIT_PAR_learned(n).R2fit
        FIT_PAR_learned = StoreParamsLongStruct(n, param_theta(j_best, :), R2s(j_best), FIT_PAR_learned);
        fprintf('Overwriting parameters...\n')
    end
    
    if FLAG_PLOT
        clf
        param_auto = GetParamsLongStruct(n, FIT_PAR_learned);
        gabor_estimated_start = evalgabor2d(param_auto,xx,yy);
        gabor_estimated_repeat= evalgabor2d(param_theta(j_best, :),xx,yy);
        subplot(221); imagesc(z); set(gca,'DataAspectRatio',[1 1 1]); colorbar; title('orig dict elem')
        subplot(222); imagesc(gabor_estimated_repeat); set(gca,'DataAspectRatio',[1 1 1]); colorbar; title('brute force estimation')
        subplot(223); imagesc(gabor_estimated_start); set(gca,'DataAspectRatio',[1 1 1]); colorbar; title('auto matlab fitting (OLD)')
        drawnow;
    end
end

%%% Store original dictionary (i.e. as it was learned by routine Job_01) and
%%% sort its columns by orientation
Dlearned = D;
[FIT_PAR, D] = SortByOri(FIT_PAR_learned, Dlearned, 2);

%%% Add field 'center of mass' to structure FIT_PAR
CenterOfMass = zeros(N,2);
for n=1:N
    z = reshape(D(:,n), resolution, resolution);
    thresh = abs(z) > 0.2*max(abs(z(:)));
    phi_thresh = z.*thresh;
    
    num = [0 0];
    for x=1:resolution
        for y=1:resolution
            num = num + abs(phi_thresh(x,y))*[y x];
        end
    end
    CenterOfMass(n,:) = num/sum(abs(phi_thresh(:)));
    FIT_PAR(n).center_mass_row = CenterOfMass(n, 1);
    FIT_PAR(n).center_mass_col = CenterOfMass(n, 2);
end

if FLAG_PLOT
    for n2=0:64:(N-64)
        for n1=1:64
            n = n2+n1;
            z = reshape(D(:, n), resolution, resolution);
            c_row_CRF = FIT_PAR(n).center_x;
            c_col_CRF = resolution-FIT_PAR(n).center_y;

            subplot(8, 8, n1);
            imagesc(z); hold on; colormap gray % title(sprintf('phi %i',n)); colormap jet;
            plot(CenterOfMass(n,1),CenterOfMass(n,2),'rx');
            plot(c_row_CRF,c_col_CRF,'co');
            set(gca, 'DataAspectRatio', [1 1 1], 'xTick', [], 'yTick', [])
            drawnow
        end
        waitforbuttonpress
        clf
    end
end

save(ResFile1, 'FIT_PAR_learned', 'FIT_PAR');
save(ResFile2, 'D', 'Dlearned');