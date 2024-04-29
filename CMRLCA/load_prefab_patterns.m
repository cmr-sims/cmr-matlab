function patterns = load_prefab_patterns(filename, pat_inds, n_patterns)
% patterns = create_distributed_patterns(filename, pat_inds, n_patterns)
%
% Creates a set of patterns that can be drawn from to make lists,
% called by create_environment.
%
% This function loads a subset of prefabricated patterns
%
%  INPUTS:
%
%            n_patterns - How many distinct patterns are required.
%
%  OUTPUTS:
%
%          patterns - A matrix. 
%
%


mat = getfield(load(filename),'mat');

% grab a subset of patterns
patterns = mat(pat_inds, :);

% if n_patterns is more than pat_inds, then we need some
% distraction patterns.
extras_needed = n_patterns - size(patterns,1);

if extras_needed > 0
  
  for i=1:extras_needed
    extras(i,:) = normalize_vector(randn(1,size(patterns,2)));
  end
  % concatenate
  patterns = [patterns; extras];
  
end
