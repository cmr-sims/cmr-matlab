% L13_PLOT(data_efr,data_ifr)
% Plots figures in the same format as in the CMR2 manuscript: squares are
% efr; triangles are ifr. This function can also be used to just plot one
% or the other. The data structure not given should be specified as empty,
% e.g. to only plot the ifr data:
% L13_plot([],data_ifr)
 
function L13_plot(data_efr,data_ifr)

if ~isempty(data_efr)
    plot_sp_info(data_efr,{'sk-','MarkerFaceColor','k','MarkerEdgeColor','none'});
    make_rec_rej_table(data_efr);
end
if ~isempty(data_ifr)
    % fill these in so that we can apply the same function to efr and ifr
    data_ifr.rejected = false(size(data_ifr.rec_itemnos));
    data_ifr.net.rejected = false(size(data_ifr.net.rec_itemnos));
    plot_sp_info(data_ifr,{'^k--','MarkerFaceColor',[.5 .5 .5],'MarkerEdgeColor','none'});
end

function plot_sp_info(data,marker_info)
% make a logical matrix the same size as the recalls matrices, true only at
% the positions we want to include in the recall analyses. the function
% called below excludes items with values less than 1 (intrusions),
% repeats, and non-recalled output positions.
rec_mask_exp = make_clean_recalls_mask2d(data.recalls) & data.rejected~=1;
rec_mask_cmr2 = make_clean_recalls_mask2d(data.net.recalls) & data.net.rejected~=1;

% === SERIAL POSITION CURVE === %
figure(1); hold on
% experimental data
plot(mean(spc(data.recalls,data.subject,data.list_length,rec_mask_exp)),...
    marker_info{:},'MarkerSize',10)
% make the figure look nice

axis([0.5 data.list_length+.5 0 1])
ylabel('Probability of Recall')
set(gca,'XTick',2:2:data.list_length,'XTickLabel','','YTick',0:.2:1)
box on

% CMR2
figure(2); hold on
plot(mean(spc(data.net.recalls,data.net.subject,data.net.list_length,rec_mask_cmr2)),...
    marker_info{:},'MarkerSize',10)

axis([0.5 data.list_length+.5 0 1])
set(gca,'XTick',2:2:data.list_length,'XTickLabel','','YTick',0:.2:1,'YTickLabel','')
box on

% === PROBABILITY OF FIRST RECALL === %

% adjust recall masks to consider only the first output position.
rec_mask_exp(:,2:end) = false;
rec_mask_cmr2(:,2:end) = false;

figure(3); hold on
plot(mean(spc(data.recalls,data.subject,data.list_length,rec_mask_exp)),...
    marker_info{:},'MarkerSize',10)

axis([0.5 data.list_length+.5 0 1])
xlabel('Serial Position')
ylabel('Probability of First Recall')
set(gca,'XTick',2:2:data.list_length,'YTick',0:.2:1)
box on

figure(4); hold on
plot(mean(spc(data.net.recalls,data.net.subject,data.net.list_length,rec_mask_cmr2)),...
    marker_info{:},'MarkerSize',10)

axis([0.5 data.list_length+.5 0 1])
set(gca,'XTick',2:2:data.list_length,'YTick',0:.2:1,'YTickLabel','')
box on

function make_rec_rej_table(data)

% === REJECTION PROBABILITIES === %

% Because the denominator changes with each session, we need to calculate
% each rejection probability by session and then take the mean across
% sessions. One way to do this is to give each subject/session combination
% a unique identifier for the analysis, and then combine across all
% possible sessions for a given subject.

subj_sess_exp = data.subject + .01*data.session; % list of subjects and sessions
subj_list_exp = floor(unique(subj_sess_exp)); % list of subjects, 1 per session

subj_sess_cmr2 = data.net.subject+.01*data.net.session;
subj_list_cmr2 = floor(unique(subj_sess_cmr2));

% Correct items

% make a logical matrix the same size as the recalls matrices, true only at
% the positions we want to include in the recall analyses. the function
% called below excludes items with values less than 1 (intrusions),
% repeats, and non-recalled output positions.
rec_mask_exp = make_clean_recalls_mask2d(data.recalls);
rec_mask_cmr2 = make_clean_recalls_mask2d(data.net.recalls);

prej_sess_cor_exp = p_reject(data.rejected, subj_sess_exp, rec_mask_exp);
prej_cor_exp = nanmean(subj_means_across_sessions(prej_sess_cor_exp,subj_list_exp));

prej_sess_cor_cmr2 = p_reject(data.net.rejected, subj_sess_cmr2, rec_mask_cmr2);
prej_cor_cmr2 = nanmean(subj_means_across_sessions(prej_sess_cor_cmr2,subj_list_cmr2));

% PLIs

% we'll only provide the list-lags to the function that calculates the
% proportion of PLIs at each lag, so it's up to the user to mask out
% repeated PLIs. this function masks out negative values (extra-list
% intrusions), repeats, and non-recalled positions.
pli_mask_exp = make_clean_recalls_mask2d(data.rec_itemnos) & data.intrusions>0;
pli_mask_cmr2 =  make_clean_recalls_mask2d(data.net.rec_itemnos)  & data.net.intrusions>0;

prej_sess_pli_exp = p_reject(data.rejected, subj_sess_exp, pli_mask_exp);
prej_pli_exp = nanmean(subj_means_across_sessions(prej_sess_pli_exp,subj_list_exp));

prej_sess_pli_cmr2 = p_reject(data.net.rejected, subj_sess_cmr2, pli_mask_cmr2);
prej_pli_cmr2 = nanmean(subj_means_across_sessions(prej_sess_pli_cmr2,subj_list_cmr2));

% === RECALL PER LIST === %

% Correct items
prec_cor_exp = mean(p_rec(data.recalls,data.subject,data.list_length,rec_mask_exp));
prec_cor_cmr2 = mean(p_rec(data.net.recalls,data.net.subject,...
    data.net.list_length,rec_mask_cmr2));

% Prior-list intrusions (PLIs)

% we'll only provide the list-lags to the function that calculates the
% proportion of PLIs at each lag, so it's up to the user to mask out
% repeated PLIs. this function masks out negative values (extra-list
% intrusions), repeats, and non-recalled positions.

pli_mask_exp = make_clean_recalls_mask2d(data.rec_itemnos) & data.intrusions>0;
prec_sess_pli_exp = prop_pli(data.intrusions,subj_sess_exp,0,pli_mask_exp);
prec_pli_exp = nanmean(subj_means_across_sessions(prec_sess_pli_exp,subj_list_exp));

pli_mask_cmr2 =  make_clean_recalls_mask2d(data.net.rec_itemnos)  & data.net.intrusions>0;
prec_sess_pli_cmr2 = prop_pli(data.net.intrusions,subj_sess_cmr2,0,pli_mask_cmr2);
prec_pli_cmr2 = nanmean(subj_means_across_sessions(prec_sess_pli_cmr2,subj_list_cmr2));

fprintf('P(recall)    correct: %1.1f (data), %1.1f (model) \n',prec_cor_exp,prec_cor_cmr2);
fprintf('P(recall)        PLI: %1.2f (data), %1.2f (model) \n',prec_pli_exp,prec_pli_cmr2);
fprintf('P(reject)    correct: %1.2f (data), %1.2f (model) \n',prej_cor_exp,prej_cor_cmr2);
fprintf('P(reject)        PLI: %1.2f (data), %1.2f (model) \n',prej_pli_exp,prej_pli_cmr2);
