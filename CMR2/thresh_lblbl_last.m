function threshold = thresh_lblbl_last(net,env)

% suppose the last item of the earlier list is recalled:
% env.list_num
% set the index.
fake_recalled_index = env.pat_indices{1,env.list_num-2}(end);

% set f accordingly, and use this to determine theoretical c_in.
f = zeros(size(net.f));
f(fake_recalled_index) = 1;
c_in = net.w_fc * f;

% normalize
for i = 1:length(net.c_sub)
    c_in(net.c_sub{i}.idx) = normalize_vector(c_in(net.c_sub{i}.idx));
end
net.c(net.c<0) = 0;

% finally, determine c.c_in to set as threshold.
threshold = dot(net.c,c_in);