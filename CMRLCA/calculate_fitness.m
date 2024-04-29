function [f,v] = calculate_fitness(behav_resvec, net_resvec, behav_semvec, ...
                                   wtvec)
%CALCULATE_FITNESS   Calculate Chi2 goodness of fit.
%
%  [f, v] = calculate_fitness(behav_resvec, net_resvec, behav_semvec, wtvec)
%
%  INPUTS:
%  behav_resvec:  vector of behavioral data.
%
%    net_resvec:  vector of simulated model data.
%
%  behav_semvec:  vector standard error of the mean for behavioral data.
%
%         wtvec:  vector giving weights to apply to each data point.
%
%  OUTPUTS:
%        f:  sum of weighted chi2 values.
%
%        v:  unweighted chi2 value for each data point.
%
%  NOTES:
%   If any element of any input contains a NaN, overall fit will be
%   2000000.
%   tightly linked to gamut_of_analyses_optim.m
%
%  EXAMPLE:
%   [behav_res,behav_sem]=gamut_of_analyses_optim(data);
%   [net_res,net_sem]=gamut_of_analyses_optim(net_data);
%   wtvec = wtvec_srch1;
%   [f,v]=calculate_fitness(behav_res,net_res,behav_sem,wtvec);

% convert the resvec to chi-square
z = (behav_resvec - net_resvec) ./ behav_semvec;
chi2vec = z .^ 2;

% use weighting to emphasize certain aspects of the fit
wchi2vec = chi2vec .* wtvec;

chi2 = sum(wchi2vec);

if isnan(chi2)
  chi2 = 10^10;
end

f = chi2;
v = chi2vec;