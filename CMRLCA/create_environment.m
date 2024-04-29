function env = create_environment(param)
% CREATE_ENVIRONMENT  Creates the environment structure that
% patterns are plugged into.  This allows one to map from the
% indices of presented items to the particular patterns used to
% represent those items.
% 
% INPUTS:
% 
%  param.subregions - integer - how many subregions are you making
%  patterns for.
%
%  param.n_patterns - how many distinct patterns are required for
%  each subregion.  A vector of length subregions.
%
%  param.pres_indices - a cell array containing the indices of the
%  items that will be presented to the network.  Dimensions are
%  {trial}(subregion, serial position)
%
%  param.not_presented_indices - A cell array, one cell for each
%  subregion. Each cell contains the indices of the items that are
%  recallable by the network but are not ever presented to the
%  network. 
%
%  param.pattern_creation_fn - a cell array of function handles,
%  one for each subregion.
%
%  param.pattern_creation_args - a cell array of input arguments
%  for the pattern creation functions.
%
% OUTPUTS:
%
%  env.patterns - A cell array, one cell for each subregion.  Each
%  cell contains a matrix with dimensions (n_patterns, n_dims).
%
%  env.pool_to_item_map - A cell array, one cell for each
%  subregion.  Each cell contains a matrix with dimensions
%  (n_patterns, 2).  The first column contains the pool index of
%  each presented item.  The second column ------
%
%  env.pat_indices - A cell array, size of pres_indices, containing
%  the indices of each presented item referenced to the patterns
%  matrix.  {trial}(subregion, serial position)
%
% EXAMPLE:
%

% env.pat_indices indexes the patterns 
env.pat_indices = cell(size(param.pres_indices));

pres_indices_matrix = [param.pres_indices{:}];

for subregion = 1:param.subregions
    
    subregion_pres_indices = pres_indices_matrix(subregion,:);
    
    all_unique = unique([subregion_pres_indices(:); ...
        param.not_presented_indices{subregion}(:)]);
    n_unique = length(all_unique);

    % create a pattern for each unique item index 
    env.patterns{subregion} = param.pattern_creation_fn{subregion}( ...
        param.pattern_creation_args{subregion}{:});
    
    % environment patterns
    %env.patterns{subregion} = eye(n_patterns(subregion));
    env.pool_to_item_map{subregion}(:,1) = all_unique;
    env.pool_to_item_map{subregion}(:,2) = 1:n_unique;

    % now create a map between the schedule of item presentation
    % and the pattern matrix created above.
    for trial = 1:size(param.pres_indices,2)

        trial_pres_indices = param.pres_indices{trial}(subregion,:);
        
        for item = 1:length(trial_pres_indices)
            
            env.pat_indices{trial}(subregion,item) = ...
               env.pool_to_item_map{subregion}(find(trial_pres_indices(item)==...
               env.pool_to_item_map{subregion}(:,1)),2);

        end
    end

end




