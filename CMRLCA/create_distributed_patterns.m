function patterns = create_distributed_patterns(n_patterns, n_dimensions)
%CREATE_DISTRIBUTED_PATTERNS   Create distributed, continuous patterns.
%
%  Creates a set of patterns that can be drawn from to make lists;
%  called by create_environment.
%
%  patterns = create_distributed_patterns(n_patterns, n_dimensions)
%
%  INPUTS:
%    n_patterns - How many distinct patterns are required.
%
%  n_dimensions - How many elements in each pattern
% 
%  OUTPUTS:
%      patterns - A matrix. 

% environment patterns

% n_patterns, n_dimensions

for i = 1:n_patterns
  patterns(i,:) = normalize_vector(randn(1, n_dimensions));
end  


