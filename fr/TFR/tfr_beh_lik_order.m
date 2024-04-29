function [res] = tfr_beh_lik_order(data)
%
%
%
%


num_trials = size(data.subject,1);

% a simple model that chooses based on probabilities associated
% with SPC and p(stop)

% make the SPC
pr = mean(spc(data.recalls, data.subject, data.listLength));

% figure out pstop
clean_rec = make_clean_recalls_mask2d(data.recalls);
stop_pos = sum(clean_rec,2)+1;
pstop = collect(stop_pos,[1:data.listLength])./num_trials;

% calculate the CRP
res.lc = crp(data.recalls, ...
             data.subject, ...
             data.listLength); 

% step through the recall sequences and calculate the likelihood of
% each one

% model 1 is that at each time point you have a uniform sampling
% without replacement and pstop according to output position
rec_cleaned = zeros(size(data.recalls));
for i = 1:size(data.recalls,1)
  this_rec_seq = data.recalls(i, ...
                              make_clean_recalls_mask2d(data.recalls(i,:)));

  rec_cleaned(i,1:length(this_rec_seq)) = this_rec_seq;
end

param.ps = pstop;

logL = apply_by_index(@data_given_model, ...
                      data.subject, ...
                      1, ...
                      {rec_cleaned}, ...
                      @uniform_samp_var_pstop, param);

res.mod(1).description = 'pstop plus uniform selection probability';
res.mod(1).logL = logL;
% SMP: model 1 has the 24 values for pstop as free parameters.
res.mod(1).df = 24;

param.sp = pr;

logL = apply_by_index(@data_given_model, ...
                      data.subject, ...
                      1, ...
                      {rec_cleaned}, ...
                      @nonuniform_samp_var_pstop, param);

res.mod(2).description = 'pstop plus selection probability based on serial position';
res.mod(2).logL = logL;
% SMP: model 2 has 24 pstop values, and 24 p. rec. parameters.
res.mod(2).df = 24 + 24;

% Run some stats:
% if 2 times the difference in log-likelihoods is more than this
% number below, then you reject the simple model.

chi_thresh95 = chi2inv(.95,24);
chi_thresh99 = chi2inv(.99,24);

D = -2*(res.mod(1).logL-res.mod(2).logL);

% subject-level stat based on chi^2 distribution
for i=1:length(D)
  res.chi_p_m1_v_m2(i,1) = 1 - chi2cdf(D(i),res.mod(2).df-res.mod(1).df);
end

% group-level stat using a t-test
[h,p,ci,stats] = ttest(res.mod(1).logL, ...
                       res.mod(2).logL, 0.05, 'both');

res.t_m1_v_m2.p = p;
res.t_m1_v_m2.s = stats;
keyboard

% 
res.mod(1).permloglik = zeros(1,num_trials);

% generative model
num_trials = 1394;
mod1_recalls = NaN(num_trials,data.listLength);

for i=1:num_trials

  unstopped = 1;
  num_recalled = 0;
  mod1_eventp = zeros(1,data.listLength+1);
  mod1_pvec = NaN(1,data.listLength+1);
  % pick an item randomly from the remaining items, or stop
  while unstopped
      
    % set up probabilities
    mod1_eventp(data.listLength+1) = pstop(num_recalled+1);
    mod1_eventp(1:data.listLength) = ...
        (1 - pstop(num_recalled+1)) / ...
        (data.listLength - ((num_recalled+1)-1));
    mod1_eventp(mod1_recalls(i,1:(num_recalled+1)-1)) = 0;

    % choose an event
    u = rand;
    chosen = min(find(u<cumsum(mod1_eventp)));
    % add a check that mod1_eventp always sums to 1
    num_recalled = num_recalled + 1;
    mod1_recalls(i,num_recalled) = chosen;
    
    if (chosen == data.listLength+1) | (num_recalled == data.listLength);
      unstopped = false;
    end
    % grab the likelihood of this particular recall event
    mod1_pvec(num_recalled) = mod1_eventp(chosen);
  
  end % end of recall sequence
  % what is the likelihood of this particular recall sequence
  res.mod(1).permloglik(i) = log(prod(mod1_pvec(1:num_recalled)));

end

res.mod(1).permrecalls = mod1_recalls;
res.mod(1).permsumloglik = sum(res.mod(1).permloglik);

% SMP: 10/24.  Unclear whether the product of probabilities in a
% sequence like this is anything like the probability of that
% particular sequence from the set of all possible sequences.
% Especially given that probabilities are not stationary.  Should
% be able to make a quick model that proves it isn't true for a
% short list length, where all possible sequences can be
% enumerated, this might help shed light on the difficulty, and
% make it easier to think about the problem more broadly.  Like,
% for L=4, there are 4! possible sequences, but then the ones where
% pstop is chosen prior to the L+1 draw are considered equivalent.
% Could prove that the product method doesn't match how often a
% given sequence actually comes up.

% Casting the model in terms of marbles and urns.  You select a marble
% from an urn with L marbles within.  That's not exactly right, but
% let's start there.  One of the marbles is black, and if you pick it,
% you don't get to pick any more marbles.  The other marbles are
% numbered from 1 to L.  Each marble has an adjustable probability
% that it will be picked.  

% Note: When people repeat themselves (and they do) we are going to
% ignore the repetition, pretend it didn't happen, as a simplifying
% case.  The full version of the model should have the marble
% thrown back in, but now it is tiny, and unlikely to be repeated.


% When one model is a special case of the other, there is a test
% statistic that is distributed as chi-squared when certain
% conditions are met.  We don't know whether or not these
% conditions are met here, so to draw proper conclusions, we may
% have to come up with some permutation-based statistics.  

% how does one compare two log-likelihood values?  

% We have a set of conditional probabilities, each of which is the
% probability of terminating a recall sequence conditional on making a
% particular sequence of recalls, for a given data set.  

% We can ask, what is the likelihood of observing these data, this
% particular 

% What happens if you use model 1, above, to generate a large
% number of recall sequences.  Then you ask model 1 how likely
% each sequence is.  This will give you a distribution of
% log-likelihoods, which can be inspected.


% We would like to keep adding mechanisms until we can't get the
% observed data to be any better fit

% multinomial distribution

% what's the difference between the prediction and the outcome, how
% is that calculated?  what the equivalent of residual error?

% question, take factorial 5 situation, four list items and a stop
% probability. 
% there are 120 possible sequences of the 5 items, but item 5 is
% special, it signals the end of recall, the rest of the items are
% not counted, are disregarded.
n_trials = 10;
n_items = 5;

% list of possible arrangements
all_perms = perms(1:5);
% what if all post-5 items were replaced by NaNs?
stops = all_perms==5;
post_stops = cumsum(stops,2);
all_perms(post_stops) = NaN;


p_stop = 0.2;
pvec = zeros(n_trials, n_items);

% Generative model
for i=1:n_trials
  for j=1:n_items
    
    pvec
    
  end
end


