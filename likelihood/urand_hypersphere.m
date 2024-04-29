function nv = urand_hypersphere(x0,rv)
%
%
% x0 - column vector, startpoint
%
%

% ndim
ndim = size(x0,1);

if ~exist('rv')
  rv = ones(ndim,1);
end

% get some random numbers
these = randn(ndim,1);

% project them to the unit hypersphere
these = these ./ (sqrt(sum(these.^2)));

% scale them by the radius vector
these = these .* rv;

% add them to the originating point
nv = x0 + these;
