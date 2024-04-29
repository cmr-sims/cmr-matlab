function net = context_update_aging(net, subregion, param)
%  CONTEXT_UPDATE
%
%

% CALCULATE CONTEXT INPUT %
% net.c_in = net.w_fc * net.f;

% UPDATE CONTEXT %

% iterate through the sub-areas of context
% normalize IN if requested


%add noise to c_in
% Open questions:
% 1) should it be (1-xi)c_in + xi*c_in
% 2) should noise be constrained to be 1 < noise > -1

% to visualize vectors
% hist([net.c_in randn(size(net.c_in))])
% pause(.5)
% temp = net.c_in
%param.noise_factor

net.c_in = net.c_in + param.noise_factor .* randn(size(net.c_in));
net.c_in(net.c_in < 0) = 0;

% hist([net.c_in temp])
% legend('dirty','clean')
% pause(.5)




if param.c_in_norm(subregion)
  net.c_in(net.c_sub{subregion}.idx) = ...
      normalize_vector(net.c_in(net.c_sub{subregion}.idx));
end 

% plot(net.c_in)
% pause(.5)

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