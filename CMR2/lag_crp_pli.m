function [lag_crps,subj_sess_list] = ...
    lag_crp_pli(pli_list_lags,rec_itemnos,pres_itemnos,subject_sessions,ll)
% function [lag_crps,subj_sess_list] = ...
% lag_crp_pli(pli_list_lags,rec_itemnos,pres_itemnos,subject_sessions,ll)
%
% LAG_CRP_PLI calculates the lag-CRP only between prior list pli_list_lags
% (PLIs) that were recalled successively and from the same list.
%
%  INPUTS:
%
%
%   pli_list_lags:  For each trial (row) and output position (column),
%                   a positive integer indicates the number of lists back
%                   from which the PLI was recalled. If no PLI was recalled
%                   at this output position, or if the PLI is repeated from
%                   earlier in the recall period, a NaN should be in this
%                   position instead, to indicate that the item is excluded
%                   from this analysis.
%    
%     rec_itemnos:  Matrix whose elements are indices of recalled
%                   items. The rows of this matrix should represent
%                   recalls made by a single subject on a single trial.
%                   Elements corresponding to output positions in which no
%                   item was recalled should be set to 0.
%
%    pres_itemnos:  Matrix whose elements are indices of presented
%                   items. The rows of this matrix should represent the
%                   index of words shown to subjects during a trial.
%
%subject_sessions:  Column vector which indexes the rows of
%                   recall_itemnos with a unique subject/session identifier.
%                   That is, the recall trials of subject, session S
%                   should be located in:
%                   recall_itemnos(find(subject_sessions==S), :)
%                   Here, we assume that the unique list of subject_sessions
%                   corresponds to the list of possible subjects and sessions,
%                   i.e. we treat separately the prior-list intrusions 
%                   that occur within each unique subject_sessions number.
%                   For instance, if rec_itemnos is from subjects 400 and
%                   500, each of which performed two sessions, then one way
%                   to index the unique list of subject sessions would be
%                   by having the hundreds digit indicate the subject and
%                   the units digit indicate the session, as in 401, 402,
%                   501, 502. It would not work to have only the subject
%                   number or only the session number, as either of these
%                   would treat distinct experimental sessions as if they
%                   were the same session.
%
%              ll:  A vector where the value in each row corresponds to the
%                   list-length for that trial. Serial positions are
%                   assumed to run from 1:ll.
%
%  OUTPUTS:
%
%
%        lag_crps:  For each included subject/session (row), provides the
%                   conditional response probability at each possible lag
%                   (column), where lags range from (-(max_ll-1):max_ll).
%
%  subj_sess_list:  A list of the unique subject/session indices, provided
%                   subject_sessions, for those subject/sessions that were
%                   included in the analysis. This is important if not all
%                   sessions are included. For instance, suppose only 5 out
%                   of 8 subject/sessions include a transition between
%                   successively recalled PLIs from the same list. Then
%                   lag_crps will be a 5 row matrix, but for which of the 8
%                   possible subject/sessions? Having this second output
%                   resolves that ambiguity, and is particularly important
%                   if some of the included sessions come from the same
%                   subjects.

% Where were two successive PLIs from the same list recalled? Do this by
% taking the difference in PLI values between all successively recalled
% PLIs, and then find where they equal 0.
[success_pli_rows,success_pli_cols] = find(diff(pli_list_lags,1,2)==0);

% We only care about the subject sessions in which at least one pair of 
% successively recalled prior-list intrusions was recalled, so get the list
% of unique such subject sessions.
subj_sess_list = unique(subject_sessions(success_pli_rows));

% For each pair of PLIs, figure out:
% 1. What was the lag between them?
% 2. Which transitions were not possible based on list-length?
% 3. Which transitions were not possible based on previous recalls
%    for this trial?
%    (This rarely makes a difference, but nonetheless should be considered)

% First, get the list of all possible list-lengths.
ll_list = ll(success_pli_rows);

% Use the maximum list-length to construct a set of possible lags (the
% largest list-length will yield the largest possible lag).
max_ll = max(ll_list);
numerator = zeros(length(subj_sess_list),2*max_ll-1);
denominator = numerator;

for trans = 1:length(success_pli_rows)
    
    % NUMERATOR %
    
    % 1. To get the lag, we'll first have to gather some
    % information about this pair
    
    % i) Which trial and output position are we considering?
    tr_no = success_pli_rows(trans);
    op = success_pli_cols(trans);
    
    % ii) Which items were recalled this trial?
    recall_trial = rec_itemnos(tr_no,:);
    
    % iii) How many lists back were the original items recalled?
    list_lag = pli_list_lags(tr_no,op);
    
    % iv) When were the items originally presented?
    pres_trial = pres_itemnos(tr_no-list_lag,:);
    
    % v) Using the information from i-iv, we can now construct for each PLI,
    % we can now determine the original serial positions were.
    pli1 = recall_trial(op);
    pli2 = recall_trial(op+1);
    sp1 = find(pres_trial==pli1);
    sp2 = find(pres_trial==pli2);
    
    % vi) Finally, what was the transition made?
    lag = sp2-sp1;
    
    % vii) Add to the numerator based on the subject.
    % Figure out which subject it is, and what the corresponding
    % row will be in our lag tallies.
    subj = subject_sessions(tr_no);
    subj_ind = find(subj_sess_list==subj);
    
    numerator(subj_ind,lag+max_ll) = numerator(subj_ind,lag+max_ll) + 1;
    
    % DENOMINATOR %
    
    % 2. Which transitions were possible based on serial position?
    negativelags = (1-sp1) : -1;
    positivelags = 1 : (ll_list(trans)-sp1);
    totalposslags = [negativelags positivelags];
    
    % 3. Were any other items recalled from pres_trial on this list? if so,
    % we should eliminate them as possible items that could have been
    % recalled
    if any(pli_list_lags(tr_no,1:op-1)==list_lag)
        % Figure out which lags aren't possible.
        prev_recalls = recall_trial(pli_list_lags(tr_no,1:op-1)==list_lag);
        prev_recalls_sp = find(ismember(pres_trial,prev_recalls));
        impossiblelags = prev_recalls_sp - sp1;
        posslags = setdiff(totalposslags, impossiblelags);
        
    else
        posslags = totalposslags;
    end
    
    % Add the possible lags to the count.
    denominator(subj_ind,posslags+max_ll) = denominator(subj_ind,posslags+max_ll)+1;
    
end % loop through PLI pairs

% Finally, calculate the lag-CRP.
lag_crps = numerator./denominator;