function p_rejects = p_reject(rejects_matrix, subjects, rec_mask)

%  P_REJECT  Computes probability of rejecting recalled items.
%
%  p_rejects = p_reject(rejects_matrix, subjects, rec_mask)
%
%  INPUTS:
%  rejects_matrix:  A matrix whose elements indicates whether recalled
%                   items were rejected or accepted as correct items
%                   in externalized free recall (EFR).
%                   The rows of this matrix should represent recalls made
%                   by a single subject on a single trial, and columns
%                   should correspond to output position. An element of the
%                   rejected matrix should be equal to 1 if and only if
%                   that item was rejected.
%
%        subjects:  A column vector which indexes the rows of rejects_matrix
%                   with a subject number (or other identifier).  That is,
%                   the recall trials of subject S should be located in
%                   recalls_matrix(find(subjects==S), :)
%
%        rec_mask:  A logical matrix of the same shape as rejects_matrix,
%                   which is false at positions (i,j) where the value at
%                   rejects_matrix(i,j) should be excluded from the
%                   calculation of the probability of recall.
%                   For instance, if we're only interested in p(reject) of
%                   correct items, then rec_mask should be true only for
%                   correct items (and thus false for intrusions and
%                   repetitions).
%
%
%  OUTPUTS:
%        p_reject:  A vector of probablities. Rows are indexed by the
%                   unique values given in subjects.

p_rejects = apply_by_index(@rejects_for_subj, ...
    subjects, ...
    1, ...
    {rejects_matrix, rec_mask});

function subj_p_rejects = rejects_for_subj(rejects_matrix, rec_mask)
% Helper for p_reject:
% Calculates the probability of rejecting items.

% How many items of interest were recalled in total?
rec_counts = sum(rec_mask(:));

% How many items were rejected?
reject_counts = sum(rejects_matrix(rec_mask)==1);

% Probability of rejection is simply the number rejected divided by the
% total number recalled
subj_p_rejects = reject_counts / rec_counts;