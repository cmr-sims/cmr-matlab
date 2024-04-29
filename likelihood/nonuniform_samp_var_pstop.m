function L = nonuniform_samp_var_pstop(seq,param)
% NONUNIFORM_SAMP_VAR_PSTOP
%
% seq       - the sequence to evaluate
% param.ps  - vector prob of stopping instead of recalling something at each
%             possible output position (length of ps is listLength).
% param.sp  - vector prob of recalling each item according to
%             serial position
%
% L  - likelihood of observing this sequence given this model 
%      (note, some unit test to make sure we can deal with very
%      small likelihoods without losing precision?)
%
% seq = [5 1 2];
% param.ps = [0.25 0.35 0.3 0.05 0.05];
% param.sp = [0.5 0.4 0.3 0.5 0.7];
%
% seq = [4 3 2 1];
% param.ps = [0.25 0.25 0.25 0.25];
% param.sp = [0.5 0.1 0.3 0.7];
%
%
% L = uniform_samp_var_pstop(seq,param);
%
%
% MODEL DESCRIPTION
% Nonuniform probability of recalling the remaining items.
% Strengths go into a Luce choice pool along with pstop
% the probabilities of the items sum to 1-pstop
% pr = (1-prob_model(1,LL+1)) * (strength ./ sum(strength));
% prob_model(1,1:LL) = pr;

% SMP: sanity checks would be: arguments are each one row

% clean seq of trailing zeros
% SMP: could leave this up to the user to save time?
if any(seq==0)
  seq = seq(seq~=0);
end

LL = length(param.ps);

% append LL+1 element to end of sequence, this represents selecting
% the recall termination event
seq(end+1) = LL+1;

ps = param.ps;
% conditional probability of stopping given that you've recalled
% all the list items is one by definition.
ps(end+1) = 1;

log_event_prob = zeros(size(seq));

% init the strength vector
strength = param.sp;

% calculate the probability of each sampled element given the
% generating model.
for i = 1:length(seq)
  
  % update the stop_prob in prob model based on number of samples
  prob_model(1,LL+1) = ps(i);
  % update the prob model based on recall history
  for j = 1:LL      
    prob_model(j) = ...
        (1-prob_model(1,LL+1)) * ...
        (strength(j) ./ sum(strength));
  end
  % what was recalled?
  this_event = seq(i);
  
  % you can't recall it again
  if this_event <= LL
    strength(1,this_event) = 0;
  end
  
  log_event_prob(i) = log(prob_model(1,this_event));
  
end

L = sum(log_event_prob,2);
  
