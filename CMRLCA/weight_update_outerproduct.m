function delta_wt = weight_update_outerproduct(net_from, net_to, lrate)
%  WEIGHT_UPDATE_OUTERPRODUCT
%
%

delta_wt = (net_to * net_from') .* lrate;