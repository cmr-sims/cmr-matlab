
% a template for fminsearch

load PolyEtal09_data;
data = data.full;

recs = data.recalls;
rec_mask = make_clean_recalls_mask2d(recs);

rec_clean = zeros(size(recs));
for i = 1:size(recs,1)
    this_seq = recs(i, make_clean_recalls_mask2d(recs(i,:)));
    rec_clean(i,1:length(this_seq)) = this_seq;
end

fstruct.LL = 24;
fstruct.modelfn = @tcm_lc_2p;
fstruct.genfn   = @gen_tcm_lc_2p;
fstruct.rec_mat = rec_clean;
fstruct.ntrials = 1394;

% pick some starting parameters
start_param = [0.4 2.1 0.4 3.3 0.3 0.6];
num_params = length(param);

% create the ranges to guide picking a start point
fstruct.ranges =     [0 1;...
                    0 50;...
                    0 1;...
                    0 10;...
                    0 10;...
                    0 10]';


res_dir = '~/sims/tcm_lc_2p/';
res_name = 'P09_full';
start_file = [];
options.nruns = 1;

% find the best fit parameters for P09
options = optimset('Display', 'iter');
[best_param,fval,exitflag,output] = fminsearchbnd(@(x) eval_model(x,fstruct), ...
                                                  start_param, ...
                                                  fstruct.ranges(1,:), ...
                                                  fstruct.ranges(2,:), ...
                                                  options);




% SMP: TODO: initialize random number generator

recovery = false;
if recovery
    % for each of N runs (distribute this part later!)
    for i=1:options.nruns
        
        % generate ntrials worth of data using the true model
        gen_mat = fstruct.genfn(fstruct.ntrials, [param fstruct.LL]);
        fstruct.rec_mat = gen_mat;
        
        % use fminsearch to start from some random start point within the
        % parameter ranges, get best fit parameters
        % random creation of the initial parameter set
        start_param = rand(1, num_params);
        
        % modify these to be within the appropriate ranges
        % first multiply each by the difference between the min and max
        % of the ranges, then add the min range.
        diffs = ones(1,1) * diff(fstruct.ranges);
        mins = ones(1,1) * fstruct.ranges(1,:);
        start_param = (start_param .* diffs) + mins;
        
        % generally speaking this is what fminsearch will look like
        % though the distributed version could turn off the display
        % distributed version will want to run multiple searches?
        options = optimset('Display', 'iter');
        % [x,fval,exitflag,output] = fminsearch(@(x) eval_model(x,fstruct), ...
        %                                       start_param, options);
        [recovered(i,:),fval(i),exitflag,output] = fminsearchbnd(@(x) eval_model(x,fstruct), ...
                                                          start_param, ...
                                                          fstruct.ranges(1,:), ...
                                                          fstruct.ranges(2,:), ...
                                                          options);
        
    end
end

% SMP: TODO. each time through, save out the resultant x value and fval


    
% SMP: goal is to get this running in parallel on ACCRE
% SMP: first get it working

% options.walltime = '00:30:00';

%[res_file] = run_fmin_dce(@eval_model_ga, {fstruct}, ranges, res_dir, ...
%                          res_name, options);






