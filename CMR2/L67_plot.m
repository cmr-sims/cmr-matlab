% L67_PLOT.m
% Plots figures in the same format as in the CMR2 manuscript.

% === RECALL PROBABILITIES === %

% first, determine in each row which items were correctly recalled.
rec_mask_cmr2 = make_clean_recalls_mask2d(data.net.recalls);
% a little code efficiency here.
% - In the innermost parentheses, select out whether we're considering the
% proactive interference (pi) or control (co) lists.
% Then create a column vector where the value of each row corresponds to
% then number of correctly recalled items.
% - Next, divide this column by 3 to get a proportion of recall for
% each row.
% - Next, resize so that each subject is a row, and each column
% corresponds to the trial for that subject. (This more closely
% matches the experimental data we'll use for comparisons.)
% - Lastly, the outermost parentheses takes the mean across
% subjects.
lists_cmr2_pi = mean(reshape(sum(rec_mask_cmr2(data.is_pi,:),2)/3,24,[]),2);
lists_cmr2_co = mean(reshape(sum(rec_mask_cmr2(~data.is_pi,:),2)/3,24,[]),2);

% Combine so that we just have the means of the non-release from PI lists
% and the corresponding lists in the control condition.
recall_cmr2_pi = zeros(16,1);
recall_cmr2_co = recall_cmr2_pi;

for i = 1:8
    recall_cmr2_pi((2*(i-1)+1):(2*i)) = ...
        [lists_cmr2_pi(3*(i-1)+1) mean(lists_cmr2_pi((3*(i-1)+2):(3*i)))];
    
    recall_cmr2_co((2*(i-1)+1):(2*i)) = ...
        [lists_cmr2_co(3*(i-1)+1) mean(lists_cmr2_co((3*(i-1)+2):(3*i)))];
end

% set the x coordinate points based on plotting every 3 release from PI
% lists and every 3 lists with the average of the other 2.
xpoints = sort([1:3:22 2.5:3:23.5]);

figure; hold on
subplot(2,1,1)
plot(xpoints,recall_cmr2_pi,'ok-','MarkerFaceColor','k','MarkerSize',7,'LineWidth',1.2);
axis([0 25 .6 1])
set(gca,'XTick',1:3:24,'YTick',.6:.1:1,'XTickLabel',{''})
box off
subplot(2,1,2)
plot(xpoints,recall_cmr2_co,'ok-','MarkerFaceColor','w','MarkerSize',7,'LineWidth',1.2);
publishFig
axis([0 25 .6 1])
xlabel('Trial')
ylabel('Proportion Recalled')
set(gca,'XTick',1:3:24,'YTick',.6:.1:1)
box off

% Experimental data (approximate)
figure; hold on
subplot(2,1,1)
plot(xpoints,data.plotted_pi,'ok-','MarkerFaceColor','k','MarkerSize',7,'LineWidth',1.2);
axis([0 25 .6 1])
set(gca,'XTick',1:3:24,'YTick',.6:.1:1,'XTickLabel',{''})
box off
subplot(2,1,2)
plot(xpoints,data.plotted_co,'ok-','MarkerFaceColor','w','MarkerSize',7,'LineWidth',1.2);
publishFig
axis([0 25 .6 1])
xlabel('Trial')
ylabel('Proportion Recalled')
set(gca,'XTick',1:3:24,'YTick',.6:.1:1)
box off