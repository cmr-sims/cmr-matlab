function publishFig
%PUBLISHFIG - Prepared figure for publication.
% 
% Prepares a figure for publication or presentation by making all
% the fonts larger.  The default is to work on the current figure
% and to clear the title away.
  
% set the tics on all children
h = get(gcf,'Children');
for j=1:length(h)
  set(h(j),'FontSize',21)
end

% set the title and labels
h = get(get(gcf,'Children'),'Title');
if length(h) > 1 
  for j=1:length(h)
    set(h{j},'FontSize',21);
  end
else
  set(h,'FontSize',21);
end

% remove the title
title('');

% set the xlabel
h = get(get(gcf,'Children'),'xlabel');
if length(h) > 1 
  for j=1:length(h)
    set(h{j},'FontSize',21);
  end
else
  set(h,'FontSize',21);
end

% set the ylabel
h = get(get(gcf,'Children'),'ylabel');
if length(h) > 1 
  for j=1:length(h)
    set(h{j},'FontSize',21);
  end
else
  set(h,'FontSize',21);
end

% redo the legend
%legend