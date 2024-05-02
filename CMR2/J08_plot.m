% J08_PLOT.M
% Plots figures in the same format as in the CMR2 manuscript.
% For efficiency, this is set up for the specifics of Jang & Huber 2008,
% Experiment 1.

% === TARGET LIST RECALLS === %

% get the means and SEMs for the experimental data.
prop_target_exp = prop_target(data.recalls_target,data.task,data.list_length,data.subject);
mean_target_exp = mean(prop_target_exp,1);
sem_target_exp = std(mean_target_exp,0,1)/sqrt(size(mean_target_exp,1)-1);

% get the means for the simulated data.
mean_target_cmr2 = mean(prop_target(data.net.recalls_target,data.net.task,...
    data.net.list_length,data.net.subject));

figure
bar([1 4],mean_target_exp([4 3]),'k','BarWidth',.25)
hold on
bar([2 5],mean_target_exp([2 1]),'w','BarWidth',.25)
errorbar([1 4 2 5],mean_target_exp([4 3 2 1]),sem_target_exp([4 3 2 1]),'k.','MarkerSize',.1)
set(gca,'XTick',[1.5 4.5],'XTickLabel',{'Long','Short'},'YTick',0:.1:.4,...
    'YTickLabel',{'0.0','0.1','0.2','0.3','0.4'})
ylabel('Proportion of Recall')
publishFig;
title('Target, No Recall b/t Lists, Exp')
xlabel('Target List Length')
ylim([0 0.45])
legend('Long Intervening','Short Intervening','Location','Northwest')

figure
bar([1 4],mean_target_cmr2([4 3]),'k','BarWidth',.25)
hold on
bar([2 5],mean_target_cmr2([2 1]),'w','BarWidth',.25)
set(gca,'XTick',[1.5 4.5],'XTickLabel',{'Long','Short'},'YTick',0:.1:.4,...
    'YTickLabel',{'0.0','0.1','0.2','0.3','0.4'})
ylabel('Proportion of Recall')
publishFig;
title('Target, No Recall b/t Lists, CMR2')
xlabel('Target List Length')
ylim([0 0.45])

figure
bar([1 4],mean_target_exp([8 7]),'k','BarWidth',.25)
hold on
bar([2 5],mean_target_exp([6 5]),'w','BarWidth',.25)
%if nargin > 2
    errorbar([1 4 2 5],mean_target_exp([8 7 6 5]),sem_target_exp([8 7 6 5]),'k.','MarkerSize',.1)
%end
set(gca,'XTick',[1.5 4.5],'XTickLabel',{'Long','Short'},'YTick',0:.1:.4,...
    'YTickLabel',{'0.0','0.1','0.2','0.3','0.4'})
ylabel('Proportion of Recall')
publishFig;
title('Target, Recall b/t Lists, Exp')
xlabel('Target List Length')
ylim([0 0.45])

figure
bar([1 4],mean_target_cmr2([8 7]),'k','BarWidth',.25)
hold on
bar([2 5],mean_target_cmr2([6 5]),'w','BarWidth',.25)
set(gca,'XTick',[1.5 4.5],'XTickLabel',{'Long','Short'},'YTick',0:.1:.4,...
    'YTickLabel',{'0.0','0.1','0.2','0.3','0.4'})
ylabel('Proportion of Recall')
publishFig;
title('Target, Recall b/t Lists, CMR2')
xlabel('Target List Length')
ylim([0 0.45])

% === INTERVENING LIST RECALLS === %

% get the means and SEMs for the experimental data.
prop_interv_exp = prop_interv(data.recalls_interv,data.task,data.list_length,data.subject);
mean_interv_exp = mean(prop_interv_exp,1);
sem_interv_exp = std(mean_interv_exp,0,1)/sqrt(size(mean_interv_exp,1)-1);

% get the means for the simulated data.
mean_interv_cmr2 = mean(prop_interv(data.net.recalls_interv,data.net.task,...
    data.net.list_length,data.net.subject));

figure
bar([1 3],mean_interv_exp,'k','BarWidth',.25)
set(gca,'XTick',[1 3],'XTickLabel',{'Pause','Recall'},'YTick',0:.01:.04,...
    'YTickLabel',{'0.00','0.01','0.02','0.03','0.04'})
hold on
errorbar([1 3],mean_interv_exp,sem_interv_exp,'k.','MarkerSize',.1)
ylim([0 0.045])
publishFig
xlabel('Task Between Lists')
ylabel('Proportion of Recall')
title('Intervening, Exp')

figure
bar([1 3],mean_interv_cmr2,'k','BarWidth',.25)
set(gca,'XTick',[1 3],'XTickLabel',{'Pause','Recall'},'YTick',0:.01:.04,...
    'YTickLabel',{'0.00','0.01','0.02','0.03','0.04'})
ylim([0 0.045])
publishFig
hold on
xlabel('Task Between Lists')
ylabel('Proportion of Recall')
title('Intervening, CMR2')