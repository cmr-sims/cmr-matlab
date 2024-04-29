function seq = gen_tcm_lc(num_trials,param)
% GEN_TCM_LC
% seq = gen_tcm_lc(num_trials,param)
%
% Bare bones version of TCM for exploration. 
% - just one Beta parameter (enc=rec) [B 0-1]
% - one-parameter primacy process [P 0-?]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - luce-choice with tau paramter from HK02 [T 0-inf]
% - pstop is negative exponential with decay parameter [S ?-?]
%
% This version works on a single trial.
% % fieldnames = {'B' 'P' 'G' 'T' 'S' 'LL'};
%
% param = [0.5 1 0.5 1 0.1 3];
%
% param.B = 0.5;
% param.P = 1;
% param.G = 0.5;
% param.T = 1;
% param.S = 0.1;
% param.LL = 3;
%
% num_trials = 2;
% seq = gen_tcm_lc(num_trials,param)
%

% it can either be a struct or a vector
% if it is a vector, assign to struct fields
if ~isstruct(param)
    vec = param;
    clear param;
    fieldnames = {'B' 'P' 'G' 'T' 'S' 'LL' };
    for i=1:length(fieldnames)
       param.(fieldnames{i}) = vec(i); 
    end
end

LL = param.LL;

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

  w_fc = eye(LL+1) * (1 - param.G);
  w_cf = zeros(LL+1);

  % simulate the study period
  for j = 1:LL
    
    % present item
    f = zeros(LL+1,1);
    f(j) = 1;
    
    % update context
    c_in = w_fc * f;
    c_in = normalize_vector(c_in);
    rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
    c = rho*c + param.B*c_in;
    
    % this is the 1-position primacy version
    if j == 1
        P = param.P;
    else
        P = 1;
    end

    % update weights 
    % here we use c, others use c_prev 
    delta = param.G * (c * f');
    w_fc = w_fc + delta;
    delta = (f * c')  .* P; 
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
  
    % stopping model is negative exponential of strength of all
    % competing items
    if pos <= LL
        prob_model(1,LL+1) = exp(-1 * param.S * sum(strength));
    else
        prob_model(1,LL+1) = 1;
    end 
    % transform strengths preparing for luce choice
    lstr = (strength(1:LL)) .^ param.T;
    lp = lstr ./ sum(lstr);
    for j = 1:LL
        prob_model(1,j) = ...
            (1-prob_model(1,LL+1)) * ...
            (lp(j) ./ sum(lp(1:LL)));
    end    
    prob_model(isnan(prob_model)) = 0;
    
    % % update the prob model
    % for j = 1:LL      
    %   prob_model(1,j) = ...
    %       (1-prob_model(1,LL+1)) * ...
    %       (strength(j) ./ sum(strength(1:LL)));
    % end
    % prob_model(isnan(prob_model)) = 0;

    % choose an event
    u = rand;
    this_event = min(find(u<cumsum(prob_model)));

    % stop if you choose the 'termination event'
    if this_event == LL+1
      unstopped = false;
    else
      this_seq(1,pos) = this_event;
      seq(i,pos) = this_event;
      pos = pos+1;
    end    
    
    % reactivate winning item
    if this_event <= LL
      f = zeros(LL+1,1);
      f(seq(i,pos-1)) = 1;
    
      % update context based on what was recalled
      c_in = w_fc * f;
      c_in = normalize_vector(c_in);
      rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
      c = rho*c + param.B*c_in;
    end
    
    % keyboard
    
  end % while unstopped
    
end % num_trials
  

