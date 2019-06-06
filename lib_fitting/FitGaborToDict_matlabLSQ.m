function [params, R2, exitflag] = FitGaborToDict_matlabLSQ(z, params_ini, params_lower_bound, params_upper_bound, verbose)
% Ispirato a:
% function [params,R2] = fitgabor2d(z,params0)
%
% <z> is a 2D square matrix of values
% <params0> (optional) is an initial seed.
%   default is [] which means make up our own initial seed.
%
% use lsqcurvefit.m to estimate parameters of a 2D Gabor function.
% return:
%  <params> is like the input to evalgabor2d.m (the second flavor).
%  <R2> is the R^2 between fitted and actual z-values (see calccod.m).
%  <exitflag> (added by fede) as returned from the function lsqcurvefit
%
% example:
% z = makegabor2d(32,[],[],4,pi/6,0,2) + randn(32,32)*.1;
% [params,R2] = fitgabor2d(z);
% figure; imagesc(z,[-2 2]);
% [xx,yy] = calcimagecoordinates(32);
% figure; imagesc(evalgabor2d(params,xx,yy),[-2 2]); title(sprintf('R2=%.5f',R2));
%

%%% Check input
if ~exist('verbose', 'var')
    verbose = 0;
end
%%% Construct coordinates
res = size(z,1);
[xx,yy] = meshgrid(1:res, res:-1:1);

%%% Define options
% 'OutputFcn',@fitgaussian2doutput);,  % ,,OutputFcn',@fitblah
% options = optimset('Display','final','MaxFunEvals',Inf,'MaxIter',Inf,'TolFun',1e-10,'TolX',1e-10); %orig
if verbose
    options = optimset('Display','final','MaxFunEvals',Inf,'MaxIter',10000,'TolFun',1e-10,'TolX',1e-10); % fede
else
    options = optimset('Display','off','MaxFunEvals',Inf,'MaxIter',10000,'TolFun',1e-10,'TolX',1e-10); % fede
end

%%% Define seed
if ~exist('params_ini','var') || isempty(params_ini)
    % shift coordinates
    if mod(res,2)==0
        [cxx,cyy] = meshgrid(-res/2:res/2-1,-res/2:res/2-1);
    else
        [cxx,cyy] = meshgrid(-(res-1)/2:(res-1)/2,-(res-1)/2:(res-1)/2);
    end
    
    zhat = fftshift(abs(fft2(z)));
    [~, ix] = max(zhat(:)); % ix e' come pos sotto
    cpfov = sqrt(cxx(ix)^2+cyy(ix)^2);
    
    zx = repmat((1:res), [res 1]).*(z.^2);
    zy = repmat(fliplr(1:res), [res 1]).*(z.^2);
    xseed = sum(zx(:))/sum(z(:).^2);
    yseed = sum(zy(:))/sum(z(:).^2);
    oriseed = mod(-atan2(cyy(ix),cxx(ix))-pi/2,pi);
    
    params_ini =  [cpfov/res oriseed 0 xseed yseed (2/cpfov)/4*res (2/cpfov)/4*res range(z(:))/2 mean(z(:))];
    fprintf('initial seed is %s\n', mat2str(params_ini,5));
end

%%% Define bounds
if ~exist('params_lower_bound','var') || isempty(params_lower_bound)
    %                     cpu         ang     phase   mx      my      sd1 	sd2     contr   offset
    params_lower_bound = [0           -Inf   -Inf     -Inf    -Inf    -Inf    -Inf    0      -Inf];
end
if ~exist('params_upper_bound','var') || isempty(params_upper_bound)
    params_upper_bound = [1/2*sqrt(2) Inf    Inf      Inf    Inf     Inf     Inf     Inf     Inf ];
end

%%% do it
[params, ~, ~, exitflag, ~] = lsqcurvefit(@evalgabor2d, params_ini, [xx(:)'; yy(:)'], z(:)', params_lower_bound, params_upper_bound, options);

%%% sanity transformation
params(2:3) = mod(params(2:3),2*pi);
params(6:7) = abs(params(6:7));

%%% how well did we do?
zvec = z(:)';
zfit = evalgabor2d(params, [xx(:)'; yy(:)']);
zfit(isnan(zvec)) = NaN;
zvec(isnan(zfit)) = NaN;
zfit = zfit - nanmean(zfit);
zvec = zvec - nanmean(zvec);
numerator = nansum((zfit-zvec).^2);
denominator = nansum(zvec.^2);
if denominator~=0
    R2 = 100*(1-numerator/denominator);
else
    R2 = NaN;
end

