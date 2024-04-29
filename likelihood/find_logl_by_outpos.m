function outL = find_logl_by_outpos(logl_all)


the_nans = isnan(logl_all);
stop_events_onward = zeros(size(logl_all));

for i=1:size(the_nans,1)  
  % find the first NaN in each row
  first_nan = find(the_nans(i,:), 1);
  % the  element just before that one is a stop event
  stop_events_onward(i,first_nan - 1:end) = 1;
end

valid_non_stop = ~stop_events_onward;

max_op = sum(sum(valid_non_stop)>0);

outL = zeros(max_op,1);

for i=1:max_op
  
  n_valid = sum(valid_non_stop(:,i));
  these_logl = logl_all(valid_non_stop(:,i),i);
  
  outL(i) = sum(these_logl)/n_valid;
  
end


