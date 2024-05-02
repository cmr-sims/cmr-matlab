function recalls_target_matrix = make_lbl_fields(recalls_itemnos_matrix,...
    pres_itemnos_matrix,subjects)
% MAKE_LBL_FIELDS makes fields relevant to the list-before-last (lbl)
% paradigm: since subjects are asked not to recall items from the most
% recently presented list, but the list before the last, we're more
% interested in seeing how many items they recalled from 1 list back (the
% target list), rather than items from the current list (the intervening
% list).
%
%
% function recalls_target_matrix = make_recalls_target(recalls_itemnos_matrix,...
%    pres_itemnos_matrix,subjects)
%
% INPUTS:
% recalls_itemnos_matrix:   a matrix whose elements are INDICES of recalled
%                           items. The rows of this matrix should represent
%                           recalls made by a single subject on a single trial.
%
% pres_itemnos_matrix:      a matrix whose elements are INDICES of PRESENTED
%                           items. The rows of this matrix should represent
%                           the index of words shown to subjects during a trial.
%
% subjects:                 a column vector which indexes the rows of
%                           recalls_itemnos_matrix with a subject number
%                           (or other identifier). That is, the recall
%                           trials of subject S should be located in
%                           recalls_itemnos_matrix(find(subjects==S), :)
%
% OUTPUTS:
% recalls_target_matrix: for each trial (row) and output position (column),
% indicates if the item was recalled from the list before last. if so, then
% the item is indexed with a positive integer indicating serial position.
% otherwise, the element is set to 0.
%
% NOTE:
%    This script assumes:
%       - data matrix is in chronological order within session.
%   Also, because in most situations we want recalls_target_matrix to match
%   element-for-element with the recalls_itemnos_matrix, the exclusion of
%   repeats from the recalls_itemnos_matrix would prevent this from
%   happening, as the code is currently set up.


% sanity checks:
if ~exist('recalls_itemnos_matrix', 'var')
    error('You must pass a recalls_itemnos matrix.')
elseif ~exist('pres_itemnos_matrix', 'var')
    error('You must pass a pres_itemnos matrix.')
elseif ~exist('subjects', 'var')
    error('You must pass a subjects vector.')
elseif size(recalls_itemnos_matrix, 1) ~= length(subjects)
    error('recalls_itemnos matrix must have the same number of rows as subjects.')
elseif size(pres_itemnos_matrix, 1) ~= length(subjects)
    error('pres_itemnos matrix must have the same number of rows as subjects.')
end

% apply_by_index applies intrusions_for_subj on each subjects recall data
% separately
% As with other functions, intrusions_for_subj does most of the work here
recalls_target_matrix = apply_by_index_ordered(@recalls_target_for_subj, ...
    subjects, ...
    1, ...
    {recalls_itemnos_matrix, pres_itemnos_matrix});

function recalls_target_matrix_for_subj = recalls_target_for_subj(recitemnos,presitemnos)

% go through each trial, see if there are any intrusions. if so, assign
% accordingly.
recalls_target_matrix_for_subj = zeros(size(recitemnos));

for rows = 2:size(recitemnos,1)
    these_recalls = recitemnos(rows,:);
    these_pres = presitemnos(rows-1,:);
    max_op = find(these_recalls,1,'last');
    for op = 1:max_op
        sp = find(these_recalls(op)==these_pres);
        if ~isempty(sp)
            recalls_target_matrix_for_subj(rows,op) = sp;
        end
    end

end