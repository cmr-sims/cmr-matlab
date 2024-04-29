function p_recall = logl_spc(logl_possible, recalls)
%LOGL_SPC   Recall probability by serial position, from log likelihood.
%
%  p_recall = logl_spc(logl_possible, recalls)
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
%       p_recall:  [lists X items] matrix of recall probabilties
%                  for each list.

p_possible = exp(logl_possible);

% get only item recall probabilities, conditional on not stopping
[n_trials, n_recalls, n_resps] = size(p_possible);
list_length = n_resps - 1;
p_model = NaN(n_trials, n_recalls, list_length);
for i = 1:n_trials
  for j = 1:n_recalls
    if recalls(i,j) == 0
      % remove stopping events; only calculate the SPC for times in
      % the sequence when they made a recall
      continue
    end
    
    p = squeeze(p_possible(i,j,:));
    
    % remove stop probability
    %p = p(1:list_length);
    %p_model(i,j,:) = p ./ sum(p);
    p_model(i,j,:) = p(1:list_length);
  end
end

p_recall = squeeze(nansum(p_model, 2));

