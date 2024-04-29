function t_in = combine_contexts(t_exp, t_pre, gamma)
%COMBINE_CONTEXTS   Combine pre-experimental and experimental compenents.
%
%  t_in = combine_contexts(t_exp, t_pre, gamma)
%
%  NOTES:
%   Based on Howard et al. 2005. May be used for combining
%   components of c_in and for components of f_in.

if gamma == 0
  t_in = t_pre;
elseif isinf(gamma)
  t_in = t_exp;
else
  % calculate a_o, which varies based on the overlap between contexts
  a_o = sqrt(1 / (gamma^2 + 2 * gamma * (t_exp' * t_pre) + 1));
  
  % calculate a_n based on the definition of gamma
  a_n = gamma * a_o;

  % make the combined representation; should have length 1
  t_in = (a_o * t_pre) + (a_n * t_exp);
end

