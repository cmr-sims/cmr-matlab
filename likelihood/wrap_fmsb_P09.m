
load PolyEtal09_data;
data = data.co;

recs = data.recalls;
rec_mask = make_clean_recalls_mask2d(recs);

rec_clean = zeros(size(recs));
for i = 1:size(recs,1)
    this_seq = recs(i, make_clean_recalls_mask2d(recs(i,:)));
    rec_clean(i,1:length(this_seq)) = this_seq;
end

func = @eval_model;
fstruct.modelfn = @tcm_lc_2p;
fstruct.rec_mat = rec_clean;
fstruct.LL = 24;
fstruct.ntrials = size(rec_clean,1);
func_input = {fstruct};
% ranges = [0 1; 0 20; 0 1; 0 10; 0 10; 0 10]';
% fieldnames = {'B' 'P1' 'G' 'T' 'S' 'P2' 'LL' };
ranges = [0 1; 2 2; 0.3 0.3; 3.3 3.3; 0.3 0.3; 0.6 0.6]';
res_dir = '~/sims/P09';
res_name = 'tcm_lc_2p_Lfit_temp';

options.num_fits = 10;
options.walltime = '02:30:00';

res_file = run_fmsb_dce(func, func_input, ranges, ...
                        res_dir, res_name, options); 




