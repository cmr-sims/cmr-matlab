function create_plots(seq, recs, prefix, LL, figpath)
%CREATE_PLOTS   Compare summary plots for model and data.
%
%  create_plots(seq, recs, prefix, LL, figpath)
%
%  INPUTS:
%       seq:  [trials X recalls] matrix of serial positions
%             recalled by the model.
%
%      recs:  [trials X recalls] matrix of serial positions
%             recalled in the actual data.
%
%    prefix:  string to prepend to each figure filename.
%
%        LL:  list length.
%
%   figpath:  directory to save figures.

figure(1); clf;
subplot(1,2,1)
plot_spc(spc(seq,ones(size(seq,1),1),LL));
title('Model');
subplot(1,2,2)
plot_spc(spc(recs,ones(size(seq,1),1),LL));
title('Data');
set(gcf,'Position',[937 836 1009 468]);
print(gcf,'-depsc2',fullfile(figpath,[prefix '_spc']));

figure(2); clf;
subplot(1,2,1)
plot_crp(crp(seq,ones(size(seq,1),1),LL));
title('Model');
subplot(1,2,2)
plot_crp(crp(recs,ones(size(seq,1),1),LL));
title('Data');
set(gcf,'Position',[937 836 1009 468]);
print(gcf,'-depsc2',fullfile(figpath,[prefix '_crp']));

figure(3); clf;
subplot(1,2,1)
plot_spc(pfr(seq,ones(size(seq,1),1),LL));
title('Model');
subplot(1,2,2)
plot_spc(pfr(recs,ones(size(seq,1),1),LL));
title('Data');
set(gcf,'Position',[937 836 1009 468]);
print(gcf,'-depsc2',fullfile(figpath,[prefix '_pfr']));


close all