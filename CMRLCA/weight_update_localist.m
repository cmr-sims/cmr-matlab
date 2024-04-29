function net = weight_update_localist(net, c, lrate_fc, lrate_cf)
%WEIGHT_UPDATE_LOCALIST   Update connection weights using Hebbian learning.
%
%  This function assumes that items are orthonormal, that only one
%  unit is activated per subregion at a time, and that the activation
%  of that unit is 1. This is the case for all published versions of
%  CMR. Under these assumptions, it is not necessary to calculate a
%  computationally expensive outer product; the same result can be
%  produced using an assignment operation.
%
%  net = weight_update_localist(net, c, lrate_fc, lrate_cf)
%
%  INPUTS:
%       net:  must include fields:
%              f
%              f_sub
%              c_sub
%              w_fc
%              w_cf
%
%         c:  the state of context to associate with f.
%
%  lrate_fc:  [f subregions X c subregions] matrix of learning
%             rates. lrate_fc(i,j) gives the learning rate from f
%             subregion i to c subregion j.
%
%  lrate_cf:  [c subregions X f subregions] matrix of learning
%             rates. lrate_cf(i,j) gives the learning rate from c
%             subregion i to f subregion j.
%
%  OUTPUTS:
%       net:  these fields are updated:
%              w_fc
%              w_cf

% get the active unit in each subregion of the feature layer
f_ind = cell(1, length(net.f_sub));
for i = 1:length(f_ind)
  f_ind{i} = net.f_sub{i}.idx(find(net.f(net.f_sub{i}.idx)));
end

% for both weight matrices, learning rate is arranged as a
% [from x to] matrix. The order of dimensions for the actual weight
% matrices is [to x from].

% update Mfc, a C x F matrix
for i = 1:length(net.f_sub) % from F
  if isempty(f_ind{i})
    continue
  end
  for j = 1:length(net.c_sub) % to C
    % store context in the column corresponding to this item
    if lrate_fc(i,j) ~= 0
      net.w_fc(net.c_sub{j}.idx, f_ind{i}) = ...
          net.w_fc(net.c_sub{j}.idx, f_ind{i}) + ...
          (c(net.c_sub{j}.idx) .* lrate_fc(i,j));
    end
  end
end

% update Mcf, a F x C matrix
for i = 1:length(net.c_sub) % from C
  for j = 1:length(net.f_sub) % to F
    if isempty(f_ind{j})
      continue
    end
    % store context in the row corresponding to this item
    if lrate_cf(i,j) ~= 0
      net.w_cf(f_ind{j}, net.c_sub{i}.idx) = ...
          net.w_cf(f_ind{j}, net.c_sub{i}.idx) + ...
          (c(net.c_sub{i}.idx) .* lrate_cf(i,j))';
    end
  end
end

