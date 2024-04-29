function [fit,erfvec] = eval_param_summary_tcm(param, state, varargin)
%EVAL_PARAM_SUMMARY_TCM   Calculate likelihood for TCM with a given set of paramters.
%
%  [fit, erfvec] = eval_param_tcm(param, ...)
%
%  INPUTS:
%     param:  parameter structure, or numeric vector of parameter
%             values (if numeric, must also pass param_info; see below).
%     data:
%      
%     pidx
%      
%     n_rep
%       
%     index
%       
%     wtvec
%
%  OUTPUTS:
%      fit:  chi square
%
%   erfvec:  likelihood for possible outcome, conditional on the
%             recalls made up to that point in the observed data.
%
%  OPTIONS:
%  These options may be set using parameter, value pairs, or by
%  passing a structure with these fields. Defaults shown in parentheses.
%   data          - REQUIRED. Either a behavioral data structure,
%                   or the path to a MAT-file containing the data,
%                   saved as a variable named 'data'.
%   param_info    - see unpack_param for details.
%   f_logl        - handle to a function of the form:
%                    [logl, logl_all] = f_logl(param, data)
%                   Calculates likelihood. (@tcm_general)
%   f_check_param - handle to a function of the form:
%                    param = f_check_param(param)
%                   Used to set default values and run sanity
%                   checks on parameters. (@check_param_tcm)
%   verbose       - if true, more information is printed.
%                   (isstruct(param))
%  May also pass additional parameter fields for f_logl.

% param evaluation configuration
def.data = '';
def.param_info = [];
def.f_stat = @tcm_stat;
def.f_check_param = @check_param_tcm;
def.verbose = isstruct(param);
def.load_data = true;
def.pidx = struct;
def.n_rep = 1;
def.index = [];
def.wtvec = [];

[opt, custom_param] = propval(varargin, def);

if ~isstruct(param)
  % convert to struct format
  if isempty(opt.param_info)
    error('Cannot interpret parameter vector without param_info')
  end
  param = unpack_param(param, opt.param_info);
end

% merge in additional parameters set
if ~isempty(custom_param)
  param = propval(custom_param, param, 'strict', false);
end

% sanity checks, set default parameters, etc.
param = opt.f_check_param(param);

if opt.verbose
  disp(param)
end

% load the behavioral data if necessary
if opt.load_data && ischar(opt.data)
  opt.data = getfield(load(opt.data, 'data'), 'data');
end

% will need to add argin checking?
[fit, erfvec] = opt.f_stat(param, varargin{1});

