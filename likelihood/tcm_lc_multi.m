function L = tcm_lc_multi(recs,param)
% TCM_LC_MULTI
% L = tcm_lc(recs,param)
%
% Bare bones version of TCM for exploration. 
% - just one Beta parameter (enc=rec) [B 0-1]
% - one-parameter primacy process [P 0-?]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - pstop is negative exponential with decay parameter [S ?-?]
% [ - luce-choice with tau paramter from HK02? ]
%
% Saving this in progress towards a multi-list version.
%
% param.S = 2;
% param.B = 0.5;
% param.P = 10;
% param.G = 0.5;
% param.LL = 5;
%
% recs = [2 3 0 0 0; 1 2 3 4 0];
%

LL = param.LL;
trials = size(recs,1);
pool = LL * trials;

% need to translate recs into the indices we are using here
% just add LL*trial_number to each row of recs
% SMP: have to make sure intrusions get set correctly, maybe pull
% this into a pre-function that will take care of intrusions appropriately?
for i=1:trials
   recs(i,:) = recs(i,:) + ((i-1) * LL);
end

% assume orthogonal items
% add a feature for the pre-list state of context
% not sure we need to explicitly simulate f
f = zeros(pool+1,1);

% do we have to assume context starts with length of 1 by
% activating some orthogonal unit?
c = zeros(pool+1,1);
c(end) = 1;

w_fc = eye(pool+1) * (1 - param.G);
w_cf = zeros(pool+1);

% outer loop for each study list
for i = 1:trials

    % figure out the set of indices for this list
    start = ((i-1) * LL) + 1;
    finish = i * LL;
    f_inds = [start:finish];
    
    % the study list
    for j = 1:LL
  
        % present item
        % Multi-list version, can't use i to reference features!
        f = zeros(pool+1,1);
        f(f_inds(j)) = 1;
  
        % update context
        c_in = w_fc * f;
        c_in = normalize_vector(c_in);
        rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
        c = rho*c + param.B*c_in;

        % calculate primacy gradient
        % prime_fact = (param.p_scale * ...
        %               exp(-param.p_decay * (i - 1))) + 1;
        
        
        if i == 1
            P = param.P;
        else
            P = 1;
        end
          
        % update weights (using c_prev or c?)
        delta = param.G * (c * f');
        w_fc = w_fc + delta;
        delta = (f * c')  .* P; 
        w_cf = w_cf + delta;
        
    end
    
    % the recall period, start collecting event probabilities
    
    % grab just the corresponding row of recs
    seq = recs(i,:);
    
    % clean trailing zeros
    if any(seq==0)
        seq = seq(seq~=0);
    end

    % append LL+1 element to end of sequence, this represents selecting
    % the recall termination event
    % is pool+1 an appropriate index for the recall termination event?
    seq(end+1) = pool+1;

    log_event_prob = zeros(size(seq));

    % calculate the probability of each sampled element given the
    % generating model.
    for j = 1:length(seq)

        % determine the strength of each item in the recall competition
        % also known as f_in
        strength = (w_cf * c)';
        % LL+1 is a placeholder position
        % strength(LL+1) = 0;
        
        % we aren't letting items be recalled twice
        % (in a given recall period)
        for j = 1:(i-1)
            strength(seq(j)) = 0;
        end
        
        % what was recalled?
        this_event = seq(i);
        
        % reactivate item
        f = zeros(pool+1,1);
        f(seq(j)) = 1;
        
        % update context based on what was recalled
        c_in = w_fc * f;
        c_in = normalize_vector(c_in);
        rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
        c = rho*c + param.B*c_in;

        % update the stop_prob in prob model based on number of samples        
        % strength of just the most recent list, or everything?  
        % if it doesn't work then the generative model will give a
        % crazy looking SPC, so check this.
        % MAKE THIS A COLUMN?
        prob_model(1,pool+1) = exp(-1 * param.S * sum(strength));
        
        % update the prob model based on recall history
        for k = 1:pool
            prob_model(1,k) = ...
                (1-prob_model(1,pool+1)) * ...
                (strength(k) ./ sum(strength(1:LL)));
        end
        
        % tweak pstop to make sure sum is truly equal to 1?
        % prob_model(LL+1) = 1-(sum(prob_model(1:LL)));
        
        log_event_prob(j) = log(prob_model(1,this_event));
        
        % if sum(prob_model) ~= 1
        %   keyboard
        % end
        
    end % recall period

    % trial-wise likelihood
    L_trial(i) = sum(log_event_prob,2);
    
end % session

L = sum(L_trial);



