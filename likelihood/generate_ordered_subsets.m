function all_seq = generate_ordered_subsets(LL)
% GENERATE_ORDERED_SUBSETS
%
% LL = 5;
%
% all_seq = generate_ordered_subsets(LL);
%
% Note: current implementation is inefficient, first creates full
% set of all possible permutations including stop position, and
% then finds all sequences that are unique prior to the stop
% position. 
%
% It would be more efficient (I think) to loop from 1:LL and for each
% sequence length generate all ordered subsequences.  It will still
% blow up, but not quite as fast as the current version.  I don't have
% matlab code to generate ordered subsequences yet.


% generate sequences
all_perms = perms(1:LL+1);
for i=1:size(all_perms,1)
  all_perms(i,find(all_perms(i,:)==(LL+1)):end) = 0;
end

% get it to be all subsequences
% collapse identical rows
all_seq = unique(all_perms,'rows');



