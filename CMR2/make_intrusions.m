function [intrusions_matrix] = make_intrusions_core(recalls_itemnos_matrix,pres_itemnos_matrix,...
    subjects)
% MAKE_INTRUSIONS makes an intrusions_matrix, formatted to the standard
% intrusions field of a data structure. unlike MAKE_INTRUSIONS, this
% function expects all of the inputs to be given and to be formatted
% correctly.
%
%
% [intrusions_matrix] = make_intrusions(recalls_itemnos_matrix,pres_itemnos_matrix,subjects)
%
% INPUTS:
% recalls_itemnos_matrix:   a matrix whose elements are indices of recalled
%                           items. The rows of this matrix should represent
%                           recalls made by a single subject on a single trial.
%
% pres_itemnos_matrix:      a matrix whose elements are indices of presented
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
% intrusions_matrix: for each trial (row) and output position (column),
% indicates the type of intrusion that was made:
%
%       0: no intrusion
%
%       -1: extra-list intrusion (ELI)
%
%       positive integer: prior-list intrusion (PLI), indicating the number
%       of lists back from which the PLI was recalled
%       NOTE that in the case of items repeated across lists, this integer
%       is the *minimum* possible value.
%       E.g. if an item is repeated on lists 3 and 4, but recalled on list
%       5, it could be called a PLI from 1 lists or 2 lists back. This
%       version of the code always assumes the minimum, so the element in
%       the intrusions_matrix corresponding to this recall is 1.
%
% NOTE:
%    This script assumes:
%       - data matrix is in chronological order within session.
%       - nonrecorded items are marked with a 0.
%   Also, because in most situations we want intrusions_matrix to match
%   element-for-element with the recalls_itemnos_matrix, the exclusion of
%   repeats from the recalls_itemnos_matrix would prevent this from
%   happening, as the code is currently set up. Therefore, no masks should
%   be used here.


% apply_by_index applies intrusions_for_subj on each subjects recall data
% separately
% As with other functions, intrusions_for_subj does most of the work here
intrusions_matrix = apply_by_index_ordered(@intrusions_for_subj, ...
    subjects, ...
    1, ...
    {recalls_itemnos_matrix, pres_itemnos_matrix});

function intrusions_matrix_for_subj = intrusions_for_subj(recitemnos,presitemnos)

% go through each trial, see if there are any intrusions. if so, assign
% accordingly.
intrusions_matrix_for_subj = zeros(size(recitemnos));

for rows = 1:size(recitemnos,1)
    these_recalls = recitemnos(rows,:);
    these_pres = presitemnos(rows,:);
    max_op = find(these_recalls,1,'last');
    % this is a bit counterintuitive, as it implements collect in the
    % opposite way from typical functions. rather than seeing how many of
    % the presented items were recalled, as in spc, this tells us how many
    % of the currently recalled items were presented on the list. if a
    % recalled item was not on the presented list, then its corresponding
    % value in is_current = 0.
    %
    % e.g.
    % these_pres = [5 6 7 8]; these_recalls = [5 7 28];
    % is_current = [1 1 0], so indicating the recall of 28 is an intrusion
    is_current = collect(these_pres,these_recalls(1:max_op));
    is_intrusion = find(~is_current);
    % we only care if is_intrusion is nonempty.
    if ~isempty(is_intrusion)
        % if we're on the first list, the intrusion must be an ELI.
        if isequal(rows,1)
            for intrusion = is_intrusion
                intrusions_matrix_for_subj(rows,intrusion) = -1;
            end

        else
            these_ints = these_recalls(is_intrusion);
            previous_items = presitemnos(1:rows-1,:);
            for int_num = 1:length(is_intrusion)
                this_int = these_ints(int_num);
                this_op = is_intrusion(int_num);
                intrusion_value = intrusions_for_op(this_int,previous_items,rows);
                intrusions_matrix_for_subj(rows,this_op) = min(intrusion_value);
            end

        end
    end

end

function intrusion_value = intrusions_for_op(this_int,previous_items,rows)
%
% first, see if the intrusion matches any previously presented
% items. if so, record the list lag. otherwise, it's an ELI.
[list,op] = find(previous_items==this_int);
if ~isempty(list)
    intrusion_value = rows-list;
else
    intrusion_value = -1;
end
