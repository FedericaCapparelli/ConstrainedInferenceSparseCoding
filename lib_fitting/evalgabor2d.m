function gab = evalgabor2d(params,x,y)
% This function evaluates a 2D Gabor at x and y.
%
% INPUT
% <params> is [cpu ang phase mx my sd g d] where
%   <cpu> is the number of cycles per unit
%   <ang> is the orientation in [0,2*pi).  0 means a horizontal grating.
%   <phase> is the phase in [0,2*pi)
%   <mx>,<my> is the center
%   <sd> is the standard deviation of the Gaussian envelope (assumed isotropic)
%   <g> is the gain in [0,Inf) (1 means the total peak-to-trough distance is 2)
%   <d> is the offset
%     OR [cpu ang phase mx my sd1 sd2 g d] where
%   <sd1> is the standard deviation along the major axis
%   <sd2> is the standard deviation along the minor axis
% <x>,<y> are matrices containing x- and y-coordinates to evaluate at.
%   you can omit <y> in which case we assume the first row
%   of <x> contains x-coordinates and the second row contains
%   y-coordinates.
%
% OUTPUT
%
% USAGE
% function f = evalgabor2d(params,x,y);
%
% EXAMPLE
% x = 0:.01:1; y = 0:.01:2; [xx,yy] = meshgrid(x,y);
% gab = evalgabor2d([4 pi/6 0 .5 .5 .1 1 0],xx,yy);
% figure; imagesc(x,y,gab); colorbar; set(gca, 'yDir', 'normal', 'DataAspectRatio', [1 1 1])

% input
if ~exist('y','var')
    y = x(2,:);
    x = x(1,:);
end

cpu = params(1); % spatial frequency
ang = params(2); % orientation
phase = params(3);
mx = params(4);
my = params(5);
sd1 = params(6);
sd2 = params(7);
g = params(8);
d = params(9);

% Intention:
% - Positive orientations correspond to counter-clockwise rotations
% - We want to start from a Gaussian aligned with coordinate axes
% To obtains coordinate axes, we need to 'undo' the rotation,
% i.e. to rotate clockwise,
% i.e. to apply
% [x' y']' = [cos ang  sin ang; -sin ang  cos ang] [x y]'.
x_centered = x(:)'-mx;
y_centered = y(:)'-my;
coord = [cos(ang) sin(ang); -sin(ang) cos(ang)]*[x_centered; y_centered];

gaussiana = exp(- 1/2 *(coord(1,:).^2/(sd1^2) + coord(2,:).^2/(sd2^2)) );
sinusoide = cos(2*pi*cpu*coord(2,:) + phase);
gab = g*gaussiana.*sinusoide + d;
gab = reshape(gab,size(x));
