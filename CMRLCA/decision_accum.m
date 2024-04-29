function [winners,time,x] = decision_accum(param,in,noise,retrieved,thresholds)
%DECISION_ACCUM   Decide between competing representations.
%
%  Creates a set of leaky, competitive accumulators that determine
%  which item is recalled and with what latency.
%
%  [winners, time, x] = decision_accum(param, in, noise, recalled)
%
%  PARAM:
%   K
%   eta
%   dt
%   dt_tau
%   sq_dt_tau
%   lmat
%   reset
%   can_repeat

ncycles = size(noise,2);
nunits = size(in,1);
inds = 1:nunits;

K = param.K;
eta = param.eta;

crossed = 0;
dt_tau = param.dt_tau;
sq_dt_tau = param.sq_dt_tau;

x = zeros(size(in));

% lateral inhibition
L = param.L;
%lmat = param.lmat;

% if items can be repeated, then any item has the potential to be
% retrieved multiple times. if they cannot be repeated, then only allow
% items that have not been retrieved previously to be retrieved.
if param.can_repeat
  retrievable = true(size(x));
else
  retrievable = ~retrieved;
end

%%%%%%%%%%%%%%%%%%%%%%
% VISUALIZATION TOOL % 
%%%%%%%%%%%%%%%%%%%%%%
% set this flag to 1 to observe the input vector prior to each
% recall attempt.
% flag2 = 0;
% if flag2 == 1
%   figure(5);
%   clf;
%   plot(in,'.r-');
%   axis([0 25 0 1]);
%   keyboard
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN ACCUMULATORS CYCLING %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

winners = [];
i = 1;
while i < ncycles && crossed == 0
  
  % the lateral inhibition felt by each unit
  % old implementation:
  % lx = lmat * x;
  % assuming lmat = ~eye(length(x)) * L,
  % this way is equivalent but faster for large numbers of units:
  %lx = sum(x * L) - (x * L);
  
  % the activity leaking from each unit
  %kx = K .* x;
  
  % the change in each accumulator
  %x = x + ((in - kx - lx) * dt_tau + (eta * noise(:,i) * sq_dt_tau));
  % eliminated intermediate variables (lx, kx) for a slight speedup
  x = x + (in - K*x - (sum(x*L) - (x*L))) * dt_tau + ...
          eta * noise(:,i) * sq_dt_tau;
  x(x < 0) = 0;
%   imagesc(x');colorbar;
  
  % one way to ensure that recently retrieved items are not retrieved for
  % short lags subsequently is to reset their values to 95% of what they 
  % were previously.
  if param.reset && any(x >= thresholds)
    reset_these = retrieved & x >= thresholds;
    x(reset_these) = .95 * thresholds(reset_these);
  end
    
  % determine whether any items have crossed their respective thresholds
  if any(x >= thresholds & retrievable)
    crossed = 1;
    winners = inds(x >= thresholds & retrievable);
  end
  
  i = i + 1;
end % i ncycles

% calculate the amount of elapsed time
time = i * param.dt;

% determine which unit crossed; check for ties
% random tiebreak
if length(winners) > 1
  temp = randperm(length(winners));
  winners = winners(temp(1));
end
