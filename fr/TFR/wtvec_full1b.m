function wtvec = wtvec_full1b
% wtvec = wtvec_full1b
%
%
% These groups correspond to the output of gamut
% 1:7 - relabeled control train s.p.c.
% 8:14 - shift train s.p.c
% 15:25 - relab control train CRP
% 26:36 - shift train CRP
% 37 - relab source clustering
% 38 - shift source clustering
% 39 - relab remote source clustering
% 40 - shift remote source clustering
% 41:47 - train s.p.c difference
% 48:58 - train CRP difference
% 59:66 - OP 1-2 corrected CRP
% 67:74 - OP 4+ corrected CRP
% 75:77 - PFR last 3 serial positions
% 78:80 - PSR last 3 serial positions
% 81:83 - PTR last 3 serial positions
% 84:93 - IRTs 0 through 9
%
%

wtvec = ones(1,93);

% 1:7 - relabeled control train s.p.c.
wtvec(1:7) = 3;
% 8:14 - shift train s.p.c
wtvec(8:14) = 3;
% 15:25 - relab control train CRP
wtvec(15:25) = 4;
% 26:36 - shift train CRP
wtvec(26:36) = 4;
% 39 - relab remote source clustering
% 40 - shift remote source clustering
wtvec(39:40) = 3;
% 41:47 - train s.p.c difference
wtvec(41:47) = 2;
% 48:58 - train CRP difference
wtvec(48:58) = 5;
% 59:66 - OP 1-2 corrected CRP
wtvec(59:66) = 2;
% 67:74 - OP 4+ corrected CRP
wtvec(67:74) = 2;
% 84:93 - IRTs 0 through 9
wtvec(84:93) = 0.0001;
% all of the +2 positions in the train CRPs
wtvec([22 33 55]) = 15; 
