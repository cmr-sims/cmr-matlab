function [prob_model, strength] = pmod_uniform_samp_var_pstop(pos,ps,strength,LL)
%
%
%
%
%


% update the stop_prob in prob model based on number of samples
prob_model(1,LL+1) = ps(pos);
% update the prob model based on recall history
for j = 1:LL      
  prob_model(j) = ...
      (1-prob_model(1,LL+1)) * ...
      (strength(j) ./ sum(strength));
end

% if all the strengths are zero then they'll all end up as NaNs and
% we can replace the NaNs with zeros
prob_model(isnan(prob_model)) = 0;



