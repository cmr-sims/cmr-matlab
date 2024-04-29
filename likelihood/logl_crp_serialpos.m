function crps = logl_crp_serialpos(logl_possible, recalls)
%LOGL_CRP_SERIALPOS   Conditional response probability by serial position.
%
%  crps = logl_crp_serialpos(logl_possible, recalls)
%
%  INPUTS:
%  logl_possible:  [lists X recalls X responses] matrix of log
%                  likelihood values produced by a model for each 
%                  possible recall event in a study (conditional on
%                  the actual recall sequence up to that point). Not to
%                  be confused with the likelihood of the actual
%                  responses the participant made.
%
%        recalls:  [lists X recalls] matrix giving the serial position
%                  of each recall in the study. Do not include stopping
%                  events.
%
%  OUTPUTS:
%           crps:  [starting points X items] matrix of conditional response
%                  probabilities. crp([list length + 1],:) gives the
%                  probabilities from the end of the list, i.e. the
%                  probability of first recall curve.

p_possible = exp(logl_possible);

[n_trials, n_recalls, n_resps] = size(p_possible);
list_length = n_resps - 1;
crps = zeros(n_resps, list_length);
n_cond = zeros(n_resps, list_length);

recalls = [repmat(n_resps, n_trials, 1) recalls];
for i = 1:n_trials
  for j = 2:n_recalls
    sp = recalls(i,j-1);
    if isnan(sp) || sp == 0 || recalls(i,j) == 0
      continue
    end
    
    % for this model and parameters, probability of each recall
    % event (including recalls and stopping)
    p_recalls = permute(p_possible(i,j-1,:), [1 3 2]);

    % for the rare case where all items have been recalled, so
    % probability of recalling any item is 0
    if all(p_recalls(1:list_length) == 0)
      continue
    end
    
    % remove stop probability; rescale other probabilities so they
    % are conditional on there being another recall
    p_recalls = p_recalls(1:list_length) ./ sum(p_recalls(1:list_length));
    
    p_nonzero = find(p_recalls);
    n_cond(sp, p_nonzero) = n_cond(sp, p_nonzero) + 1;
    crps(sp,:) = crps(sp,:) + p_recalls;
  end
end

% divide to get average log likelihood for each cell
crps = crps ./ n_cond;

