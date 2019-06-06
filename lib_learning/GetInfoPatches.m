function [extract_size, num_im, height_im, width_im] = GetInfoPatches(IMAGES, alitp, patch_size, n_patch)
% Get height and width for allowable starting indices for subimages:
% extract_size  
% heigth_im     represents the last pixel on vertical dimension (from top 
%               to bottom) from where you can start extracting a patch
% width_im      represents the last pixel on horizontal dimension (from 
%               left to right) from where you can start extracting a patch

extract_size = zeros(1, 2);
switch alitp(1)
    case 'h' % landscape
            extract_size(1) = patch_size(1);
            extract_size(2) = n_patch*patch_size(2);
    case 'v' % portrait
        extract_size(1) = n_patch*patch_size(1);
        extract_size(2) = patch_size(2);
    case 'd'
        extract_size(1) = n_patch*patch_size(1);
        extract_size(2) = n_patch*patch_size(2);
end

height_im   = size(IMAGES, 1) - extract_size(1) + 1;
width_im    = size(IMAGES, 2) - extract_size(2) + 1;
num_im      = size(IMAGES, 3); % Number of images

end % end of function