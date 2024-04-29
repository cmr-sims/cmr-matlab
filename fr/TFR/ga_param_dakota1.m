function gaparam = ga_param_dakota1
% gaparam = ga_param_dakota1;
% 
% One of a set of functions that creates a gaparam structure which
% facilitates interaction between the genetic algorithm code and
% the standard CMR code
%


gaparam(1).name = 'B_enc_temp';
gaparam(1).range = [0.4 1];
gaparam(1).vector_index = 1;

gaparam(2).name = 'B_rec_temp';
gaparam(2).range = [0.4 1];
gaparam(2).vector_index = 2;

gaparam(3).name = 'B_source';
gaparam(3).range = [0.4 1];
gaparam(3).vector_index = 3;

gaparam(4).name = 'p_scale';
gaparam(4).range = [0.5 2.5];
gaparam(4).vector_index = 4;

gaparam(5).name = 'p_decay';
gaparam(5).range = [0.1 1];
gaparam(5).vector_index = 5;

gaparam(6).name = 'task_lrate_cf';
gaparam(6).range = [0 0.5];
gaparam(6).vector_index = 6;

gaparam(7).name = 'K';
gaparam(7).range = [0 0.7];
gaparam(7).vector_index = 7;

gaparam(8).name = 'L';
gaparam(8).range = [0 0.7];
gaparam(8).vector_index = 8;

gaparam(9).name = 'eta';
gaparam(9).range = [0 0.7];
gaparam(9).vector_index = 9;

gaparam(10).name = 'tau';
gaparam(10).range = [100 1000];
gaparam(10).vector_index = 10;

gaparam(11).name = 's';
gaparam(11).range = [0 4];
gaparam(11).vector_index = 11;

gaparam(12).name = 'gamma_fc';
gaparam(12).range = [0 1];
gaparam(12).vector_index = 12;

gaparam(13).name = 'd';
gaparam(13).range = [0 0.95];
gaparam(13).vector_index = 13;