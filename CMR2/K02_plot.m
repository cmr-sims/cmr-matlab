% K02_plot.m
% Plots figures in the same format as in the CMR2 manuscript: black is
% experimental data; white is the model.

% make a logical matrix the same size as the recalls matrices, true only at
% the positions we want to include in the recall analyses. the function
% called below excludes items with values less than 1 (intrusions),
% repeats, and non-recalled output positions.
rec_mask_exp = make_clean_recalls_mask2d(data.recalls);
rec_mask_cmr2 = make_clean_recalls_mask2d(data.net.recalls);
pres_mask_exp = true(size(data.pres_itemnos));
pres_mask_cmr2 = true(size(data.net.pres_itemnos));

% === SERIAL POSITION CURVE === %
figure
% experimental data
plot(mean(spc(data.recalls,data.subject,data.list_length,rec_mask_exp)),...
    'ok-','MarkerFaceColor','k','MarkerSize',10)
hold on
% CMR2
plot(mean(spc(data.net.recalls,data.net.subject,data.net.list_length,rec_mask_cmr2)),...
    'ok--','MarkerFaceColor','w','MarkerSize',10)
% make the figure look nice
publishFig
axis([0.5 data.list_length+.5 0 1])
xlabel('Serial Position')
ylabel('Probability of Recall')
set(gca,'XTick',1:data.list_length,'YTick',0:.2:1)
box off

% === CONDITIONAL RESPONSE PROBABILITY AS A FUNCTION OF LAG === %
%note due to reasons of shared code etc. this does NOT exclude the first 3
%output positions as shown in the manuscript
lagcrp_exp = mean(crp(data.recalls, data.subject, data.list_length,...
    rec_mask_exp,rec_mask_exp,pres_mask_exp,pres_mask_exp));
lagcrp_cmr2 = mean(crp(data.net.recalls,data.net.subject,data.net.list_length,...
    rec_mask_cmr2,rec_mask_cmr2,pres_mask_cmr2,pres_mask_cmr2));
figure
plot(-5:-1,lagcrp_exp(5:9),'ok-','MarkerFaceColor','k','MarkerSize',10)
hold on
plot(1:5,lagcrp_exp(11:15),'ok-','MarkerFaceColor','k','MarkerSize',10)
plot(-5:-1,lagcrp_cmr2(5:9),'ok--','MarkerFaceColor','w','MarkerSize',10)
plot(1:5,lagcrp_cmr2(11:15),'ok--','MarkerFaceColor','w','MarkerSize',10)
publishFig
axis([-5.5 5.5 0 0.6])
xlabel('Lag')
ylabel('Conditional Response Probability')
set(gca,'XTick',[-5:-1 1:5],'YTick',0:0.1:0.6)
box off

% === PROBABILITY OF FIRST RECALL === %

% adjust recall masks to consider only the first output position.
rec_mask_exp(:,2:end) = false;
rec_mask_cmr2(:,2:end) = false;

figure
plot(mean(spc(data.recalls,data.subject,data.list_length,rec_mask_exp)),...
    'ok-','MarkerFaceColor','k','MarkerSize',10)
hold on
plot(mean(spc(data.net.recalls,data.net.subject,data.net.list_length,rec_mask_cmr2)),...
    'ok--','MarkerFaceColor','w','MarkerSize',10)
publishFig
axis([0.5 data.list_length+.5 0 1])
xlabel('Serial Position')
ylabel('Probability of First Recall')
set(gca,'XTick',1:10,'YTick',0:.2:1)
box off

% === PROPORTION OF PRIOR-LIST INTRUSIONS (PLIs) === %

% we'll only provide the list-lags to the function that calculates the
% proportion of PLIs at each lag, so it's up to the user to mask out
% repeated PLIs. this function masks out negative values (extra-list
% intrusions), repeats, and non-recalled positions.
pli_mask_exp = make_clean_recalls_mask2d(data.rec_itemnos);
figure
plot(1:3,nanmean(pli_recency(data.intrusions,data.subject,3,pli_mask_exp)),...
    'ok-','MarkerFaceColor','k','MarkerSize',10)
hold on
pli_mask_cmr2 = make_clean_recalls_mask2d(data.net.rec_itemnos);
plot(1:3,nanmean(pli_recency(data.net.intrusions,data.net.subject,3,pli_mask_cmr2)),...
    'ok--','MarkerFaceColor','w','MarkerSize',10)
publishFig
axis([0.5 3.5 0 0.6])
set(gca,'XTick',1:3,'YTick',0:.1:.6)
ylabel('Proportion of PLIs')
xlabel('List Recency')
box off