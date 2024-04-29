function sumL = find_logl_after_repint(logl_all, recalls_raw)

vec = [];
%vec = zeros(size(logl_all,1),1);
%the_nans = isnan(logl_all);

% create clean recalls mask
mask = make_clean_recalls_mask2d(recalls_raw);
% make a version where the correct responses are numbered
% sequentially
numbered_mask = zeros(size(mask));
for i=1:size(mask,1)
  
  this_trial = mask(i,:);
  these_event_inds = find(this_trial);
  for j=1:length(these_event_inds)
    numbered_mask(i,these_event_inds(j)) = j;
  end
  
  % which indices follow an invalid recall event?
  this_trial_shift = [1 this_trial(1:end-1)];
  follow_repint = this_trial & ~this_trial_shift;
  valid_following_invalid(i,:) = follow_repint;
  
  % what is the corresponding index in the clean version
  clean_indices = numbered_mask(i,follow_repint);
  vec = [vec logl_all(i,clean_indices)];
  
end

fprintf('Number of valid events following invalid events: %d\n', ...
        sum(valid_following_invalid(:)));
fprintf('Total events: %d\n', sum(mask(:)));
sumL = sum(vec);




