function report_error(evec)
% report_error(evec)
%
% [behav_res,behav_sem]=gamut_of_analyses_optim(data);
% [net_res,net_sem]=gamut_of_analyses_optim(data.net);
% [f,v] = calculate_fitness(behav_res,net_res,behav_sem);
% report_error(v);
%
%
%

fprintf('Relab. co. train S.P.C.: \t%1.3f \n',sum(evec(1:7)));
fprintf('\tPrimacy train pos.: %1.3f \n',sum(evec(1:2)));
fprintf('Shift train S.P.C.: \t\t%1.3f \n',sum(evec(8:14)));
fprintf('\tPrimacy train pos.: %1.3f \n',sum(evec(8:9)));
fprintf('Relab. co. train C.R.P.: \t%1.3f \n',sum(evec(15:25)));
fprintf('Shift train C.R.P.: \t\t%1.3f \n',sum(evec(26:36)));
fprintf('Relab. co. source clust.: \t%1.3f \n',sum(evec(37)));
fprintf('Shift source clust.: \t\t%1.3f \n',sum(evec(38)));
fprintf('Relab. remote source clust.: \t%1.3f \n',sum(evec(39)));
fprintf('Shift remote source clust.: \t%1.3f \n',sum(evec(40)));
fprintf('Train S.P.C. diff.: \t\t%1.3f \n',sum(evec(41:47)));
fprintf('Train C.R.P. diff.: \t\t%1.3f \n',sum(evec(48:58)));
fprintf('O.P. 1-2 corr. C.R.P.: \t\t%1.3f \n',sum(evec(59:66)));
fprintf('O.P. 4+ corr. C.R.P.: \t\t%1.3f \n',sum(evec(67:74)));
fprintf('P.F.R. last 3 ser. pos.: \t%1.3f \n',sum(evec(75:77)));
fprintf('P.S.R. last 3 ser. pos.: \t%1.3f \n',sum(evec(78:80)));
fprintf('P.T.R. last 3 ser. pos.: \t%1.3f \n',sum(evec(81:83)));
fprintf('I.R.T. 0 through 9: \t%1.3f \n',sum(evec(84:93)));
fprintf('\nTotal Error: \t%1.3f \n',sum(evec));





