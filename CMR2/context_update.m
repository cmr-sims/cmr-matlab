function net = context_update(net, subregion, param)
%CONTEXT_UPDATE   Integrate new context inputs.
%
%  net = context_update(net, subregion, param)
%
%  INPUTS:
%        net:  network structure.
%
%  subregion:  subregion of context to update (for CMR2 simulations, 
%              this is always 1).
%
%      param:  aside from the usual fields (see readme), must also have
%
%      c_in_norm - vector of length subregions true for each subregion
%                  for which context should be normalized before update.

% iterate through the sub-areas of context normalize IN, if requested
% (for CMR2, param.c_in_norm is always true, as in Equation A1)
if param.c_in_norm(subregion)
  net.c_in(net.c_sub{subregion}.idx) = ...
      normalize_vector(net.c_in(net.c_sub{subregion}.idx));
end 

% UPDATE CONTEXT %

net.c(net.c_sub{subregion}.idx) = ...
    advance_context(net.c_in(net.c_sub{subregion}.idx), ...
                    net.c(net.c_sub{subregion}.idx), ...
                    net.c_sub{subregion}.B);



function updated_c = advance_context(c_in, c, B)
%
% c_in: input to context
%    c: current state of context
%    B: beta parameter

% Equation A2
rho = sqrt(1+(B^2)*((dot(c,c_in)^2)-1)) - B*dot(c,c_in);
% Equation 1
updated_c = rho*c + B*c_in;

