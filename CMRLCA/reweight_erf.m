function reweight_erf(fcell,wtvec,outf)
%REWEIGHT_ERF  Update fitness values based on a reweighting of
%data-points from a fitting procedure.
%
% reweight_erf(fcell,wtvec,outf);
%
% INPUTS:
%    fcell: A cell array of the files on disk that should be
%    concatenated, each should contain fitness values, parameter
%    values and erfvec values.
%
%    wtvec: A vector with one element for each element of erfvec
%
%    outf: name of the output file containing the reweighted search
%    history. 
%
% USAGE:
%  
%    fcell = {'~/sims/VFR/ga1', '~/sims/VFR/ga2', '~/sims/VFR/ga3', '~/sims/VFR/ga4'};
%    wtvec = ones(1,35); wtvec(end-6:end) = 4;
%    outf = '~/sims/VFR/rewt_ga_phase_ana';
% 

% load fcell (fitness, parameters, erfvec)
parameters = [];
erfvec = [];

for i=1:length(fcell)
  temp = getfield(load(fcell{i}),'parameters');
  parameters = [parameters; temp];
  temp = getfield(load(fcell{i}),'erfvec');
  erfvec = [erfvec; temp];
end

% apply wtvec to erfvec
wtvec = ones(size(erfvec,1),1) * wtvec;
erfvec = erfvec .* wtvec;

% sum over rows to get new fitness
fitness = sum(erfvec,2);

% write to disk
save(outf,'fitness', 'parameters', 'erfvec');

