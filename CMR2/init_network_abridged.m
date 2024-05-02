function [net,env] = init_network_abridged(param,env)
% this should output the exp component, but then update
% env.pat_indices for each simulated subject within run_ function.
%
% [net,env,init_net] = init_network_abridged(param)
%
% Initialize a CMR network and corresponding environment
% structure. Here, we initialize net and env to after all items
% on the first list were presented. 
%
% This function makes quite a few assumptions in order to speed
% things up:
% - no distractors
% - only temporal context contributes to the end-of-list context cue
% - all items are presented exactly once in the initial list
% - before the first list item, we present an initial item orthogonal to all other items
% - feature (item) representations are orthonormal
% 
% Note that this is most straightforward for the first list, and was
% developed based on initializing the model, but it's left as an exercise
% to the reader to develop this for subsequent lists!

% we'll call on these a lot, so take them out of their respective 
% structures to speed things up.
ll = double(param.list_length(1));
B = param.B_enc;
gamma_fc = param.lrate_fc_enc;
gamma_cf = param.lrate_cf_enc;

% reset the network state: 
% === begin create_network code
% subregion parameters
for i=1:param.subregions
  net.c_sub{i}.B = B;
  net.c_sub{i}.B_enc = B;
  net.c_sub{i}.B_rec = param.B_rec(i);

  cum_dim = [0 cumsum(param.n_dimensions)];
  net.f_sub{i}.idx = cum_dim(i)+1:cum_dim(i+1);
  net.c_sub{i}.idx = net.f_sub{i}.idx;
end

% create the network structures
total_dimensions = sum(param.n_dimensions);

% the layers
net.f = zeros(total_dimensions,1);
net.c = net.f;

% lrates: these are scalars, not matrices
net.lrate_fc_enc = gamma_fc;
net.lrate_cf_enc = gamma_cf;
net.lrate_fc_rec = 0;
net.lrate_cf_rec = 0;

% create the connecting weight matrices
net.w_fc = eye(total_dimensions) * param.eye_fc;
net.w_cf = eye(total_dimensions) * param.eye_cf;

% ==== end create_network code

% the fun part! update net, env as if the first list were presented

% W_FC %

% above, we've initialized the pre-experimental component. Here, we
% calculate the experimental component.

% each item's strength in context is a function of param.B_enc
% (here, B) and the normalization factor used to make each net.c
% state have magnitude = 1.
rho = sqrt(1-B^2);

% the only values that change for the first list correspond to
% those items. Here, we'll calculate these values for the first ll
% items, as well as the first orthogonal item presented.
% then we'll fill in the values at the appropriate
% places for the first list in the network structure.
w_fc_exp = zeros(ll);

% When item i is presented to the model, it is associated to the
% previous state of context, in which item i-1 has strength B.
% So, for all i, elements in w_fc (i-1,i) have strength B. This
% corresponds to elements in the upper diagonal.
%
% Similarly, all (i-2,i) have strength B*rho, (i-3,i) have strength B*rho^2, ...,
% (i-n,i) has strength B*rho^(n-1).
% Again, we can index these items based off being above the
% diagonal (i,i). 
%
% Now we know that we want to set all items on a particular
% diagonal above the main diagonal all equal to the same value.
% Conveniently, Matlab indexes matrix elements
% starting with column 1, then going down the column. So, if we
% have the indices corresponding to the diagonal, subtracting all
% of those values by 1 will give us the elements for one above the
% diagonal, ... subtracting n will give us the elements that are n
% above the diagonal.
% In addition to subtracting n, we must also
% exclude the first n elements, as each upper diagonal has one
% fewer element than the previous one.a

% First, get the indices of the elements on the diagonal.
diag_ind = (1:ll)+(0:ll-1)*ll;

% now, loop through starting with the diagonal elements one above
% the main diagonal, all the way through to the strength of the
% context of the first item in the last context state before recall.
for n = 1:(ll-1)
   w_fc_exp(diag_ind((n+1):end)-n)=B*rho^(n-1);
end

% For the initially presented orthogonal item, its strengths in
% each context representation are solely determined by rho, as its
% strength in context when it is first presented to the model is 1,
% not B.
ortho_vector = rho.^(0:(ll-1));

% incorporate both list items and the first presented item for the
% final output.
net.w_fc([env.pat_indices{1} param.first_distraction_index],env.pat_indices{1}) = ...
      net.w_fc([env.pat_indices{1} param.first_distraction_index],env.pat_indices{1}) + ...
          gamma_fc * [w_fc_exp; ortho_vector];
      
% W_CF %
% as a starting point, use w_fc_exp, since they're the transpose of
% each other before adding on other scalars
w_cf_exp = w_fc_exp';

% next, calculate primacy gradient for all presented items, which
% will simply be a function of serial position. thus, these values
% will remain constant across all items corresponding to a context
% state of a serial position. for w_cf_exp, this means the values
% will vary by column but not row  
phi_s = repmat(((param.p_scale * exp(-param.p_decay * ((1:ll) - 1))) + 1)',1,ll);

% incorporate both list items and the first presented item for the
% final output.
net.w_cf(env.pat_indices{1},[env.pat_indices{1},param.first_distraction_index]) = ...
      net.w_cf(env.pat_indices{1},[env.pat_indices{1},param.first_distraction_index]) + ...
          gamma_cf * [phi_s.*w_cf_exp phi_s(:,1).*ortho_vector'];

% C %
% reiterating the calculation of the weight matrices above,
% context strength have strength B*rho^n for the item presented n
% serial positions previously. Conveniently, we already have a
% vector of these rho values, so just multiply by B.
% for the first orthogonal item, it will simply have strength
% rho^ll, as continuing with the pattern above.
net.c([env.pat_indices{1} param.first_distraction_index]) = ...
          [B.*ortho_vector(end:-1:1) rho^ll];

% F %
% zero everywhere except for the just-presented item.
 net.f([env.pat_indices{1} param.first_distraction_index]) = ...
          [zeros(ll-1,1); 1; 0];

% update env as if we presented everything.
env.list_index = [];
env.timer.rec_time = param.rec_time;
env.init_index = zeros(1,param.subregions);

env.list_num = 1;
env.n_presented_items = ll;
env.list_position = ll +1;
env.present_distraction_index = param.first_distraction_index + 1;

% intialize env structures based on pat_indices for the first list.
env.presented_index = cell(size(env.pat_indices));
env.presented_index{1} = env.pat_indices{1};
env.present_index = env.presented_index{1}(end);

[net, env] = create_semantic_structure(net, env, param);