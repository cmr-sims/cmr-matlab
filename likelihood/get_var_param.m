function y = get_var_param(x, ind)
%GET_VAR_PARAM   Get parameters for a specific subject/trial/etc.
%
%  y = get_var_param(x, ind)
%
%  INPUTS:
%        x:  parameter structure. Some fields may contain vectors
%            to indicate that the parameter varies based on e.g. the
%            subject, trial, or condition.
%
%      ind:  for each vector field, indicates the element to return.
%
%  OUTPUTS:
%        y:  standard parameter structure, with values selected for
%            the given ind.

f = fieldnames(x);
y = struct;
for i = 1:length(f)
  if length(x.(f{i})) > 1 && ~ischar(x.(f{i})) && isvector(x.(f{i}))
    y.(f{i}) = x.(f{i})(ind);
  else
    y.(f{i}) = x.(f{i});
  end
end

