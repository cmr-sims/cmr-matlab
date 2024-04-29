function seq = gen_tcm_lc_2p_sem(fstruct,param)
% GEN_TCM_LC_2P_SEM
% seq = gen_tcm_lc_2p_sem(fstruct,param)
%
% version of TCM for exploration. 
% - just one Beta parameter (enc=rec) [B 0-1]
% - one-parameter primacy process [P 0-?]
% - gamma_fc (gamma_cf fixed) [G 0-1]
% - luce-choice with tau paramter from HK02 [T 0-inf]
% - pstop is negative exponential with decay parameter [X ?-?]
% - semantic strength [S 0-?]
%
% fstruct needs to have:
% fstruct.LL
% fstruct.ntrials
% % fstruct.recalls
% fstruct.pres_itemnos
% fstruct.sem_path
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

load(fstruct.sem_path);


seq = zeros(fstruct.ntrials,LL);

for t = 1:fstruct.ntrials

    
    % for each trial take the pres_itemnos and the sem_mat and make a
    % semantic associative matrix for cf
    semantic = sem_mat(fstruct.pres_itemnos(t,:),fstruct.pres_itemnos(t,:));
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

    % sample elements given the probabilities of the 
    % generating model.
    unstopped = true;
    pos = 1;
    this_seq = [];

    while unstopped
        
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
        if ~isempty(this_seq)
            for j = 1:(pos-1)
                strength(seq(t,j)) = 0;
            end
        end
        
        % stopping model is negative exponential of strength of all
        % competing items
        if pos <= LL
            prob_model(1,LL+1) = exp(-1 * param.X * sum(strength));
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
        
        % choose an event
        u = rand;
        this_event = min(find(u<cumsum(prob_model)));
        
        % stop if you choose the 'termination event'
        if this_event == LL+1
            unstopped = false;
        else
            this_seq(1,pos) = this_event;
            seq(t,pos) = this_event;
            pos = pos+1;
        end    
        
        % reactivate winning item
        if this_event <= LL
            f = zeros(LL+1,1);
            f(seq(t,pos-1)) = 1;
    
            % update context based on what was recalled
            c_in = w_fc * f;
            c_in = normalize_vector(c_in);
            rho = sqrt(1+(param.B^2)*((dot(c,c_in)^2)-1)) - param.B*dot(c,c_in);
            c = rho*c + param.B*c_in;
        end
    
    
    end % while unstopped
end % ntrials



