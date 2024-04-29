function [net,data] = simulate_taskFR(param,data)
% [net,data] = simulate_taskFR(param,data);
%
% Runs a series of CMR simulations of free recall.
% 
% Sample minimal data structure:
%    LL = 24;
%    nlists = 5;
%    data.listLength = LL;
%    data.recalls = zeros(nlists,LL);
%    data.times = zeros(nlists,LL);
%    data.pres_itemnos = ones(nlists,LL);
%    data.pres_task = zeros(nlists,LL);
%
%    [net,outdata] = simulate_taskFR(param,data);
%
% [net,data] = simulate_taskFR(param,data.net.co);
%

LL = data.listLength;
nLists = size(data.recalls,1);
maxOP = getValFromStruct(param,'maxOP',length(data.pres_itemnos(1,:)));

%%%%%%%%%%%%%%%%%%%%%%%%%%
% set network parameters %
%%%%%%%%%%%%%%%%%%%%%%%%%%

taskShiftDisrupt = getValFromStruct(param,'taskShiftDisrupt',0);
env.timer.recTime = param.recTime;

% specialty code for altering recall and study modes
mrparam = getValFromStruct(param,'mrparam',[]);
msparam = getValFromStruct(param,'msparam',[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the network and environment % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

net = create_CMR(param);
envparam.nPats = net.nDim;
env = create_orthogonal_environment(env,envparam);
env.listNum = 0;

%%%%%%%%%%%%%%%%%%%%
% set up recording %
%%%%%%%%%%%%%%%%%%%%

% to record, pass in param.recording == 1
recording = getValFromStruct(param,'recording',0);
% some recording defaults
net.rec.c.data = [];
net.rec.c.reclevel = 'item';
net.rec.f.data = [];
net.rec.f.reclevel = 'item';

%%%%%%%%%%%%%%%%%%%%%%
% begin the paradigm %
%%%%%%%%%%%%%%%%%%%%%%

for i = 1:nLists

  % display progress
  if mod(i,25)==0, fprintf('%d ',i); end
  if mod(i,300)==0, fprintf('\n'); end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % reinitialize variables for this list %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % erasing record of c and f
  net.rec.c.data = [];
  net.rec.f.data = [];
  % set network for study
  msparam.modeString = 'study';
  msparam.suppressDisp = 1;
  net = mode_CMR(net,msparam);
  % reinit the network
  env.listNum = i;
  env.poolIdx = data.pres_itemnos(i,:);
  env.initTask = data.pres_task(i,1)+1;

  [net,env] = init_CMR(net,env,param);
  % bookkeeping
  env.allPresentedIdx = [];
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % present the list - study period %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if i == 1
    
    % THE STUDY PERIOD
    disruptCount = 0;
    for j = 1:length(data.pres_itemnos(i,:))

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % present the item, churn the network %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      % task-shift distractor      
      if taskShiftDisrupt
	if (j > 1) & (data.pres_task(i,j)~=data.pres_task(i,j-1))
	  itemInd = env.listIdx(1) + LL + disruptCount;
	  disruptCount = disruptCount + 1;
	  taskInd = [];
	  updateWeights = 0;
	  appendItem = 0;
	  isDistract = 1;
	  isEncoding = 0;
	  B_temp = net.c_sub{1}.B;
	  net.c_sub{1}.B = taskShiftDisrupt;
	  [net,env] = present_CMR(net,env,param,itemInd,taskInd,updateWeights,appendItem,isDistract,isEncoding);
	  net.c_sub{1}.B = B_temp;
	end
      end
      
      % present the actual item
      itemInd = [];
      taskInd = net.c_sub{2}.idx(data.pres_task(i,j)+1);
      updateWeights = 1;
      appendItem = 1;
      isDistract = 0;
      isEncoding = 1;
      [net,env] = present_CMR(net,env,param,itemInd,taskInd,updateWeights,appendItem,isDistract,isEncoding);
      
      if recording == 1
	net = record_fields(net,'item');
      end
      
    end % j items

    % bookkeeping
    env.allPresentedIdx = [env.allPresentedIdx env.listIdx];
        
  else % i > 1
    
    [temp_net temp_env] = init_CMR(net,env,param);
    
  end % if i
  
  %%%%%%%%%%%%%%%%%
  % recall period %
  %%%%%%%%%%%%%%%%%

  mrparam.modeString = 'recall';
  mrparam.suppressDisp = 1;
  net = mode_CMR(net,mrparam);

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % initialize recall variables %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  env.recalled = zeros(1,LL);
  env.timer.timePassed = 0;
  env.recallCount = 0;
  env.lastRecIdx = 0;
  env.lastRecPos = 0;
  
  while env.timer.timePassed < env.timer.recTime

    if recording == 1
      net = record_fields(net,'recall');
    end
    
    [net,env] = recall_CMR(net,env,param);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % reactivation of the retrieved item %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % only let the net churn if there is time left
    if env.timer.timePassed < env.timer.recTime
      % allow the most recently recalled item to retrieve context
      itemInd = env.lastRecIdx;
      taskInd = [];
      updateWeights = 0;
      appendItem = 0;
      isDistract = 0;
      isEncoding = 0;
      [net,env] = present_CMR(net,env,param,itemInd,taskInd,updateWeights,appendItem,isDistract,isEncoding);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % logging the recall event %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % only record the event if: 
    %   the last recall was not an intrusion
    %   the last recall process didn't exceed allotted recall time
    
    if (env.lastRecPos > 0) & (env.timer.timePassed < env.timer.recTime)
      data.recalls(i,env.recallCount) = env.lastRecPos;
      data.times(i,env.recallCount) = env.timer.timePassed;
      data.task(i,env.recallCount) = data.pres_task(i,env.lastRecPos);
      data.rec_itemnos(i,env.recallCount) = data.pres_itemnos(i,env.lastRecPos);
    end % if not failure
    
    % BREAK if we have reached the maximum number of output positions
    if env.recallCount >= maxOP
      break;
    end
    
  end % while time
  
end % i lists
