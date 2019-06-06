function Dnew = BuildDictFromLongStruc(D, OPT_PAR_LongStruct)
addpath(genpath('/home/federica/Documents/MATLAB/knkutils-master')); % library for gabor functions

[M,N] = size(D);
resolution = sqrt(M);
[xx,yy] = calcimagecoordinates(resolution);

% Build a dictionary Dmanual from the parameters just obtained
Dnew = zeros(M,N);
for n=1:N
    param = GetParamsLongStruct(n, OPT_PAR_LongStruct);
	g = evalgabor2d(param,xx,yy);
    Dnew(:,n) = g(:);
end

