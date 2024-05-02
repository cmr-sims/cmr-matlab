function [winners,time,x] = decision_accum(param,in,noise,retrieved,thresholds)
%DECISION_ACCUM   Decide between competing representations.
%
%  Creates a set of leaky, competitive accumulators that determine
%  which item is recalled and with what latency.
%
%  [winners, time, x] = decision_accum(param, in, noise, recalled)
%
%  INPUTS: 
%  param:           structure that must have the following fields (if
%                   you're just running CMR2 code this should always work,
%                   but for completeness and clarity we list them here):
%                   K (parameter \kappa)
%                   eta
%                   dt
%                   dt_tau: dt/tau, calculated for efficiency
%                   sq_dt_tau: square root of dt_tau, calculated for efficiency
%                   L (parameter \lambda)
%                   reset, can_repeat: see explanation lines 60-62
%
%  in:              vector of activation values, one for each item entering
%                   the decision competition.
%
%  noise:           calculated in advance for efficiency, a matrix of
%                   random numbers with mean 0, std 1 for each time step 
%
%  retrieved:       vector, one corresponding to each item, keeping track
%                   of whether each item has been retrieved previously.
%                   this is important when keeping track of repetitions.
%
%  thresholds:      vector, one corresponding to each item, of the threshold
%                   value that an item's activation must exceed in order to
%                   be retrieved.
% 
%  OUTPUTS:
%  winners:         the winning item from the competition
%
%  time:            amount of time that has passed for this particular
%                   decision competition
%
%  x:               final activation values of each item in the competition

ncycles = size(noise,2);
nunits = size(in,1);
inds = 1:nunits;

% set values from parameters for efficiency
K = param.K;
eta = param.eta;
dt_tau = param.dt_tau;
sq_dt_tau = param.sq_dt_tau;
L = param.L;

% crossed keeps track of whether any items have crossed threshold.
crossed = 0;

% initialize x vector, with one item for each accumulator
x = zeros(size(in));

% if items can be repeated, then any item has the potential to be
% retrieved multiple times. if they cannot be repeated, then only allow
% items that have not been retrieved previously to be retrieved.
if param.can_repeat
  retrievable = true(size(x));
else
  retrievable = ~retrieved;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN ACCUMULATORS CYCLING %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

winners = [];
i = 1;

while i < ncycles && crossed == 0
  
  % the change in each accumulator (see Equation A5)
  %x = x + ((in - kx - lx) * dt_tau + (eta * noise(:,i) * sq_dt_tau));
  x = x + (in - K*x - (sum(x*L) - (x*L))) * dt_tau + ...
          eta * noise(:,i) * sq_dt_tau;
  x(x < 0) = 0;

  % one way to ensure that recently retrieved items are not retrieved for
  % short lags subsequently is to reset their values to 95% of what they 
  % were previously (compatible with CMR implentation).
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