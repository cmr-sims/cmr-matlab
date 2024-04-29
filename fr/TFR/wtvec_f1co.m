function wtvec = wtvec_f1co
% wtvec = wtvec_f1co
%
%
% These groups correspond to the output of gamut
% 1:24 - s.p.c.
% 25:35 - relab control train CRP
% 36:43 - OP 1-2 corrected CRP
% 44:51 - OP 4+ corrected CRP
% 52:54 - PFR last 3 serial positions
% 55:57 - PSR last 3 serial positions
% 58:60 - PTR last 3 serial positions
% 61:70 - IRTs 0 through 9
%
%

wtvec = ones(1,70);

% 84:93 - IRTs 0 through 9
wtvec(61:70) = 0.0001;
