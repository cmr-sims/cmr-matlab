function res = ana_taskFR(net_data, data, sem_mat)
%
%

co_trials = data.full.listType<2;
sh_trials = data.full.listType==2;

net_data_co = trial_subset(co_trials, net_data);
net_data_sh = trial_subset(sh_trials, net_data);

res.co.sp = spc(net_data_co.recalls,net_data_co.subject,24);
res.sh.sp = spc(net_data_sh.recalls,net_data_sh.subject,24);

figure(1);
clf;
param.marker = 'o';
plot_spc(res.co.sp,param);
hold on;
param.marker = 'x';
plot_spc(res.sh.sp,param);

res.co.lc = crp(net_data_co.recalls,net_data_co.subject,24);
res.sh.lc = crp(net_data_sh.recalls,net_data_sh.subject,24);

figure(2);
clf;
param.ylim = [0 0.3];
param.marker = 'o';
plot_crp(res.co.lc,param);
hold on;
param.marker = 'x';
plot_crp(res.sh.lc,param);

net_data.rec_itemnos = zeros(size(net_data.recalls));
for i = 1:size(net_data.recalls,1)
  net_data.rec_itemnos(i, net_data.recalls(i,:) > 0) = ...
      data.full.pres_itemnos(i, ... 
			     net_data.recalls(i, net_data.recalls(i,:) > 0));
end

res.df = dist_fact(net_data.rec_itemnos, ...
		   data.full.pres_itemnos, ...
		   net_data.subject, ...
		   sem_mat); 