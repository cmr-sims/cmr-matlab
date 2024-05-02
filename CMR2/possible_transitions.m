function [transits_array] = possible_transitions(serial_position, ...
						 prior_recalls, transition, ...
						 params)
% POSSIBLE_TRANSITIONS  Returns the possible lags from a given serial position,
%                       excluding lags to serial positions which have already
%                       been recalled
%
%  [transits_array] = possible_transitions(serial_position, prior_recalls, ...
%                                          transition, params)
%
%  NOTE: this function is meant to be passed as a condition function to
%  conditional_transitions(); its arguments are dictated by the requirements
%  of that function.
%
%  INPUTS:
%  serial_position:  the serial position from which possible transitions should
%                    be calculated.  If this value is less than 1 (i.e., the
%                    'recall' was an intrusion or empty cell), an empty
%                    array is returned.
%
%    prior_recalls:  a row vector of serial positions which have already been
%                    recalled; transitions to these serial positions are
%                    excluded from the output
%
%       transition:  the current transition value (accepted here to meet the
%                    requirements of conditional_transitions(), but not used)
%
%           params:  a structure containing a field 'list_length' which
%                    specifies the length of the list, and a field
%                    'to_mask_pres' which specifies if any list
%                    positions are not possible to transition to in
%                    the context of this analysis.
%
%  OUTPUTS:
%   transits_array:  a row vector of possible transitions from the current
%                    serial position (excluding transitions to
%                    previously-recalled serial positions)
%
%  EXAMPLES:
%  >> sp = 4;
%  >> prior_recalls = [3 2];
%  >> params.list_length = 6;
%  
%  % with no prior recalls, all transitions for list_length 6 are possible:
%  >> possible_transitions(sp, [], -1, params)
%  ans =
%     -3   -2   -1   1   2
%     
%  % with two prior recalls, transitions to those positions are excluded:
%  >> possible_transitions(sp, prior_recalls, -1, params)
%  ans = 
%     -3    1    2
%  

% sanity checks
if ~exist('serial_position', 'var')
  error('You must pass a serial position')
elseif ~exist('prior_recalls', 'var')
  error('You must pass a prior_recalls vector')
elseif ~exist('params', 'var')
  error('You must pass a params struct')
elseif ~isfield(params, 'list_length')
  error('params must have a list_length field')
end
list_length = params.list_length;

if ~isfield(params, 'to_mask_pres')
  params.to_mask_pres = ones(1,list_length);
end
to_mask_pres = params.to_mask_pres;

if ~isfield(params, 'from_mask_pres')
  params.from_mask_pres = ones(1,list_length);
end
from_mask_pres = params.from_mask_pres;

% Transitions from an intrusion or empty cell are never allowed
if serial_position < 1
  transits_array = [];
  return
end

% Nor are transitions from a repeated word 
if any(ismember(prior_recalls, serial_position))
  transits_array = [];  
  return
end

% Nor are transitions from masked out serial positions allowed
if ismember(serial_position, find(from_mask_pres==0))
  transits_array = [];
  return
end

% Generally speaking, all transitions of magnitude greater than 0
% are possible, from (-serial_position + 1) to 
% (list_length - serial_position), inclusive
transits_array = [-serial_position + 1 : -1, 1 : list_length - serial_position];

% Remove transitions to items disallowed by to_mask_pres
disallowed_positions = [find(to_mask_pres==0) prior_recalls];
disallowed_transits = unique(disallowed_positions - serial_position);

% Remove transitions to previously recalled serial positions
% disallowed_transits = unique(prior_recalls - serial_position);
transits_array = setdiff(transits_array, disallowed_transits);

