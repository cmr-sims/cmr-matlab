
% need an experiment with both LSA and WAS similarity. Constructing
% this information based on intermediate files available for different
% experiments

% LTP version used only words from the WAS pool

wordpool_ltp = read_wordpool(tfr_ltp_wp_file);

% can't find the pool for the behavioral version (TFR) anywhere; so
% reconstruct from the LSA information and item numbers
load PolyEtal09_data.mat
load LSA_tfr.mat
uitemnos = unique(data.full.pres_itemnos);

wordpool_tfr = W(uitemnos);
tfr_beh_wp_file = '~/matlab/apem_e7_ltp/exp/pools/tfr_wordpool.txt';
write_wordpool(wordpool_tfr, tfr_beh_wp_file);



% stats used to run the experiment; should match up with data
tfr_wp_file = '~/matlab/apem_e7_ltp/exp/pools/wasnorm_wordpool.txt';
tfr_was_file = '~/matlab/apem_e7_ltp/exp/pools/wasnorm_was.txt';
tfr_was_mat = load(tfr_was_file);
tfr_wordpool = read_wordpool(tfr_wp_file);

% stats from the FR database; may have some extra words (wordpool
% may have been modified during data collection)
db_lsa_file = '~/matlab/fr_database/exp_files/taskFR_LTP/lsa.txt';
tfr_lsa_mat = load(db_lsa_file);
db_wp_file = '~/matlab/fr_database/exp_files/taskFR_LTP/wordpool.txt';
db_wordpool = read_wordpool(db_wp_file);

% get the data structure from the fr_database
db_data_file = '~/matlab/fr_database/exp_files/taskFR_LTP/data_original.mat';
data = getfield(load(db_data_file, 'data'), 'data');
cmr_data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data.mat';
save(cmr_data_file, 'data')

% get missing WAS values from the original WAS pool the words were
% chosen from
s_was = load('~/matlab/wordpools/stats/WAS.mat');
tfr_was_mat = pWAS(db_wordpool, s_was.W, s_was.V, false);

% save out the wordpool and complete WAS and LSA information
sem_mat = tfr_lsa_mat;
sem_mat = prep_sem_mat(sem_mat);
save('~/matlab/cmr/fr/TFRLTP/tfrltp_lsa.mat', 'sem_mat')

sem_mat = tfr_was_mat;
sem_mat = prep_sem_mat(sem_mat);
save('~/matlab/cmr/fr/TFRLTP/tfrltp_was.mat', 'sem_mat')

write_wordpool(db_wordpool, '~/matlab/cmr/fr/TFRLTP/tfrltp_wordpool.txt');

% sanity check: make figures like in Manning & Kahana 2012
l = size(tfr_lsa_mat, 1);
tfr_lsa_mat(1:(l+1):end) = 0;
tfr_was_mat(1:(l+1):end) = 0;
tfr_lsa_vec = squareform(tfr_lsa_mat);
tfr_was_vec = squareform(tfr_was_mat);

figure
clf
subplot(1, 3, 1)
hist(tfr_lsa_vec, 500);
set(get(gca, 'child'), 'FaceColor', 'k', 'EdgeColor','k');
set(gca, 'XLim', [-.2 1], 'XTick', -.2:.2:1)
subplot(1, 3, 2)
hist(tfr_was_vec, 500)
set(get(gca, 'child'), 'FaceColor', 'k', 'EdgeColor','k');
set(gca, 'XLim', [-.2 1], 'XTick', -.2:.2:1)
subplot(1, 3, 3)
plot(tfr_lsa_vec, tfr_was_vec, '.k', 'MarkerSize', 2);
set(gca, 'YLim', [-.1 1], 'YTick', 0:.2:1, ...
         'XLim', [-.2 .9], 'XTick', 0:.2:1)

% remove trials that do not have both WAS and LSA
bad_itemnos = union(find_missing_psim(tfr_lsa_mat), ...
                    find_missing_psim(tfr_was_mat));
isbad_trial = any(ismember(data.pres_itemnos, bad_itemnos), 2);

data = rmfield(data, {'subname' 'pres_rate' 'FR_type' 'dist_int', ...
                      'dist_type' 'rec_int' 'ISI' 'ISI_type' ...
                      'hasIntInfo' 'pres_type' 'hasTimeInfo', ...
                      'hasSemInfo' 'rec_type' 'name' 'age' ...
                      'pres_vid' 'pres_aud' 'listLength'});

data = trial_subset(~isbad_trial, data);

% save the trimmed data
cmr_data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data_sem.mat';
save(cmr_data_file, 'data')

% found problems with the FR database version; there may have been
% differences in the wordpools used to annotate different
% sessions. The FR database version doesn't have the item strings,
% so I can't repair it. The version in the data directory on rhino
% looks OK, so using that
data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data.mat';
data = getfield(load(data_file, 'data'), 'data');

% remove trials with missing similarity information
isbad_trial = any(ismember(data.pres_itemnos, bad_itemnos), 2);
data = trial_subset(~isbad_trial, data);
wordpool = read_wordpool('~/matlab/cmr/fr/TFRLTP/tfrltp_wordpool.txt');

% remove subjects that did not finish all sessions
[sess_index, labels] = make_index(data.subject, data.session);
usubject = unique(data.subject);
n_sess = collect([labels{:,1}], usubject);
data = trial_subset(data.subject ~= usubject(n_sess < max(n_sess)), data);

check_frdata(data, wordpool)

% save the trimmed data
cmr_data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data_sem.mat';
save(cmr_data_file, 'data')

% save just control trials
data = trial_subset(data.pres.listtype(:,1) ~= 2, data);
co_data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data_sem_co.mat';
save(co_data_file, 'data')

% save clean recalls version for likelihood fitting
clean_data_file = '~/matlab/cmr/fr/TFRLTP/tfrltp_data_sem_co_clean.mat';
[data.recalls, data.rec_items, data.rec_itemnos, ...
 data.times, data.intrusions] = clean_recalls(data.recalls, ...
    data.rec_items, data.rec_itemnos, data.times, data.intrusions);

% remove fields not used in basic sims
data = rmfield(data, {'subjid' 'pres' 'rec'});

save(clean_data_file, 'data')
