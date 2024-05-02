function [proportion_plis] = pli_recency(intrusions_matrix, subjects, max_lag, mask)
%PLI_RECENCY_CORE   Prior-list intrusions by list recency.
%
%  Computes proportion of prior-list intrusions (PLIs) as
%  a function of list lag, or list recency.
%  Unlike PLI_RECENCY, this function does not have any error-checking.
%  It assumes all of the inputs listed below are given and formatted
%  correctly.
%  
%  [proportion_plis] = pli_recency(intrusions_matrix, subjects, max_lag, mask)
%
%  INPUTS: 
%  intrusions_matrix:   A matrix whose elements are nonzero only for items
%                       recalled as intrusions. For such elements, a
%                       positive integer indicates the number of lists back
%                       from which this intrusion occured.
%                       The rows of this matrix should represent recalls
%                       made by a single subject on a single trial.
%
%        subjects:      a column vector which indexes the rows of recalls_matrix
%                       with a subject number (or other identifier).  That is, 
%                       the recall trials of subject S should be located in
%                       recalls_matrix(find(subjects==S), :)
%         
%         max_lag:      a scalar indicating the maximum number of lists back from
%                       which to determine PLIs. I.e., if we are interested
%                       in determining the number of PLIs from 1,2,..,n lists
%                       back,then max_lag = n. Note that this value has
%                       implications for the analysis as well: for
%                       max_lag=n, we only consider lists n+1 through the
%                       end of the session. For any lists occuring earlier
%                       than this, there would be more opportunities to
%                       make PLIs from smaller list lags than larger ones.
%
%            mask:      a logical matrix of the same shape as 
%                       recalls_matrix, which is false at positions (i, j) where
%                       the value at intrusions_matrix(i, j) should be excluded from
%                       the calculation of the probability of recall.
%                       note that, unlike other functions, the mask MUST be
%                       given. repeats cannot be determined solely by
%                       looking at the intrusions_matrix alone. to make a
%                       mask that excludes repeated items, use 
%                       make_mask_exclude_repeats1d.m, but pass through the
%                       recalled item numbers rather than serial positions
%                       (for the standard data structure, data.rec_itemnos
%                       rather than data.recalls)
% 
%  OUTPUTS:
%  proportion_plis:     a matrix indicating the proportion of all plis made from
%                       a particular list lag.  Its columns are indexed by
%                       list lag and its rows are indexed by subject.
%
%  EXAMPLES:
%  >> intrusions = [0 0 0 0 0 0; ...
%                   0 0 0 0 0 0; ...
%                   0 1 0 0 0 0; ...
%                   0 0 0 0 1 0; ...
%                   0 0 0 0 0 2];  
%  >> subjects = ones(6,1); list_length = 6; max_lag = 2;
%  >> % use a standard mask:
%  >> pli_recency = spc(intrusions, subjects, list_length,max_lag)
%  pli_recency = 
%               .67 .33
%

% pli_for_subj does all the real work here
proportion_plis = apply_by_index(@pli_for_subj, ...
                           subjects, ...
			   1, ...
                           {intrusions_matrix, mask}, ...
                           max_lag);
%endfunction

function subj_pli = pli_for_subj(intrusions, mask, max_lag)
  % Helper for pli: 
  % calculates the proportion of plis as a function of lag, per subject;
  % returns a vector of proportions, indexed by list lag
  
  % the mask should also exclude trials up to max_lag number of lists.
  % otherwise, there are more opportunities to make PLIs from smaller list
  % lags.
  mask(1:max_lag,:)=false;
  
  % appears after masking out unwanted ones...so it doesn't matter that
  % this ravels recalls.
  masked_intrusions = intrusions(mask);
  

  % intrusion counts: the number of PLIs in total, to use as a denominator
  % for proportions.  Here, we are relying type casting from true -> 1...
  % We are also assuming that PLIs are indexed with positive integers. In
  % some paradigms, extra-list intrusions (XLIs) are indexed with -1, so
  % only consider positive integers here.
  pli_counts = sum(masked_intrusions>0, 1);
  
  lag_counts = collect(masked_intrusions, 1:max_lag);

  subj_pli = lag_counts ./ pli_counts;
%endfunction
