function [logl, logl_all, p] = tcm_recency(param, data)
%TCM_RECENCY   Simulate probability of first recall using TCM.
%
%  [logl, logl_all, p] = tcm_recency(param, data)

% remove trials with no recalls
data = trial_subset(data.recalls(:,1) ~= 0, data);

% initialize
[N, S] = size_frdata(data);
logl = NaN(N, 1);
logl_all = NaN(N, S);

% unpack options/data to match BUGS script
B = param.B_enc;
C = param.C;
T = 1;
P1 = param.P1;
%P2 = param.P2;
P2 = 10;
f = eye(S+1);
r = data.recalls(:,1);

rho = sqrt(1 - B^2);

% Below is a version designed to resemble the BUGS version
%c = zeros(1, S+1);
%c(end) = 1;
% calculate each state of context
%for i = 1:S
%  for j = 1:(S+1)
%    c(i+1,j) = (rho * c(i,j)) + (B * f(i,j));
%  end
%end

% % 1-item primacy
% prim(1) = P1;
% for i = 2:S
%   prim(i) = 0;
% end

% store in Mcf
% for i = 1:S
%   for j = 1:(S+1)
%     wcf(i,j) = c(i+1,j) + prim(i) + C;
%   end
% end

% % calculate activations
% for i = 1:S
%   a(i) = dot(wcf(i,:), c(S+1,:));
% end

% study period of every list
wcf = zeros(S+1) + C;
c = zeros(S+1, 1);
c(end) = 1;
for i = 1:S
  f = zeros(S+1, 1);
  f(i) = 1;
  
  c = rho * c + B * f;
  
  P = (P1 * exp(-P2 * (i - 1))) + 1;
  wcf = wcf + (P * (f * c'));
end

a = (wcf * c)';
a = a(1:S);

% calculate the probability distribution
l = a.^T;
p = l ./ sum(l);

% the recalled item is chosen from a categorical distribution
for i = 1:N
  logl(i) = log(p(r(i)));
  logl_all(i,:) = log(p);
end

