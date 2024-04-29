function gof = eval_model_summary_ga(param_vec,state,struct) 
% EVAL_MODEL_SUMMARY
%
%
% struct.LL = 20;
% struct.genfn = @gen_tcm_lc;
% struct.summary = [sp lc];
% param_vec = [0.5 1 0.5 0.1];
%
% gof = eval_model_summary(param_vec, struct);
%

param = [param_vec struct.LL];

seq = struct.genfn(struct.ntrials, param);

sp = spc(seq,ones(struct.ntrials,1),struct.LL);
lc = crp(seq,ones(struct.ntrials,1),struct.LL);
pos = [struct.LL-5:struct.LL-1 struct.LL+1:struct.LL+5];
this_summary = [sp lc(pos)];

% first pass can be rmsd
gof = sqrt(sum((this_summary - struct.summary).^2));

