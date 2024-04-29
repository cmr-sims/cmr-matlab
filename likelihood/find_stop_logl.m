function vec = find_stop_logl(logl_all)

vec = zeros(size(logl_all,1),1);
the_nans = isnan(logl_all);

for i=1:size(logl_all,1)
  
  % find the first NaN in each row
  first_nan = find(the_nans(i,:), 1);
  % grab the element just before that one
  vec(i) = logl_all(i,first_nan - 1);
  
end

