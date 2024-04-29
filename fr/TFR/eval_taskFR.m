function [fit, erfvec] = eval_taskFR(param_vec, state, fstruct)
%EVAL_TASKFR   Calculate error for a set of parameters for taskFR.n
%
%  Takes a parameter vector and runs a taskFR simulation, and returns
%  an error function rather than the actual results. Designed to work
%  with lab genetic algorithm functions.
%
%  [fit, erfvec] = eval_taskFR(param_vec, state, fstruct)
%
%  INPUTS:
%  param_vec:  parameters in vector form (use param_conversion).
%
%      state:  some information from GA code. Not used.
%
%    fstruct:  structure with information about how to run simulations.
%              Must contain the following fields:
%               datapath     - path to behavioral data structure
%               behav_resvec - actual results
%               behav_semvec - standard error for actual results
%               wtvec        - weight for each data point
%               sem_path     - path to semantic matrix
%               gaparam      - vector structure with information about
%                              each paramter being searched
%
%              These are optional:
%               customAnaFn  - analysis function to use
%                              (gamut_of_analyses_optim)
%               mult_subj
%               encodVar
%               justControl
%
%  OUTPUTS:
%        fit:  weighted chi2 error for this set of parameters.
%
%     erfvec:  chi2 error for each data point.
%
% EXAMPLE:
% param_vec = param_conversion(param,gaparam,'vector');
% 
% fstruct.datapath='/Users/polyn/SCIENCE/SIMULATION/CMR_sims/fr/TFR/PolyEtal09_data.mat';
% load(fstruct.datapath);
% [fstruct.behav_resvec,fstruct.behav_semvec] = gamut_of_analyses_optim(data.full);
% fstruct.gaparam = ga_param_full1;
% fstruct.sem_path = '/Users/polyn/SCIENCE/SIMULATION/CMR_sims/resources/LSA_tfr.mat';
% fstruct.wtvec = wtvec_ones;
% state = [];

% includes datapath and behav_vec
% load fmin_info;
behav_resvec = fstruct.behav_resvec;
behav_semvec = fstruct.behav_semvec;
wtvec = fstruct.wtvec;

% convert the param_vec back into a param structure 
param = param_conversion(param_vec, fstruct.gaparam, 'param');

% load semantic_matrix
if isfield(fstruct, 'sem_path')
  param.sem_path{1} = fstruct.sem_path;
  load(fstruct.sem_path);
else
  % load default semantic matrix from param_conversion
  load(param.sem_path{1});
end

if isfield(fstruct, 'mult_subj')
  param.mult_subj = fstruct.mult_subj;
end
if isfield(fstruct, 'encodVar')
  param.encodVar = fstruct.encodVar;
end
if isfield(fstruct, 'justControl')
  param.justControl = fstruct.justControl;
end

% run simulation and get raw data structure
data = run_taskFR(param, fstruct.datapath);

% printout of params for general debugging utility
param_vec

% run the analysis function
if isfield(fstruct, 'customAnaFn') 
  [net_resvec, net_semvec, res] = fstruct.customAnaFn(data, sem_mat);
else
  [net_resvec, net_semvec, res] = gamut_of_analyses_optim(data, sem_mat);
end

% calculate fitness
[fit, erfvec] = calculate_fitness(behav_resvec, net_resvec, ...
                                  behav_semvec, wtvec);

fprintf('chi^2: %g \n', fit);

