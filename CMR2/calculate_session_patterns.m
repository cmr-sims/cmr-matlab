function [n_patterns, first_distraction_index] = ...
                                           calculate_session_patterns(param)
%CALCULATE_SESSION_PATTERNS   Determine the number of patterns needed.
%
%  [n_patterns, first_distraction_index] = calculate_session_patterns(param)

n_patterns = zeros(1,param.subregions);
first_distraction_index = zeros(1,param.subregions);

% determine the appropriate number of patterns
for i = 1:param.subregions
  % unique pres_indices <-
  pres_indices_matrix = [param.pres_indices{:}];
  unique_labels = length(unique(pres_indices_matrix(i,:)));
  if ~isempty(param.not_presented_indices{i})
    unique_labels = unique_labels + ...
	length(unique(param.not_presented_indices{i}));
  end
  
  % unique cdfr distractor patterns
  if param.do_cdfr
    unique_cdfr = sum(param.cdfr_schedule(:)>0) * ...
	param.cdfr_disrupt_regions(i) * ...
	param.do_cdfr;
  else
    unique_cdfr = 0;
  end

  % unique dfr distractor patterns
  if param.do_dfr
    unique_dfr = sum(param.dfr_schedule>0) * ...
	param.dfr_disrupt_regions(i) * ...
	param.do_dfr;
  else
    unique_dfr = 0;
  end

  % unique shift distractor patterns
  % shift calculation must be sensitive to trial boundaries, which
  % pres_indices_matrix loses if list_length is not constant.  So
  % we return to pres_indices{}.
  unique_shift = 0;
  if param.do_shift 
    if param.shift_disrupt_regions(i)
      for j = 1:param.subregions
	for k = 1:length(param.pres_indices)
          these_pres_indices = param.pres_indices{k}(j,:);
	  these_unique = sum(sum(abs(diff(these_pres_indices,1,2)))) * ...
	      param.shift_trigger_regions(j);
	  unique_shift = unique_shift + these_unique;
	end % for k
      end % for j
    else % this region is not disrupted by shifts
      unique_shift = 0;
    end 
  end % if do_shift
  
  % unique end list distractor patterns  
  if param.do_end_list
    unique_end_list = sum(param.end_schedule>0) * ...
	param.end_disrupt_regions(i) * ...
	param.do_end_list;
  else
    unique_end_list = 0;
  end
  
  n_patterns(i) = sum([unique_labels, unique_cdfr, ...
		    unique_dfr, unique_shift, unique_end_list, ...
		    param.init_orthogonal_index(i)]);
  first_distraction_index(i) = unique_labels + 1;

end

