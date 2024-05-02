function [plis] = prop_pli(pli_list_lags,subjects,nliststoexclude,mask)
%
% [plis] = PROP_PLI(pli_list_lags,subjects,nliststoexclude,mask)
%
% PROP_PLI calculates the proportion of prior list intrusions (PLIs) made 
% by each subject per trial
%
%
%   pli_list_lags:  For each trial (row) and output position (column),
%                   a positive integer indicates the number of lists back
%                   from which the PLI was recalled. If no PLI was recalled
%                   at this output position, or if the PLI is repeated from
%                   earlier in the recall period, a NaN should be in this
%                   position instead, to indicate that the item is excluded
%                   from this analysis. Technically this function just
%                   counts the number of times pli_list_lags is greater
%                   than 0, so this matrix could simply be true at any
%                   element for which a (non-repeated) PLI was recalled.
%
%        subjects:  A column vector which indexes the rows of rec_targets
%                   with a subject number (or other identifier).  That is, 
%                   the recall trials of subject S should be located in
%                   rec_targets(find(subjects==S),:)
%
% nliststoexclude:  How many of the first lists to exclude per subject
%                   (because subjects can't make intrusions on the first list,
%                   this would weigh PLIs from list 1 too heavily, etc.).
%                   This is particularly useful if say, we're also
%                   interested in the proportion of PLIs from 1,2,3 lists
%                   back. In that case, we would exclude the first 3 lists,
%                   so it would be best to also exclude those same lists
%                   when considering the proportion of PLIs, for consistent
%                   comparisons.
%
%         OUTPUTS:
% 
%            plis: A vector with the number of PLIs recalled per trial with 
%                  each row corresponding to a unique value in subjects.

% apply_by_index applies pli_for_subj separately for each subject's data,
% so pli_for_subj does most of the work here
plis = apply_by_index_ordered(@pli_for_subj, ...
		      subjects, ...
		      1, ...
                     {pli_list_lags, mask},nliststoexclude); 

function prop_pli = pli_for_subj(pli_list_lags,mask,nliststoexclude)

% Exclude the lists we don't want.
mask(1:nliststoexclude,:)=false;

% Count the number of prior list intrusions made by a given subject and
% divide by the total number of possible lists.
prop_pli = sum(pli_list_lags(mask)>0)/(size(pli_list_lags,1)-nliststoexclude);