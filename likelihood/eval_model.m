function [gof, logL, logL_possible] = eval_model(param, fstruct) 
%EVAL_MODEL   Calculate log likelihood for a model of free recall.
%
%  [gof, logL, logL_possible] = eval_model(param, fstruct)
%
%  INPUTS:
%    param:  vector of parameter values.
%
%  fstruct:  structure with options for calculating likelihood.
%            Required fields:
%             modelfn      - handle to a function of the form:
%                             L = modelfn(fstruct, param)
%                            where fstruct contains presentation
%                            information for one trial, and L is
%                            the likelihood for that trial.
%             ntrials      - number of trials.
%             LL           - list length.
%            Optional fields:
%             sem_path     - path to a MAT-file containing a semantic
%                            similarity matrix. The variable must be
%                            named 'sem_mat'.
%             recalls      - serial positions of recalls.
%             pres_itemnos - item numbers (indexes the semantic
%                            similarity matrix).
%
%  OUTPUTS:
%      gof:  negative log likelihood for all trials.
%
%  EXAMPLE:
%  fstruct.LL = 20;
%  fstruct.modelfn = @tcm_lc_2p;
%  fstruct.rec_mat = rec_mat;
%  fstruct.ntrials = 1200;
%  fstruct.ranges = [0 0 0 0 0 0; 1 50 1 10 10 10];
%
%  param_vec = [0.4 2 0.3 3.3 0.3 0.6];
%
%  L = eval_model(param_vec, fstruct);

n_recalls = size(fstruct.recalls, 2);
logL = NaN(fstruct.ntrials, n_recalls);
logL_possible = NaN(fstruct.ntrials, n_recalls, fstruct.LL+1);

mod_struct = struct;
mod_struct.LL = fstruct.LL;

if isfield(fstruct, 'sem_path') && ~isempty(fstruct.sem_path)
  mod_struct.sem_mat = getfield(load(fstruct.sem_path, 'sem_mat'), ...
                                'sem_mat');
end

for i = 1:fstruct.ntrials
  if isfield(fstruct, 'recalls')
    mod_struct.recalls = fstruct.recalls(i,:);
  end
  if isfield(fstruct,'neural')
      mod_struct.neural = fstruct.neural(i,:);
  end
  if isfield(fstruct,'pres_itemnos')
    mod_struct.pres_itemnos = fstruct.pres_itemnos(i,:);
  end
  
  % calculate likelihood for this recall sequence
  if nargout(fstruct.modelfn) == 1
    L = fstruct.modelfn(mod_struct, param);
    logL(i,1:length(L)) = L;
  else
    [L, L_possible] = fstruct.modelfn(mod_struct, param);
    logL(i,1:length(L)) = L;
    logL_possible(i,1:length(L),:) = L_possible;
  end
  %logL(i) = sum(L);
end

% make negative, since fitting routines generally are set up to
% minimize a value
gof = -nansum(logL(:));

