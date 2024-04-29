function y = convert_indices(x, env, convert_to)
%CONVERT_INDICES   Convert indices between pattern and pool types.
%
%  y = convert_indices(x, env, convert_to)
%
%  INPUTS:
%           x:  cell array with one element for each trial. Each
%               cell contains a [subregions X items] matrix of indices.
%
%         env:  environment structure. Needs to have a pool_to_item_map
%               defined.
%
%  convert_to:  either 'pattern' (convert from pool indices to pattern
%               indices) or 'pool' (vice versa).
%
%  OUTPUTS:
%           y:  same format as x, but with the other type of index.

% the output is the same shape, but contains the other type of
% indices
y = x;

% set the columns of the map to grab from
switch convert_to
  case 'pattern'
    from_ind = 1;
    to_ind = 2;
  case 'pool'
    from_ind = 2;
    to_ind = 1;
end
    
n_subregions = length(env.pool_to_item_map);
n_trials = length(x);
for i = 1:n_trials
  % item indices for this trial, a [subregions X items] matrix
  item_indices = x{i};
  n_items = size(item_indices, 2);
  
  for j = 1:n_subregions
    % get the map
    from_map = env.pool_to_item_map{j}(:,from_ind);
    to_map = env.pool_to_item_map{j}(:,to_ind);
    
    for k = 1:n_items
      % find this item index in the map
      map_index = from_map == item_indices(j,k);
      
      % set the converted index
      y{i}(j,k) = to_map(map_index);
    end
  end
end

