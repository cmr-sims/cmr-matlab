function [L, L_possible] = tcm_lc_2p_sem(fstruct, param, varargin)
% TCM_LC_2P_SEM
% L = tcm_lc_2p_sem(fstruct,param)
%
% version of TCM for exploration. 
% - just one Beta parameter (enc=rec) [B 0-1]
% - two-parameter primacy process [P1 0-?, P2]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - luce-choice with tau paramter from HK02 [T 0-inf]
% - pstop is negative exponential with decay parameter [X ?-?]
% - semantic strength [S 0-?]
%
% fstruct needs to have:
% fstruct.LL
% fstruct.recalls
% fstruct.pres_itemnos
% fstruct.sem_mat
%
% This version works on a single trial.
% % fieldnames = {'B' 'P1' 'P2' 'G' 'T' 'X' 'S'};
%
% param = [0.5 1 1 0.5 1 0.3 1 3];
%
% param.B = 0.5;
% param.P1 = 1;
% param.P2 = 1;
% param.G = 0.5;
% param.T = 1;
% param.X = 0.3;
% param.S = 1;
% param.LL = 3;
%
% recs = [2 3 0 0 0];
%
% % To test it %
% LL = 5;
% all_seq = generate_ordered_subsets(LL);
% param = [0.41 2.09 0.61 0.36 3.34 0.29 1.0 LL];
% modelfn = @tcm_lc_2p_sem;
% % L = data_given_model(all_seq, modelfn, param);
% L = eval_model(fstruct, param);
% sum(exp(L)) % this should sum to 1

% convert new inputs if necessary
if isnumeric(fstruct)
  % we are getting model_logl.m style inputs
  v1 = fstruct;
  v2 = param;
  v3 = varargin{1};
  param = v1;
  data = v2;
  fstruct = v3;
  [~, fstruct.LL] = size_frdata(data);
  fstruct.recalls = data.recalls;
  fstruct.pres_itemnos = data.pres_itemnos;
end

% it can either be a struct or a vector
% if it is a vector, assign to struct fields
if ~isstruct(param)
    vec = param;
    clear param;
    fieldnames = {'B' 'P1' 'P2' 'G' 'T' 'X' 'S'};
    for i=1:length(fieldnames)
       param.(fieldnames{i}) = vec(i); 
    end
end

LL = fstruct.LL;

% copy recs to seq
seq = fstruct.recalls;    
% clean trailing zeros
if any(seq==0)
    seq = seq(seq~=0);
end
% append LL+1 element to end of sequence, this represents selecting
% the recall termination event.  pool+1 is the index for the
% recall termination event
seq(end+1) = LL+1;

% take the pres_itemnos and the sem_mat and make a semantic
% associative matrix for cf
semantic = fstruct.sem_mat(fstruct.pres_itemnos,fstruct.pres_itemnos);
semantic = semantic * param.S;
semantic(1:LL+1:end) = 0;


% assume orthogonal items
% add a feature for the pre-list state of context
% not sure we need to explicitly simulate f
f = zeros(LL+1,1);

% context starts with length of 1
c = zeros(LL+1,1);
c(end) = 1;

w_fc = eye(LL+1) * (1 - param.G);
w_cf = zeros(LL+1);
w_cf(1:LL,1:LL) = semantic;

% the study list
L_possible = NaN(length(seq), LL+1);
for i = 1:LL
    % present item
    f = zeros(LL+1,1);
    f(i) = 1;
    
    % update context
    % NWM: gamma is irrelevant here, since context is normalized before
    % update; so c_in is just a copy of f
    c_in = f;
    %c_in = w_fc * f;
    %c_in = normalize_vector(c_in);

    % NWM: given that all items are orthogonal, dot(c,c_in) must
    % equal 0. This is true even if simulating multiple lists, as
    % long as no items are repeated
    %rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
    rho = sqrt(1 - param.B^2);
    c = rho*c + param.B*c_in;
    
    % 2 parameter primacy
    P = (param.P1 * exp(-param.P2 * (i - 1))) + 1;
    
    % update weights 
    % here we use c, others use c_prev 
    %delta = param.G * (c * f');
    %w_fc = w_fc + delta;
    w_fc = w_fc + (param.G * (c * f'));
    %delta = (f * c')  .* P; 
    %w_cf = w_cf + delta;
    w_cf = w_cf + (P * (f * c'));
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
    % if we have a strange situation where an item is deemed
    % impossible to recall, we give it a miniscule probability
    strength(strength(1:LL)<=0) = eps;
    % if any(strength(1:LL)<=0)
    %   keyboard
    % end
    
    % we aren't letting items be recalled twice
    % (in a given recall period)
    % NWM: vectorized for speed
    strength(seq(1:(i-1))) = 0;
    %for j = 1:(i-1)
    %    strength(seq(j)) = 0;
    %end
        
    % what was recalled?
    this_event = seq(i);
        
    % reactivate item
    f = zeros(LL+1,1);
    f(seq(i)) = 1;

    % update context based on what was recalled
    c_in = w_fc * f;
    c_in = normalize_vector(c_in);
    % NWM: calculate the dot product only once; a little faster
    %rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
    rho = scale_context(dot(c, c_in), param.B);
    c = rho*c + param.B*c_in;

    % stopping model is negative exponential of strength of all
    % competing items
    prob_model = NaN(1, LL+1);
    if i <= LL
        prob_model(LL+1) = exp(-param.X * sum(strength));
    else
        prob_model(LL+1) = 1;
    end
    
    % % transform strengths preparing for luce choice
    % lstr = (strength(1:LL)) .^ param.T;
    % lp = lstr ./ sum(lstr);
    % for j = 1:LL
    %     prob_model(1,j) = ...
    %         (1-prob_model(1,LL+1)) * ...
    %         (lp(j) ./ sum(lp(1:LL)));
    % end

    % NWM: vectorized for speed
    % probability of recalling each item given that recall did not stop
    lstr = strength(1:LL) .^ param.T;
    prob_model(1:LL) = (1 - prob_model(LL+1)) .* (lstr ./ sum(lstr));

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
    L_possible(i,:) = prob_model;
    %if ~isreal(log_event_prob(i))
    %  keyboard
    %end
end % recall period

% trial-wise likelihood
L = log_event_prob;%sum(log_event_prob,2);


function rho = scale_context(cdot, B)

  rho = sqrt(1 + B^2 * (cdot^2 - 1)) - (B * cdot);

