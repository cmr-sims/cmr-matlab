function [param_info, fixed] = search_param_tcm(model_type, split_names, ...
                                                n_groups)
%SEARCH_PARAM_TCM   Get parameter ranges and fixed parameters.
%
%  [param_info, fixed] = search_param_tcm(model_type, split_names, n_groups)

fixed = struct;
switch model_type
  case 'test'
    par.B = [0 1];
    par.P1 = [0 10];
    par.P2 = [0 10];
    par.X1 = [0 .1];
    par.X2 = [0 1];
    par.C = [0 1];
    par.G = [0 1];
    
    start.B = 0.5;
    start.P1 = 1;
    start.P2 = 1;
    start.X1 = 0.0001;
    start.X2 = 0.3;
    start.C = 0.1;
    start.G = 0.9;
    
    fixed.T = 1;
  case 'tcm_lc_vfr'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 100];
    par.P2 = [0 100];
    par.G = [0 1];
    par.X1 = [0 1];
    par.X2 = [0 100];
    par.C = [0 100];
    par.T = [0 100];
    par.m = [0 0.00004];
    par.b = [0 1];
    
    start.B_enc = 0.78;
    start.B_rec = 0.78;
    start.P1 = 1.22;
    start.P2 = 0.92;
    start.G = 0.62;
    start.X1 = 0.02;
    start.X2 = 0.16;
    start.C = 0.58;
    start.T = 7.31;
    start.m = 0.000025
    start.b = 0.5;
    
  case 'tcm_lc_simple'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 100];
    par.P2 = [0 100];
    par.G = [0 1];
    par.X1 = [0 1];
    par.X2 = [0 1];
    par.C = [0 100];
    par.T = [0 100];
    
    start.B_enc = 0.78;
    start.B_rec = 0.78;
    start.P1 = 1.22;
    start.P2 = 0.92;
    start.G = 0.62;
    start.X1 = 0.02;
    start.X2 = 0.16;
    start.C = 0.58;
    start.T = 7.31;
  case 'tcm_mcmc'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 100];
    par.P2 = [0 100];
    par.G = [0 1];
    par.X1 = [0 1];
    par.X2 = [0 1];
    par.C = [0 100];
    par.T = [0 100];
    
  case 'tcm_szfr'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 100];
    par.P2 = [0 100];
    par.G = [0 1];
    par.X1 = [0 1];
    par.X2 = [0 100];
    par.C = [0 100];
    par.S = [0 100];
    par.D = [0 100];
  
    fixed.T = 10;
    
  case 'tcm_szfr_split'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 100];
    par.P2 = [0 100];
    par.G = [0 1];
    par.X1 = [0 1];
    par.X2 = [0 100];
    par.C = [0 100];
    par.S = [0 100];
    par.D = [0 100];
  
    fixed.T = 10;
    
    split_names = {'X2' 'C' 'S'};
    n_groups = 2;
    
  case 'tcm_lc_simple_was'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 10];
    par.P2 = [0 10];
    par.G = [0 1];
    par.X1 = [0 .1];
    par.X2 = [0 1];
    par.S = [0 1];
    par.T = [0 100];
    
    start.B_enc = 0.9381;
    start.B_rec = 0.5;
    start.P1 = 0.2714;
    start.P2 = 1;
    start.G = 0.9984;
    start.X1 = 0.0001;
    start.X2 = 0.3;
    start.S = 0.5;
    start.T = 1;
  case 'tcm_lc_simple_was2'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.P1 = [0 10];
    par.P2 = [0 10];
    par.G = [0 1];
    par.X1 = [0 10];
    par.X2 = [0 10];
    par.C = [0 1];
    par.S = [0 1];
    par.D = [0 1];
    par.T = [0 10];
    
    start.B_enc = 0.9381;
    start.B_rec = 0.5;
    start.P1 = 0.2714;
    start.P2 = 1;
    start.G = 0.9984;
    start.X1 = 0.0001;
    start.X2 = 0.3;
    start.C = 0.1;
    start.S = 0.1;
    start.D = 0;
    start.T = 1;
  case 'tcm_lc_2p'
    % TCM with Luce choice, stopping based on overall cuing
    % strength, and a two-parameter model of primacy
    par.B = [0 1];
    par.P1 = [0 20];
    par.P2 = [0 10];
    par.G = [0 10];
    par.X = [0 10];
    par.C = [0 10];
    
    start.B = .5;
    start.P1 = 2;
    start.P2 = 1;
    start.G = .5;
    start.X = .1;
    start.C = .1;
    
    fixed.T = 1;
  case 'tcm_1subj'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.C = [0 1];
    par.P = [0 10];
    par.G = [0 1];
    par.X1 = [0 1];
    par.X2 = [0 10];
    par.T = [0 1000];
    
    start.B_enc = 0.9381;
    start.B_rec = 0.5;
    start.C = 0.8;
    start.P = 0.0001;
    start.G = 0.55;
    start.X1 = 0.01;
    start.X2 = 0.3;
    start.T = 10;
  case 'tcm_stop'
    par.B_enc = [0 1];
    par.B_rec = [0 1];
    par.C = [0 10];
    par.P1 = [0 20];
    par.G = [0 1];
    par.X2 = [0 10];
    
    start.B_enc = 0.9381;
    start.B_rec = 0.5;
    start.C = 0.8;
    start.P1 = 2;
    start.G = 0.55;
    start.X2 = 0.3;
    
    fixed.X1 = 0.001;
    fixed.T = 10;
    fixed.P2 = 1;
  otherwise
    error('Unknown model type: %s', model_type)
end

names = fieldnames(par);
ranges = struct2cell(par);
if exist('start', 'var')
  starts = struct2cell(start);
else
  starts = [];
end

if exist('n_groups', 'var')
  temp = ones(size(names));
  for i = 1:length(split_names)
    ind = find(strcmp(split_names{i}, names));
    temp(ind) = n_groups;
  end
  n_groups = temp;
else
  n_groups = [];
end

param_info = make_param_info(names, 'range', ranges, 'start', starts, ...
                             'n_groups', n_groups);


