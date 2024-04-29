function gaparam = ga_param_full1
% gaparam = ga_param_full1;
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

gaparam(3).name = 'B_enc_source';
gaparam(3).range = [0.4 1];
gaparam(3).vector_index = 3;

gaparam(4).name = 'B_rec_source';
gaparam(4).range = [0.4 1];
gaparam(4).vector_index = 3;

gaparam(5).name = 'pScale';
gaparam(5).range = [0.5 2.5];
gaparam(5).vector_index = 4;

gaparam(6).name = 'pDecay';
gaparam(6).range = [0.1 1];
gaparam(6).vector_index = 5;

gaparam(7).name = 'base_lrate_cf';
gaparam(7).range = [1.0 1.0];
gaparam(7).vector_index = 6;

gaparam(8).name = 'task_lrate_cf';
gaparam(8).range = [0 0.5];
gaparam(8).vector_index = 7;

gaparam(9).name = 'K';
gaparam(9).range = [0 0.7];
gaparam(9).vector_index = 8;

gaparam(10).name = 'L';
gaparam(10).range = [0 0.7];
gaparam(10).vector_index = 9;

gaparam(11).name = 'eta';
gaparam(11).range = [0 0.7];
gaparam(11).vector_index = 10;

gaparam(12).name = 's';
gaparam(12).range = [0.5 3.5];
gaparam(12).vector_index = 11;

gaparam(13).name = 'gamma_fc';
gaparam(13).range = [0 1.0];
gaparam(13).vector_index = 12;

gaparam(14).name = 'taskShiftDisrupt';
gaparam(14).range = [0 0.95];
gaparam(14).vector_index = 13;

gaparam(15).name = 'tau';
gaparam(15).range = [100 1000];
gaparam(15).vector_index = 14;


% check whether any yoked parameters have different ranges

