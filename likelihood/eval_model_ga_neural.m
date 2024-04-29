function gof = eval_model_ga_neural(param_vec,state,struct) 
% EVAL_MODEL
%
% struct.LL = 20;
% struct.modelfn = @tcm_lc;
% struct.rec_mat = rec_mat;
% struct.neural_mat = neural_mat;
% param_vec = [0.5 1 0.5 0.1];
%
% L = eval_model(param_vec, struct);
%

ntrials = size(struct.rec_mat,1);
logL = zeros(ntrials,1);

param = [param_vec struct.LL];

for i = 1:ntrials
  
  logL(i) = struct.modelfn(struct.rec_mat(i,:), param, struct.neural_mat(i,:));
  
end

% % fmin looking for min, do we flip GOF?
gof = -1*sum(logL);

