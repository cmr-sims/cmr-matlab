function net = context_update(net, subregion, param)
%CONTEXT_UPDATE   Integrate new context inputs.
%
%  net = context_update(net, subregion, param)
%
%  INPUTS:
%        net:  network struct.
%
%  subregion:  subregion of context to update.
%
%  PARAM:
%   c_in_norm - vector of length subregions; true for each subregion
%               for which context should be normalized before update.

% CALCULATE CONTEXT INPUT %
% net.c_in = net.w_fc * net.f;

% UPDATE CONTEXT %

% iterate through the sub-areas of context normalize IN if requested
if param.c_in_norm(subregion)
  net.c_in(net.c_sub{subregion}.idx) = ...
      normalize_vector(net.c_in(net.c_sub{subregion}.idx));
end 

net.c(net.c_sub{subregion}.idx) = ...
    advance_context(net.c_in(net.c_sub{subregion}.idx), ...
                    net.c(net.c_sub{subregion}.idx), ...
                    net.c_sub{subregion}.B);



function updated_c = advance_context(c_in, c, B)
%
%
%

% rho scales the current state of context 
rho = sqrt(1+(B^2)*((dot(c,c_in)^2)-1)) - B*dot(c,c_in);
updated_c = rho*c + B*c_in;

