function res = tfr_beh_lik_nonstat(LL,ps)
% TFR_BEH_LIK_NONSTAT
%
% LL - list length
% ps - prob of stopping instead of recalling something at each
%      output position 
%
%
% LL = 5;
% ps = [0.25 0.35 0.3 0.05 0.05];
%
% LL = 4;
% ps = [0.25 0.25 0.25 0.25];
%
%
% res = tfr_beh_lik_nonstat(LL,ps);


% MODEL 1
% Uniform probability of recalling the remaining items

% MODEL 2
% prob of recalling an item starts out uniform but is perturbed by
% each draw.  Recalling an item increases the strength of the one
% following it by 1, without altering the stopping probability.

% initialize prob_model
prob_model = zeros(1,LL+1);
prob_model(1,LL+1) = ps(1);

strength = ones(1,LL);

% strengths go into a luce choice pool along with pstop
% the rest of the probabilities should sum to 1-pstop
% pr = (1-prob_model(1,LL+1)) * (strength ./ sum(strength));
% prob_model(1,1:LL) = pr;

% calculate the conditional probability of each sequence
% generate all the sequences

% calculate the probability of each run length based on pstop
p_continue = cumprod(1-ps);


% generate sequences
all_perms = perms(1:LL+1);
for i=1:size(all_perms,1)
  all_perms(i,find(all_perms(i,:)==(LL+1)):end) = 0;
end

% get it to be all subsequences
% collapse identical rows
all_subseq = unique(all_perms,'rows');

% calculate the probability of each row
% given a model where only pstop changes with output position and
% the prob of recall for the individual items is stationary
event_prob = zeros(size(all_subseq));
cond_seq_prob = zeros(size(all_subseq));

for i=1:size(all_subseq)

  samp = 1;
  keep_going = true;

  % init the stop_prob in prob model based on history
  prob_model(1,LL+1) = ps(samp);

  % init the prob model for the items 
  prob_model(1:LL) = ...
      (1-prob_model(1,LL+1)) * ...
      (strength ./ sum(strength));
  
  % init the strength vector
  strength = ones(1,LL);

  while keep_going & (samp <= LL)
    % update the stop_prob in prob model based on number of samples
    prob_model(1,LL+1) = ps(samp);
    % update the prob model based on recall history
    for j = 1:LL      
      prob_model(j) = ...
          (1-prob_model(1,LL+1)) * ...
          (strength(j) ./ sum(strength));
    end
    this_element = all_subseq(i,samp);
    
    if this_element == 0
      % this will stop the while loop
      keep_going = false;
      % this is the stop event
      this_event = LL+1;
    else
      % this is some item
      this_event = all_subseq(i,samp);
      % you can't recall it again
      strength(1,all_subseq(i,samp)) = 0;
    end
    event_prob(i,samp) = prob_model(1,this_event);

    samp = samp+1;    
  end
end

% replace 0s with 1s in event_prob so cumprod isn't zeroed out
temp_event_prob = event_prob;
temp_event_prob(temp_event_prob==0) = 1;

res.all_subseq = all_subseq;
res.event_prob = event_prob;
res.cond_seq_prob = cumprod(temp_event_prob,2);

  
