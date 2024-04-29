function x = waic(a)

x = NaN(size(a));
for i = 1:size(a, 1)
  daic = a(i,:) - min(a(i,:));
  x(i,:) = exp(-.5 * daic) / sum(exp(-.5 * daic));
end