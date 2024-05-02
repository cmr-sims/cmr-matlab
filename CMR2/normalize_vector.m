function norm_vec = normalize_vector(vec)
%NORMALIZE_VECTOR   Normalize a vector to length 0.
%
%  norm_vec = normalize_vector(vec);

sz = size(vec);

% is it a vector
if or(sum(sz>1) > 1, ...
      length(sz) > 2)
  error('Function requires vector input.');
end

% make it a column vector
if sz(2) > 1
  vec = vec';  
end

% normalize the vector if it is not of length zero
if sum(vec.^2)>0
  norm_vec = vec / sqrt(vec'*vec);
else
  norm_vec = vec;
end

% pass it out the way it came in
if sz(2) > 0
  norm_vec = norm_vec';
end
