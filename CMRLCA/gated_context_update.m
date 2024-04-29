function net = gated_context_update(net, subregion, param)
% GATED_CONTEXT_UPDATE
%
%

% CALCULATE CONTEXT INPUT
% net.c_in = net.w_fc * net.f;

% CALCULATE GATE INPUT
net.g_in = net.w_g * net.f;

% UPDATE CONTEXT

% parameter for proportion of gates triggered by an incoming
% stimulus net.B(i)

% iterate through sub-areas of context

% for i=1:length(net.c_sub)
% normalize IN if requested
if param.c_in_norm(subregion)
  net.c_in(net.c_sub{subregion}.idx) = ...
      normalize_vector(net.c_in(net.c_sub{subregion}.idx));
end 

% sort input to each gate
[val, ind] = sort(net.g_in(net.c_sub{subregion}.idx),'descend');
% which gates are triggered?
g_sig = false(size(net.c_sub{subregion}.idx));
num_trig = round(net.c_sub{subregion}.B * ...
                 length(net.c_sub{subregion}.idx));
g_sig(ind(1:num_trig)) = true;
% g_sig is now the size of the context subregion
% completely update the units corresponding to the triggered gates
old_c = net.c(net.c_sub{subregion}.idx);
c_in = net.c_in(net.c_sub{subregion}.idx);
new_c(~g_sig) = old_c(~g_sig);
new_c(g_sig) = c_in(g_sig);
net.c(net.c_sub{subregion}.idx) = new_c;

% end




