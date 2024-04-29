function L = tcm_lc_pstop(seq,param)
% TCM_LC_PSTOP
%
% Bare bones version of TCM for exploration. This version takes
% p-stop values as parameters.
%
% param.LL = 3;
% param.ps = [0.1 0.2 0.4];
% param.B_enc = 0.5;
% param.B_rec = 0.5;
% param.pre_exp_fc = 0.5;
% param.pre_exp_cf = 0.5;
% param.p_scale = 0;
% param.p_decay = 0;
%
% % To test it %
%
% LL = 3;
% all_seq = generate_ordered_subsets(LL);
% modelfn = @tcm_lc_pstop;
% L = data_given_model(all_seq, modelfn, param);
% sum(exp(L)) % this should sum to 1

LL = param.LL;

ps = param.ps; 
% conditional probability of stopping given that you've recalled
% all the list items is one by definition.
ps(end+1) = 1;

B_enc = param.B_enc;
B_rec = param.B_rec;
pre_exp_fc = param.pre_exp_fc;
pre_exp_cf = param.pre_exp_cf;

% really just need to run guts of tcm and apply it to a single
% sequence

% clean seq of trailing zeros
% SMP: could leave this up to the user to save time?
if any(seq==0)
  seq = seq(seq~=0);
end

% append LL+1 element to end of sequence, this represents selecting
% the recall termination event
seq(end+1) = LL+1;

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
for i = 1:LL
  
  % present item
  f = zeros(LL+1,1);
  f(i) = 1;
  
  % update context
  c_in = w_fc * f;
  c_in = normalize_vector(c_in);
  rho = sqrt(1+(B_enc^2)*((dot(c,c_in)^2)-1)) - B_enc*dot(c,c_in);
  c = rho*c + B_enc*c_in;

  % calculate primacy gradient
  prime_fact = (param.p_scale * ...
                exp(-param.p_decay * (i - 1))) + 1;
  
  % update weights (using c_prev or c?)
  delta = (c * f');
  w_fc = w_fc + delta;
  delta = (f * c')  .* prime_fact; 
  w_cf = w_cf + delta;
  
end

log_event_prob = zeros(size(seq));

% calculate the probability of each sampled element given the
% generating model.
for i = 1:length(seq)

  % determine the strength of each item in the recall competition
  % also known as f_in
  strength = (w_cf * c)';
  % LL+1 is a placeholder position
  % strength(LL+1) = 0;

  % we aren't letting items be recalled twice
  for j = 1:(i-1)
    strength(seq(j)) = 0;
  end
   
  % what was recalled?
  this_event = seq(i);
  
  % reactivate item
  f = zeros(LL+1,1);
  f(seq(i)) = 1;
  
  % update context based on what was recalled
  c_in = w_fc * f;
  c_in = normalize_vector(c_in);
  rho = sqrt(1+(B_rec^2)*((dot(c,c_in)^2)-1)) - B_rec*dot(c,c_in);
  c = rho*c + B_rec*c_in;

  % update the stop_prob in prob model based on number of samples
  prob_model(1,LL+1) = ps(i);
  % update the prob model based on recall history
  for j = 1:LL      
    prob_model(1,j) = ...
        (1-prob_model(1,LL+1)) * ...
        (strength(j) ./ sum(strength(1:LL)));
  end
  
  % tweak pstop to make sure sum is truly equal to 1?
  % prob_model(LL+1) = 1-(sum(prob_model(1:LL)));
  
  log_event_prob(i) = log(prob_model(1,this_event));

  % if sum(prob_model) ~= 1
  %   keyboard
  % end
  
end

L = sum(log_event_prob,2);





