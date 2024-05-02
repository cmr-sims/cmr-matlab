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
%   n_dimensions - number of dimensions for the context and feature layers
%   lrate_fc_enc - [subregions X subregions] matrix of learning rates
%                  of item-to-context associations during encoding
%   lrate_cf_enc - context-to-item learning rate during encoding
%   lrate_fc_rec - item-to-context learning rate during recall
%   lrate_cf_rec - context-to-item learning rate during recall
%   eye_fc       - value for the diagonal of the item-to-context matrix
%   eye_cf       - value for the diagonal of the context-to-item matrix
%
% NET:
% produced with the following fields
% c_sub        - context drift rates, for each subregion
% f            - feature layer
% c            - context layer
% lrate_fc_enc - [subregions X subregions] matrix of learning rates
%                  of item-to-context associations during encoding
% lrate_cf_enc - context-to-item learning rate during encoding
% lrate_fc_rec - item-to-context learning rate during recall
% lrate_cf_rec - context-to-item learning rate during recall
% w_fc         - item-to-context association matrix (M^{FC} in article)
% w_cf         - context-to-item association matrix (M^{CF} in article)


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

% learning rates
net.lrate_fc_enc = param.lrate_fc_enc;
net.lrate_cf_enc = param.lrate_cf_enc;
net.lrate_fc_rec = param.lrate_fc_rec;
net.lrate_cf_rec = param.lrate_cf_rec;

% create the connecting weight matrices
net.w_fc = eye(total_dimensions) * param.eye_fc;
net.w_cf = eye(total_dimensions) * param.eye_cf;