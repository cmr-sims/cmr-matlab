function [net] = create_network(param)
%CREATE_NETWORK   Create a network based on a set of parameters.
%
%  [net] = create_network(param);
%
%  PARAM:
%  The param struct must have the following fields:
%   subregions   - number of subregions
%   B_enc        - integration rate during encoding, for each subregion
%   B_rec        - integration rate during recall, for each subregion
%   n_dimensions - ?
%   lrate_fc_enc - [subregions X subregions] matrix of learning rates
%                  of item-to-context associations during encoding
%   lrate_cf_enc - context-to-item learning rates during encoding
%   lrate_fc_rec - item-to-contex learning rates during recall
%   lrate_cf_rec - context-to-item learning rates during recall
%   eye_fc       - value for the diagonal of the item-to-context matrix
%   eye_cf       - value for the diagonal of the context-to-item matrix

% subregion parameters
for i = 1:param.subregions
  net.c_sub{i}.B = param.B_enc(i);
  net.c_sub{i}.B_enc = param.B_enc(i);
  net.c_sub{i}.B_rec = param.B_rec(i);

  cum_dim = [0 cumsum(param.n_dimensions)];
  net.f_sub{i}.idx = cum_dim(i)+1:cum_dim(i+1);
  net.c_sub{i}.idx = cum_dim(i)+1:cum_dim(i+1);
end

% create the network structures
total_dimensions = sum(param.n_dimensions);

% the layers
net.f = zeros(total_dimensions,1);
net.c = net.f;

% lrates: these are scalars, not matrices
net.lrate_fc_enc = param.lrate_fc_enc;
net.lrate_cf_enc = param.lrate_cf_enc;
net.lrate_fc_rec = param.lrate_fc_rec;
net.lrate_cf_rec = param.lrate_cf_rec;

% create the connecting weight matrices
net.w_fc = eye(total_dimensions) * param.eye_fc;
net.w_cf = eye(total_dimensions) * param.eye_cf;