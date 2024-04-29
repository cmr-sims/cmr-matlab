function seq = gen_tcm_lc_pstop(num_trials,param)
% GEN_TCM_LC_PSTOP
%
%
% the simplest bare bones version of TCM I could come up with
%
% param.LL = 5;
% param.ps = [0.1 0.2 0.4 0.2 0.1];
% param.B = 0.5;
% param.p_scale = 0;
% param.p_decay = 0;
%
% seq = gen_tcm_lc_pstop(num_trials,param);

LL = param.LL;

ps = param.ps; 
% conditional probability of stopping given that you've recalled
% all the list items is one by definition.
ps(end+1) = 1;

B_enc = param.B_enc;
B_rec = param.B_rec;
pre_exp_fc = param.pre_exp_fc;
pre_exp_cf = param.pre_exp_cf;

seq = zeros(num_trials,LL);

for i=1:num_trials
  
  % initialize network structures

  % assume orthogonal items
  % not sure we need to explicitly simulate f
  f = zeros(LL+1,1);
  % do we have to assume context starts with length of 1 by
  % activating some orthogonal unit?
  c = zeros(LL+1,1);
  c(end) = 1;

  w_fc = eye(LL+1) * pre_exp_fc;
  w_cf = eye(LL+1) * pre_exp_cf;

  % first we have to simulate the study period
  for j = 1:LL
    
    % present item
    f = zeros(LL+1,1);
    f(j) = 1;
    
    % update context
    c_in = w_fc * f;
    c_in = normalize_vector(c_in);
    rho = sqrt(1+(B_enc^2)*((dot(c,c_in)^2)-1)) - B_enc*dot(c,c_in);
    c = rho*c + B_enc*c_in;
    
    % calculate primacy gradient
    prime_fact = (param.p_scale * ...
                  exp(-param.p_decay * (j - 1))) + 1;

    % update weights (using c_prev or c?)
    delta = (c * f');
    w_fc = w_fc + delta;
    delta = (f * c')  .* prime_fact; 
    w_cf = w_cf + delta;
    
  end % j
  
  % sample elements given the probabilities of the 
  % generating model.
  unstopped = true;
  pos = 1;
  this_seq = [];

  while unstopped
  
    % determine the strength of each item in the recall competition
    % also known as f_in
    strength = (w_cf * c)';
    % LL+1 is a placeholder position
    % strength(LL+1) = 0;

    % we aren't letting items be recalled twice
    if ~isempty(this_seq)
      for j = 1:(pos-1)
        strength(seq(i,j)) = 0;
      end
    end
  
    % update the stop_prob in prob model based on number of samples
    prob_model(1,LL+1) = ps(pos);
    % update the prob model
    for j = 1:LL      
      prob_model(1,j) = ...
          (1-prob_model(1,LL+1)) * ...
          (strength(j) ./ sum(strength(1:LL)));
    end
    prob_model(isnan(prob_model)) = 0;

    % choose an event
    u = rand;
    this_event = min(find(u<cumsum(prob_model)));

    % unstop if you choose the 'termination event'
    if this_event == LL+1
      unstopped = false;
    else
      this_seq(1,pos) = this_event;
      seq(i,pos) = this_event;
      pos = pos+1;
    end    
    
    % reactivate winning item
    if this_event < LL
      f = zeros(LL+1,1);
      f(seq(i,pos-1)) = 1;
    
      % update context based on what was recalled
      c_in = w_fc * f;
      c_in = normalize_vector(c_in);
      rho = sqrt(1+(B_rec^2)*((dot(c,c_in)^2)-1)) - B_rec*dot(c,c_in);
      c = rho*c + B_rec*c_in;
    end
    
    %keyboard
    
  end % while unstopped
    
end % num_trials
  
  

