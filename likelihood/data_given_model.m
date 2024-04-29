function [L log_event_prob] = data_given_model(all_seq,modelfn,param)
% DATA_GIVEN_MODEL
%
% LL = 5;
% all_seq = generate_ordered_subsets(LL);
%
% param.ps = [0 0.2 0.4 0.3 0.1];
% modelfn = @uniform_samp_var_pstop;
%
% L = data_given_model(all_seq, modelfn, param);

L = zeros(size(all_seq,1),1);
log_event_prob = NaN(size(all_seq,1), size(all_seq,2)+1);

for i = 1:size(all_seq,1)
  
    %[L(i) log_event_prob(i,:)] = modelfn(all_seq(i,:), param);
    [a b] = modelfn(all_seq(i,:), param);
    L(i) = a;
    log_event_prob(i, 1:length(b)) = b;

end

% logL = sum(logL);

