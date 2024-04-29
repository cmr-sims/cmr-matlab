function mat_out = fix_semantic_mat(mat_in)
%FIX_SEMANTIC_MAT   Deal with missing semantic similarity values.
%
%  mat_out = fix_semantic_mat(mat_in)
%
%  INPUTS:
%  mat_in:  A semantic similarity matrix.

distrib_mat = mat_in;
mat_out = mat_in;

for i = 1:size(mat_in,1)
  distrib_mat(i,i) = 0;
end

distrib_vec = squareform(distrib_mat);  
distrib_vec(isnan(distrib_vec)) = [];

fix_inds = find(isnan(mat_out));

mat_out(fix_inds) = distrib_vec( ...
    randsample(length(distrib_vec),length(fix_inds),1));
  


