function [out_param] = set_param_tcm(param_info,in_param)
%
%
% TO DO: automate how stop rule gets set, using 'fixed'?

if isstruct(in_param)
    % let's make a vector
    for i = 1:length(param_info)
        out_param(i) = in_param.(param_info(i).name);
    end
    
else
    % let's make a structure
    for i = 1:length(param_info)
    
        out_param.(param_info(i).name) = in_param(i);
        out_param.stop_rule = 'ratio';
    
    end
end