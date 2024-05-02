function [prec_target] = prop_target(rec_targets,tasks,ll,subjects)
%
% [prec_target] = PROP_TARGET(rec_targets,tasks,ll,subjects)
%
%  PROP_TARGET calculates the proportion of target-list items recalled,
%  divided assuming 2 (target list-length) x 2 (intervening list-length) x 
%  2 (between-list task) conditions. 
%
%  INPUTS:
%
%
%
%     rec_targets:  For each trial (row) and output position (column),
%                   a positive integer indicates the serial position of the
%                   target item recalled. Technically this function just
%                   looks at the number of values in rec_targets > 0, so
%                   it could also simply be true at each recalled target
%                   position. Note that it is up to the user to first
%                   exclude any repeats within a given recall period.
%
%        subjects:  A column vector which indexes the rows of rec_targets
%                   with a subject number (or other identifier).  That is, 
%                   the recall trials of subject S should be located in
%                   rec_targets(find(subjects==S), :)
%
%              ll:  A vector where the value in each row corresponds to the
%                   list-length for that trial. Serial positions are
%                   assumed to run from 1:ll.
%
%  OUTPUTS:
%
%
%     prec_target:  An nx8 matrix, were n corresponds to the number of 
%                   subjects, such that each row corresponds to a subject's
%                   proportion of target-list recall.
%                   The 8 columns are organized as follows:
%                   Column | Target LL | Task Between Lists | Intervening LL
%                     1         short         pause              short 
%                     2         long          pause              short 
%                     3         short         pause              long 
%                     4         long          pause              long 
%                     5         short         recall             short 
%                     6         long          recall             short 
%                     7         short         recall             long 
%                     8         long          recall             long 


% set the list lengths.
short = min(ll);
long = max(ll);

% For all the matrices we use, we're only interested in counting recalls for
% trials for which there was recall between lists. So, figure out which
% ones they are, and then select out those rows (trials) from the set of
% recalls and relevant subject/list information.
task_ind = logical(tasks);
rec_targets = rec_targets(task_ind,:);
subjects = subjects(task_ind);

% Divide according to list-length of the intervening list (ll_i), list-length
% of the target list (ll_t), and task between the lists (task_bet, which
% is true only if there was recall in the between-list period prior to the
% currently considered recall period).

% set ll_t, ll_i, task_bet for logical indexing to pull out relevant rows.
ll_t = zeros(size(ll));
ll_t(2:end) = ll(1:end-1);
ll_t = ll_t(task_ind);

ll_i = ll(task_ind);

task_bet = zeros(size(tasks));
task_bet(2:end) = tasks(1:end-1);
task_bet = task_bet(task_ind);

% Calculate target list recalls based on these 3 factors (ll_i, ll_t, task_bet).
% Here, I name each matrix with format *T_@_^I
% where * = target list length (s = short, l = long)
%       @ = task between lists (P = pause, R = recall)
%       ^ = intervening list length (s = short, l = long)
% note that the order of these conditions is chronological, e.g. a subject
% sees the target list, then the task between lists, then the intervening list.
% inputs are as follows:
% - vector of target list-lengths
% - vector of intervening list-lengths
% - vector of tasks between lists
% - vector of subjects
% - scalar of target list-length to consider
% - scalar of intervening list-length to consider
% - scalar of whether to consider trials with pause or recall between
% - matrix of target recalls
sT_P_sI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,short,short,0,rec_targets);
lT_P_sI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,long,short,0,rec_targets);
sT_P_lI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,short,long,0,rec_targets);
lT_P_lI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,long,long,0,rec_targets);
sT_R_sI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,short,short,1,rec_targets);
lT_R_sI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,long,short,1,rec_targets);
sT_R_lI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,short,long,1,rec_targets);
lT_R_lI = calc_proportion_recall(ll_t,ll_i,task_bet,subjects,long,long,1,rec_targets);

% Combine all of these outputs into one vector.
prec_target = [sT_P_sI lT_P_sI sT_P_lI lT_P_lI sT_R_sI lT_R_sI sT_R_lI lT_R_lI];

function prec = calc_proportion_recall(ll_t,ll_i,task_bet,subj,TLL,ILL,have_recall,rec_targets)
% function prec =
% calc_proportion_recall(ll_t,ll_i,task_bet,subj,ILL,TLL,have_recall,targets)

% Find relevant rows that have intervening-list length = ILL and target list-length = TLL,
% and during which there was recall.
rows_to_use = (ll_i==ILL & ll_t==TLL & task_bet==have_recall);

% Select out the rows of subject vector and recall matrix based on the
% criteria.
subject_to_use = subj(rows_to_use);
recalls_target_to_use = rec_targets(rows_to_use,:);

% Initialize the vector of recall probabilities, with one row for each
% subject, based on the subject list.
subjlist = unique(subject_to_use);
nsubj = length(subjlist);
prec = zeros(nsubj,1);

for i = 1:nsubj
    
    % Grab this subject's data
    these_rows = find(subject_to_use == subjlist(i));
    
    % How many lists for this subject?
    nlists = length(these_rows);
    
    % Finally, get the number of actual recalls divided by the number of
    % possible recalls.
    prec(i) = length(find(recalls_target_to_use(these_rows,:)))/(nlists*TLL);
    
end