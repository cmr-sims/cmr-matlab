function logl = tcm_general_mex(param, data, var_param)
%TCM_GENERAL_MEX   Calculate log likelihood for free recall using TCM.
%
%  Similar to tcm_general, but calls C++ code that is much faster
%  (about 18-30X faster, depending on the data and model type). Unlike
%  tcm_general_bin.m, uses a direct interface to C++ that passes data
%  much more quickly. Currently does not support var_param.
%
%  logl = tcm_general_mex(param, data)
%
%  INPUTS:
%   param:  structure with model parameters. Each field must contain a
%           scalar or a string. 
%
%    data:  free recall data structure, with repeats and intrusions
%           removed. Required fields:
%            recalls
%            pres_itemnos
%    
% var_param: structure with information about parameters that vary
%            by trial, by study event, or by recall event.
%            Required fields:
%             name
%             update_level
%             val
%
%  OUTPUTS:
%      logl:  [lists X recalls] matrix with log likelihood values for
%             all recall events in data.recalls (plus stopping events).

param_vec = param_vec_tcmbin(param);

if isfield(param, 'sem_mat') && ~isempty(param.sem_mat)
  logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec, ...
                    data.pres_itemnos, param.sem_mat);
else
  logl = tcm_matlab(data.listLength, data.recalls_vec, param_vec);
end

