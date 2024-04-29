function x = aic(logl, k, n)
%AIC   Akaike Information Criterion with finite sample correction.
%
%  x = aic(logl, k, n)
%
%  INPUTS:
%    logl:  log likelihood of the data for maximum-likelihood
%           parameters.
%
%       k:  number of model parameters.
%
%       n:  number of fitted data points.

x = NaN(size(logl));
for i = 1:numel(logl)
  x(i) = calc_aic(logl(i), k(i), n(i));
end

function a = calc_aic(logl, k, n)

  a = -2*logl + 2*k + (2*k*(k+1))/(n-k-1);
