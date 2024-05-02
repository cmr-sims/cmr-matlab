function [list_lag_crps,subj_sess_list] = list_lag_crp(pli_list_lags,subject_sessions,excl_0)

% function [list_lag_crps,subj_sess_list] = ...
% list_lag_crp(pli_list_lags,subject_sessions,tl,excl_0)
%
% LIST_LAG_CRPS calculates a lag-CRP, where lag is defined by the list-lag
% between any two successively recalled prior-list intrusions (PLIs).
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
%              tl:  A vector where the value in each row corresponds to the
%                   list-length for total number of trials included in that
%                   session. This "Trial Length" is analogous to the
%                   list-length in the classic lag-CRP, as the maximum
%                   number of trials constrains the maximum and minimum
%                   lag.
%
%          excl_0:  Because transtions of list-lag = 0 dominate the
%                   list-lag-crp, we sometimes found it desirous to exclude
%                   transitions of this lag type from denominators and numerators
%                   in our final calculation. Thus, with excl_0 (EXCLude 0)
%                   set to true, these transitions are excluded. In the
%                   present manuscript, excl_0 was set to false.
%
%  OUTPUTS:
%
%
%   list_lag_crps:  For each included subject/session (row), provides the
%                   conditional response probability at each possible lag (column),
%                   where lags range from (-(max_tl-1):max_tl).
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


% Where were two successive PLIs recalled? Get the list of all possible
% differences using the diff function.
diff_pli = diff(pli_list_lags,1,2);

if excl_0 % If true, don't include the 0 list-lag in our list so that we don't increment denominators.
    [success_pli_rows,success_pli_cols] = find(~isnan(diff_pli)&diff_pli~=0);
else
    [success_pli_rows,success_pli_cols] = find(~isnan(diff_pli));
end

% We only care about the subject sessions in which at least one pair of
% successively recalled prior-list intrusions was recalled, so get the list
% of unique such subject sessions.
subj_sess_list = unique(subject_sessions(success_pli_rows));

% Next, we'll want to get something analogous to the "list-length" for each
% possible subject/session, which in this case is the number of *trials*
% included in the corresponding session. This is important to determine the
% set of possible lags at each transition. These numbers could be calculated
% prior to this function, but it's a bit of a pain and I don't use these
% numbers in any other analysis, so I include it here.
% First, initialize a matrix to hold the number of lists for each
% subject/session. Analogous to the "ll_list" (i.e. the vector of
% list-lengths) used in lag_crp_pli, here we'll call it tl_list for the
% list of Trial lengths.
tl_list = [subj_sess_list zeros(size(subj_sess_list))];
% Then, set the number of lists for each included subject/session.
for i = 1:length(subj_sess_list)
    tl_list(i,2) = length(find(subject_sessions==subj_sess_list(i)));
end

% For each pair of PLIs, figure out:
% 1. What was the lag between them?
% 2. Which transitions were not possible based on list-length?
% 3. Which transitions were not possible based on previous recalls
%    for this trial?
%    (This rarely makes a difference, but nonetheless should be considered)

% Use the maximum trial-length to construct a set of possible lags (the
% largest trial-length will yield the largest possible lag).
max_tl = max(tl_list(:,2));
numerator = zeros(length(subj_sess_list),2*max_tl-1);
denominator = numerator;

for trans = 1:length(success_pli_rows)
    
    % 1. To get the lag, we'll first have to gather some information about
    % this pair
    
    % i) Which trial and output position are we considering?
    tr_no = success_pli_rows(trans);
    op = success_pli_cols(trans);
    
    % ii) For each recalled PLI, what is the effective serial position?
    % I.e. we assume that the first presented list has SP = 1 and the last
    % presented list has maximum list-length
    pli1 = pli_list_lags(tr_no,op);
    pli2 = pli_list_lags(tr_no,op+1);
    
    % iii) Get some information about the subject that we'll use to enter
    % when we have the numerator and denominator.
    % Figure out which subject it is, and what the corresponding
    % row will be in our lag tallies
    subj = subject_sessions(tr_no);
    subj_ind = find(subj_sess_list==subj);
    
    % iv) Using the information from i-iii, where are these trials with
    % respect to all trials for this subject?
    % (Analogous to serial position for regular lag-CRP)
    theselists = find(subject_sessions==subj);
    thislistsp = find(theselists==tr_no);
    sp1 = thislistsp-pli1;
    sp2 = thislistsp-pli2;
    
    if sp1>0 && sp2>0 % They could be less than 0 if it's from a practice trial
        
        % What was the transition made?
        lag = sp2-sp1;
        
        % Which transitions were possible based on "serial position"?
        % Note that 0 is possible, since this simply means we're transitioning
        % within list.
        % Unlike the regular CRP, we don't worry about repeats, as the only way
        % a particular lag wouldn't be possible is if all items from a
        % prior list were recalled -- a rather unlikely scenario.
        posslags = (1-sp1) : (thislistsp-sp1-1);
        
        % Sometimes we'll get a PLI from a practice list. these shouldn't
        % count. Otherwise, tally the numerator and denominator.
        if ismember(lag,posslags)
            
            numerator(subj_ind,lag+max_tl) = numerator(subj_ind,lag+max_tl) + 1;
            denominator(subj_ind,posslags+max_tl) = denominator(subj_ind,posslags+max_tl)+1;
        end
        
    end
    
end  % loop through PLI pairs

% Finally, calculate the lag-CRP.
list_lag_crps = numerator./denominator;