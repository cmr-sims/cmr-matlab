
% a place for exploration code and some notes
% gathering the useful code fragments here, next step is to push
% them into their own little framework

% here's the code for getting clean recall sequences from M62 LL20
load MurdData;
% get rid of the other LLs for now
data = data.LL{1};
LL = data.listLength;
num_trials = size(data.recalls,1);
% make clean recall sequences
rec_cleaned = zeros(size(data.recalls));
for i = 1:size(data.recalls,1)
  this_rec_seq = data.recalls(i, ...
                              make_clean_recalls_mask2d(data.recalls(i,:)));
  rec_cleaned(i,1:length(this_rec_seq)) = this_rec_seq;
end

% here is code for getting some summary statistics from M62 clean
% seqs
sp = mean(spc(data.recalls, data.subject, data.listLength));
figure(1); clf; plot_spc(sp);
lc = mean(crp(data.recalls, data.subject, data.listLength));
figure(2); clf; plot_crp(lc);

rec_mask = make_clean_recalls_mask2d(data.recalls);
stop_pos = sum(rec_mask,2)+1;
stop_pos = collect(stop_pos,[1:data.listLength]);
for i=1:length(stop_pos)
  pstop(i) = stop_pos(i) / (num_trials - sum(stop_pos(1:i-1)));
end

% when I did fminsearch to optimze likelihood measure on one
% condition of M62 (LL 20) I got parameters close to
% these:
% [B P G S LL]
param = [0.58 11.36 0.15 0.62 LL];
seq = gen_tcm_lc(1000, param);
figure(1); hold on;
plot_spc(spc(seq,ones(1000,1),LL));
figure(2); hold on;
plot_crp(crp(seq,ones(1000,1),LL));

% [B P G T S LL]
param = [0.58 11.36 0.15 3 0.62 LL];
seq = gen_tcm_lc(1000, param);
figure(1); clf;
plot_spc(spc(seq,ones(1000,1),LL));
figure(2); clf;
plot_crp(crp(seq,ones(1000,1),LL));


% switching over to the luce choice rule with the tau parameter,
% just messing around with it, with act vals of [5 5 10] if tau is
% set to 14.43 then the probs are [0.25 0.25 0.5].  Making tau
% lower sharpens the difference, e.g., tau = 10, probs are [0.2119
% 0.2119 0.5761].  But the tau value that will give a particular
% set of probs depends on the magnitude of the activations, if acts
% are [10 10 20], then tau of 14.43 gives [0.1667 0.1667 0.6666],
% have to look into this, to understand it better.  This is a
% simplified version of the equation which might be relevant.
% Pre-normalization of the activations necessary?

% What will the new code look like?  Have a
% strength vector that will be transformed using this rule.

% ls shorthand for luce strength
tau = 10;
ls = (2*strength)./tau;
p = exp(ls) ./ sum(exp(ls));


% to-do, check the model pstop vs the data pstop

% BUG TRACKING!
% Sanity check, with change to more flexible luce choice rule, now
% the probabilities of all possible subsequences don't sum to 1.
%
% notes on the problem, possibly rounding errors adding up for very
% unlikely events?  how to identify such an error, is this a
% possible source? sum prob of all rec seqs is 0.9934 vs 1.0 when
% LL is 5 and we calc all possible recall seqs.  this discrepancy is
% sensitive to the parameter values.  how to debug? Q1, is the
% discrepancy sensitive to the number of -Infs that come out for
% the rec sequences?

% figured it out, see notebook

% modified model round 1 & round 2
% start_params => [0.8 10 0.3 1 0.6]; also [0.4 5 0.3 1.5 0.5];
% param_vec = [0.4113 3.0974 0.3268 2.7332 0.2929];
% best fit was 22,441

% round 1
% start params: param_vec = [0.5 1 0.5 0.1];
% best fit was 22,900
% best params were [0.5857 11.3648 0.1501 0.6241]

% round 2
% start params: param_vec = [0.8 30 0.3 0.6];
% best fit was 22,900
% best params were [0.5857 11.3648 0.1501 0.6241]
% exactly the same!

% generate data using these parameters
num_trials = 1200;
param = [0.41 3.1 0.33 2.73 0.29 20];
gen_data = gen_tcm_lc(num_trials, param);

struct.LL = 20;
struct.modelfn = @tcm_lc;
struct.rec_mat = gen_data;
start_vec = [0.8 5 0.6 4 0.6];
% then fit the data
options = optimset('Display', 'iter');
[x,fval,exitflag,output] = fminsearch(@(x) eval_model(x,struct), ...
                                     start_vec, options);

% param recovery round one.
% started at: [0.4 3 0.33 2.7 0.3];
% generating params were: [0.41 3.1 0.33 2.73 0.29 20];
% ended at: [0.3869    2.7073    0.3676    3.0360    0.2744]

% param recovery round two.
% started at: [0.8 5 0.6 4 0.6];
% generating params were: [0.41 3.1 0.33 2.73 0.29 20];
% ended at: [0.4011    2.9129    0.3361    2.8412    0.2834]
% fval was 20379.1

% also need a version that will run the generative version of the
% model and calculate summary statistics and calc goodness of fit
% based on that

struct.LL = 20;
struct.ntrials = 1200;
% some wrapper around gen_tcm_lc
struct.modelfn = @gen_tcm_lc;
struct.rec_mat = rec_clean;
% use rec_mat to generate summary statistics from the actual data
sp = mean(spc(rec_clean,data.LL{1}.subject,struct.LL));
lc = mean(crp(rec_clean,data.LL{1}.subject,struct.LL));
pos = [struct.LL-5:struct.LL-1 struct.LL+1:struct.LL+5];
struct.summary = [sp lc(pos)];

% start parameters first round (donbot)
% started at: param_vec = [0.4 5 0.3 1.5 0.5];
% ended at: [0.4802    5.3999    0.3158    1.4908    0.3706]
% fval = 0.6404

% start parameters second round (servo)
% started at: param_vec = [0.8 3 0.5 2 0.4];
% ended at:  [0.5533    3.1513    0.5427    2.0537    0.4614]
% fval = 0.5717

options = optimset('Display', 'iter');
[x,fval,exitflag,output] = fminsearch(@(x) eval_model_summary(x,struct), ...
                                     param_vec, options);

seq = gen_tcm_lc(1200,[x 20]);
figure(1); clf;
plot_spc(spc(seq,ones(1200,1),20));
figure(2); clf;
plot_spc(spc(seq,ones(1200,1),20));

rec_mask = make_clean_recalls_mask2d(seq);
stop_pos = sum(rec_mask,2)+1;
stop_pos = collect(stop_pos,[1:20]);
for i=1:length(stop_pos)
  pstop(i) = stop_pos(i) / (num_trials - sum(stop_pos(1:i-1)));
end

%
% May 23, 2013
%

% messing around with tcm_general, refamiliarizing before trying to
% replicate the PolyEtal09 model variants

param.G = 0.5;
param.C = 0.01;
param.B_enc = 0.5;
param.B_rec = 0.5;
param.P1 = 1;
param.P2 = 0.3;
param.stop_rule = 'op';
param.X1 = 0.01;
param.X2 = 0.5;
param.T = 2;

param_info(1).name = 'G';
param_info(1).vector_index = 1; 
param_info(2).name = 'C';
param_info(2).vector_index = 2; 
param_info(3).name = 'B_enc';
param_info(3).vector_index = 3; 
param_info(4).name = 'B_rec';
param_info(4).vector_index = 4; 
param_info(5).name = 'P1';
param_info(5).vector_index = 5; 
param_info(6).name = 'P2';
param_info(6).vector_index = 6; 
param_info(7).name = 'X1';
param_info(7).vector_index = 7; 
param_info(8).name = 'X2';
param_info(8).vector_index = 8; 
param_info(9).name = 'T';
param_info(9).vector_index = 9; 
opt.param_info = param_info;

param_vec = [0.5 0.01 0.5 0.5 1 0.3 0.01 0.5 2];

load PolyEtal09_data;
co = data.co;

[co.recalls co.pres_itemnos] = clean_recalls(co.recalls, co.pres_itemnos);

% [logL, logL_all] = tcm_general(param, co);

opt.data = co;
% [err, logl] = eval_param_tcm(param_vec, opt);


options = optimset('Display', 'iter');
start_vec = param_vec;
tic;
[x,fval,exitflag,output] = fminsearch(@(x) eval_param_tcm(x, opt), ...
                                     start_vec, options);
toc;

% this was the result:
% start = [0.5 0.01 0.5 0.5 1 0.3 0.01 0.5 2];
% x = [0.3231 0.0082 0.5232 0.7810 3.5953 0.5663 0.0116 0.2029 1.2363];
% fval = 21698.63;
% Exiting: Maximum number of function evaluations has been exceeded
%         - increase MaxFunEvals option.
%         Current function value: 21698.636231 



