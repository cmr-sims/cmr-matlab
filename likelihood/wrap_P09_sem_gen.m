
res_dir = '~/sims/P09';
res_name = 'tcm_lc_2p_sem_Lfitlocal';
% this contains best_param
load(fullfile(res_dir,res_name));


load PolyEtal09_data;
data = data.co;

recs = data.recalls;
rec_mask = make_clean_recalls_mask2d(recs);

rec_clean = zeros(size(recs));
for i = 1:size(recs,1)
    this_seq = recs(i, make_clean_recalls_mask2d(recs(i,:)));
    rec_clean(i,1:length(this_seq)) = this_seq;
end

tic

sem_path = fullfile(res_dir, 'tfr_sem_mat');
load(sem_path);

fstruct.genfn = @gen_tcm_lc_2p_sem;
fstruct.LL = 24;
fstruct.ntrials = size(rec_clean,1);
fstruct.pres_itemnos = data.pres_itemnos;
fstruct.sem_path = sem_path;

seq = fstruct.genfn(fstruct, best_param);

toc

prefix = 'tcm_sem_Lfitlocal';
create_plots(seq,rec_clean,prefix,fstruct.LL,res_dir);

% ranges = [0 1; 0 20; 0 10; 0 1; 0 10; 0 10; 0 10]';
% fieldnames = {'B' 'P1' 'P2' 'G' 'T' 'X' 'S'};
% ranges = [0 1; 2 2; 8 8; 0.3 0.3; 3.3 3.3; 0.3 0.3; 0.6 0.6]';


