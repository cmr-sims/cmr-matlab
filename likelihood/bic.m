function x = bic(logl, k, n)

% KimbEtal07: BIC = k ln(n) + n ln(RMSD)^2, n > 1
% Schw78:     BIC = ln(L) - (1/2) k ln(n)
% WitEtal12:  BIC = -2ln(L) + k ln(n)
% WagnFarr04: BIC = -2ln(L) + k ln(n)

x = NaN(size(logl));
for i = 1:numel(logl)
  x(i) = -2 * logl(i) + k(i) * log(n(i));
end
