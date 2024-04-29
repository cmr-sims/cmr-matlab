function L = tcm_lc_2p(recs,param)
% TCM_LC_2p
% L = tcm_lc_2p(recs,param)
%
% Bare bones version of TCM for exploration. 
% - just one Beta parameter (enc=rec) [B 0-1]
% - one-parameter primacy process [P 0-?]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - luce-choice with tau paramter from HK02 [T 0-inf]
% - pstop is negative exponential with decay parameter [S ?-?]
%
% This version works on a single trial.
% % fieldnames = {'B' 'P1' 'G' 'T' 'S' 'P2' 'LL'};
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
% recs = [2 3 0 0 0];
%
% % To test it %
% LL = 5;
% all_seq = generate_ordered_subsets(LL);
% param = [0.41 2.09 0.36 3.34 0.29 0.61 LL];
% modelfn = @tcm_lc_2p;
% L = data_given_model(all_seq, modelfn, param);
% sum(exp(L)) % this should sum to 1

% it can either be a struct or a vector
% if it is a vector, assign to struct fields
if ~isstruct(param)
    vec = param;
    clear param;
    fieldnames = {'B' 'P1' 'G' 'T' 'S' 'P2' 'LL' };
    for i=1:length(fieldnames)
       param.(fieldnames{i}) = vec(i); 
    end
end

LL = param.LL;

% copy recs to seq
seq = recs;    
% clean trailing zeros
if any(seq==0)
    seq = seq(seq~=0);
end
% append LL+1 element to end of sequence, this represents selecting
% the recall termination event.  pool+1 is the index for the
% recall termination event
seq(end+1) = LL+1;

% assume orthogonal items
% add a feature for the pre-list state of context
% not sure we need to explicitly simulate f
f = zeros(LL+1,1);

% context starts with length of 1
c = zeros(LL+1,1);
c(end) = 1;

w_fc = eye(LL+1) * (1 - param.G);
w_cf = zeros(LL+1);

% the study list
for i = 1:LL
  
    % present item
    f = zeros(LL+1,1);
    f(i) = 1;
    
    % update context
    c_in = w_fc * f;
    c_in = normalize_vector(c_in);
    rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
    c = rho*c + param.B*c_in;
    
    % 2 parameter primacy
    P = (param.P1 * exp(-param.P2 * (i - 1))) + 1;
    
    % update weights 
    % here we use c, others use c_prev 
    delta = param.G * (c * f');
    w_fc = w_fc + delta;
    delta = (f * c')  .* P; 
    w_cf = w_cf + delta;
    
end


% the recall period    
log_event_prob = zeros(size(seq));

% calculate the probability of each sampled element given the
% generating model.
for i = 1:length(seq)

    % determine the strength of each item in the recall competition
    % also known as f_in
    strength = (w_cf * c)';
    % for the network, LL+1 is a placeholder position
    % strength(LL+1) = 0;
    
    % we aren't letting items be recalled twice
    % (in a given recall period)
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
    rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
    c = rho*c + param.B*c_in;

    % stopping model is negative exponential of strength of all
    % competing items
    if i <= LL
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
    % prob_model(1,1:LL) = (1-prob_model(1,LL+1)) .* lp;
    
    % % update the prob model based on recall history
    % for j = 1:LL
    %     prob_model(1,j) = ...
    %         (1-prob_model(1,LL+1)) * ...
    %         (strength(j) ./ sum(strength(1:LL)));
    % end
    % replace NaNs with 0
    prob_model(isnan(prob_model)) = 0;
    
    log_event_prob(i) = log(prob_model(1,this_event));

end % recall period

% trial-wise likelihood
L = log_event_prob;%sum(log_event_prob,2);


