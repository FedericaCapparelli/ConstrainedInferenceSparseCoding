function [x] = ExtractImagePatches(IMAGES, alitp, patch_size, start_ind, extract_size)
% Given random starting points, extract subimage, reshape it into a vector

x_patches = IMAGES( start_ind(1):start_ind(1)+extract_size(1)-1, start_ind(2):start_ind(2)+extract_size(2)-1, start_ind(3));

%%% HOW DO I PARALELIZE THE CODE ABOVE FOR N_BATCH? NOT LIKE THIS: :D
%         start_ind = ceil(rand(N_BATCH, 3).*[height_im, width_im, num_im]);
%         q1 = zeros(N_BATCH, extract_size(1));
%         q2 = zeros(N_BATCH, extract_size(2));
%         q3 = zeros(N_BATCH, 1);
%         for b=1:N_BATCH
%             q1(b, :) = start_ind(b, 1):start_ind(b, 1)+extract_size(1)-1;
%             q2(b, :) = start_ind(b, 2):start_ind(b, 2)+extract_size(2)-1;
%             q3(b, :) = start_ind(b, 3);
%         end
%         % x_patches = IMAGES( start_ind(:, 1):start_ind(:, 1)+extract_size(1)-1, start_ind(:, 2):start_ind(:, 2)+extract_size(2)-1, start_ind(:, 3));
%         x_patches = IMAGES(q1, q2, q3);

% %     % Possible PREPROCESSING
%         if opts.exclude_small_var == 1
%             xp1 = x_patches(:, 1:patch_size(2));
%             xp2 = x_patches(:, (patch_size(2) +1):end);
%             counter_small_var = 0;
%             while ((std(xp1(:)) <= opts.std_min) || (std(xp2(:)) <= opts.std_min)) && counter_small_var<=25
%                 % pick other patches!
%                 start_ind = ceil(rand(1, 3).*[height_im, width_im, num_im]);
%                 x_patches = IMAGES(start_ind(1):start_ind(1)+extract_size(1)-1,...
%                     start_ind(2):start_ind(2)+extract_size(2)-1, start_ind(3));
%                 xp1 = x_patches(:, 1:patch_size(2));
%                 xp2 = x_patches(:, (patch_size(2) +1):end);
%                 counter_small_var = counter_small_var+1;
%             end
%         end

% Assign patches to output variables x
switch alitp
    case 'h'
        x = [ reshape(x_patches(:, 1:patch_size(2)), [], 1); reshape(x_patches(:, (patch_size(2)+1):end), [], 1)];
    case 'v' % I'm assuming patches are arranged vertically
        x = [ reshape(x_patches(1:patch_size(1), :), [], 1); reshape(x_patches((patch_size(1)+1):end, :), [], 1)];
    case 'd_NW_SE'
        x = [ reshape(x_patches(1:patch_size(1), 1:patch_size(2)), [], 1);  reshape(x_patches((patch_size(1)+1):end, (patch_size(2)+1):end), [], 1)];
    case 'd_NE_SW'
        x = [ reshape(x_patches(1:patch_size(1), (patch_size(2)+1):end), [], 1);  reshape(x_patches((patch_size(1)+1):end, 1:patch_size(2)), [], 1)];
end
end % end of function

