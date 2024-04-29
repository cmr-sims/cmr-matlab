function Dakota = dakota_taskFR(Dakota)
% DAKOTA_TASKFR  Interface between the Dakota optimization software
% and the CMR Matlab code.
%
%

% use the values provided by Dakota to create a parameters vector
param_vec = Dakota.xC;

% set things up for eval_taskFR
state = [];
% need a custom gaparam file to map the parameters from the Dakota
% structure onto the standard param structure
fstruct.gaparam = ga_param_dakota1;
fstruct.wtvec = wtvec_ones;
fstruct.mult_subj = 1;

% path to the behavioral data on ACCRE
fstruct.datapath = '/home/polynsm/matlab/CMR_sims/trunk/fr/TFR/PolyEtal09_data.mat';
fstruct.sem_path = '/home/polynsm/matlab/CMR_sims/trunk/resources/LSA_tfr.mat';
resvec_path = '/home/polynsm/matlab/CMR_sims/trunk/fr/TFR/tfr_resvec.mat';

% load the results vector that is being fit by the
% simulation.  Prior to the simulation this should be saved
% to disk and loaded up here.
load(resvec_path);
fstruct.behav_resvec = behav_resvec;
fstruct.behav_semvec = behav_semvec;

% call eval_taskFR
[fit,erfvec] = eval_taskFR(param_vec,state,fstruct);

% get the fit ready to pass back to Dakota
Dakota.fnVals(1) = fit;
Dakota.fnLabels = {'chi2'};