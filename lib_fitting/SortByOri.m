function [FIT_PAR, dict_sorted_by_ori] = SortByOri(OPT_PAR_long, D, field_num)
% 25/12/2017

% Let's sort the array by the field "name". First you need to convert to a cell array:
Afields = fieldnames(OPT_PAR_long);
Acell = struct2cell(OPT_PAR_long);
sz = size(Acell);           % Notice that the this is a 3 dimensional array.
                            % For MxN structure array with P fields, the size
                            % of the converted cell array is PxMxN
% Once it's a cell array, you can sort using sortrows:

% Convert to a matrix
Acell = reshape(Acell, sz(1), []);      % Px(MxN)

% Make each field a column
Acell = Acell';                         % (MxN)xP

% Sort by first field "name"
Acell = sortrows(Acell, field_num);

% And convert it back to a structure array:
Acell = reshape(Acell', sz); % Put back into original cell array format
FIT_PAR = cell2struct(Acell, Afields, 1); % Convert to Struct


% Sort by orientation
[~, ori_order] = sort([OPT_PAR_long.orientation]);
dict_sorted_by_ori = D(:, ori_order);

end % end of function