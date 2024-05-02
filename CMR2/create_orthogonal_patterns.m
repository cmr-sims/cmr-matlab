function [env] = create_orthogonal_patterns(n_patterns, pres_indices, ...
					    not_presented_indices)
%CREATE_ORTHOGONAL_PATTERNS   Create a set of orthogonal patterns.
%
%  Creates a set of patterns that can be drawn from to make lists.
%  This function creates LOCALIST, BINARY, ORTHOGONAL patterns
%
%  [env] = create_orthogonal_environment(n_patterns, pres_indices, ...
%	 				not_presented_indices);
%
%  INPUTS:
%
%            n_patterns - How many distinct patterns are required for
%                         each sub-region.  A vector of length
%                         subregions.
%
%          pres_indices - A cell array containing the indices of the
%                         items that will be presented to the
%                         network. If there is an associated
%                         semantic matrix, these indices reference
%                         that matrix, otherwise, each unique item
%                         simply has a unique integer associated
%                         with it. Dimensions are:
%                         {trial}(subregion, serial position)
% 
% not_presented_indices - A cell array.  Each cell contains the
%                         indices of the items that are recallable
%                         by the network but are not ever presented
%                         to the network. 
% 
%  OUTPUTS:
%          env.patterns - A cell array.  Each cell contains a
%                         matrix with dimensions (n_patterns,
%                         n_dimensions in subregion).   
%
%  env.pool_to_item_map - A cell array.  Each cell contains a
%                         matrix with dimensions (n_patterns,
%                         2).  The first column contains the pool
%                         index of each presented item.  
%
%       env.pat_indices - A cell array, the same size as pres_indices,
%                         that contains the indices for each
%                         presented item referenced to the patterns
%                         matrix. Dimensions are
%                         {trial}(subregion, serial position)
%                         env.patterns(env.pat_indices{1}(1,1) would
%                         return the first presented pattern. 

% env.pat_indices indexes the patterns 
env.pat_indices = cell(size(pres_indices));

pres_indices_matrix = [pres_indices{:}];

for subregion = 1:length(n_patterns)
  % for each subregion, get the unique list of patterns, i.e. the
  % orthonormal vectors
  subregion_pres_indices = pres_indices_matrix(subregion,:);
  
  all_unique = unique([subregion_pres_indices(:); ...
                      not_presented_indices{subregion}(:)]);
  n_unique = length(all_unique);

  % environment patterns
  env.patterns{subregion} = eye(n_patterns(subregion));
  
  % get the mapping
  env.pool_to_item_map{subregion}(:,1) = all_unique;
  env.pool_to_item_map{subregion}(:,2) = 1:n_unique;
  
  for trial = 1:size(pres_indices,2)
    trial_pres_indices = pres_indices{trial}(subregion,:);
    
    for item = 1:length(trial_pres_indices)
      env.pat_indices{trial}(subregion,item) = ...
          env.pool_to_item_map{subregion}(find(trial_pres_indices(item)==...
                                               env.pool_to_item_map{subregion}(:,1)),2);

    end
  end
end