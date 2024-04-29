function seq = gen_uniform_samp_var_pstop(num_trials,param)
% GEN_UNIFORM_SAMP_VAR_PSTOP
%
% num_trials   - how many sequences to generate
% param.ps  - vector prob of stopping instead of recalling something at each
%             possible output position (length of ps is listLength).
%
% L  - likelihood of observing this sequence given this model 
%      (note, some unit test to make sure we can deal with very
%      small likelihoods without losing precision?)
%
% num_trials = 10;
% param.ps = [0.25 0.35 0.3 0.05 0.05];
%
% param.ps = [0.25 0.25 0.25 0.25];
%
%
% seq = gen_uniform_samp_var_pstop(num_trials,param);
%
%
% MODEL DESCRIPTION
% Uniform probability of recalling the remaining items.
% Strengths go into a Luce choice pool along with pstop
% the probabilities of the items sum to 1-pstop
% pr = (1-prob_model(1,LL+1)) * (strength ./ sum(strength));
% prob_model(1,1:LL) = pr;

% SMP: sanity checks would be: arguments are each one row

LL = length(param.ps);

% initialize seq matrix
seq = zeros(num_trials,LL);

ps = param.ps;
% conditional probability of stopping given that you've recalled
% all the list items is one by definition.
ps(end+1) = 1;

for i = 1:num_trials
  % init the strength vector
  strength = ones(1,LL);

  % calculate the probability of each sampled element given the
  % generating model.
  unstopped = true;
  pos = 1;
  
  while unstopped
  
    % make sure the stop probability is set in here! 
    [prob_model, strength] = pmod_uniform_samp_var_pstop(pos, ...
                                                      ps, ...
                                                      strength, ...
                                                      LL);
    % what was recalled?
    % pick based on pmod

    % choose an event
    u = rand;
    this_event = min(find(u<cumsum(prob_model)));
    
    if this_event == LL+1
      unstopped = false;
    else
      seq(i,pos) = this_event;
      pos = pos+1;
    end
    
    % you can't recall it again
    if this_event <= LL
      strength(1,this_event) = 0;
    end
    
  end

end
  
