function [p_recalls] = spc(recalls_matrix, subjects, list_length, rec_mask)
%SPC    Serial position curve (recall probability by serial position).
%
%  Computes probability of recall for each serial position.
%  
%  p_recalls = spc(recalls_matrix, subjects, list_length, rec_mask)
%
%  INPUTS: 
%  recalls_matrix:  a matrix whose elements are serial positions of recalled
%                   items.  The rows of this matrix should represent recalls
%                   made by a single subject on a single trial.
%
%        subjects:  a column vector which indexes the rows of recalls_matrix
%                   with a subject number (or other identifier).  That is, 
%                   the recall trials of subject S should be located in
%                   recalls_matrix(find(subjects==S), :)
%
%     list_length:  a scalar indicating the number of serial positions in the
%                   presented lists.  serial positions are assumed to run 
%                   from 1:list_length.
%
%        rec_mask:  a logical matrix of the same shape as 
%                   recalls_matrix, which is false at positions (i, j) where
%                   the value at recalls_matrix(i, j) should be excluded from
%                   the calculation of the probability of recall.
% 
%  OUTPUTS:
%       p_recalls:  a matrix of probablities.  Its columns are indexed by
%                   serial position and its rows are indexed by subject.
%

% spc_for_subj does all the real work here
p_recalls = apply_by_index(@spc_for_subj, ...
                           subjects, ...
			   1, ...
                           {recalls_matrix, rec_mask}, ...
                           list_length);
%endfunction

function subj_p_recall = spc_for_subj(recalls, rec_mask, list_length)
  % Helper for spc: 
  % calculates the probability of recall for each serial position
  % for one subject's recall trials; returns a vector of probabilities,
  % indexed by serial position

  % presentation counts: the number of times presented items in the
  % given condition were presented in each serial position.  Here,
  % we are relying type casting from true -> 1...
  pres_counts = size(rec_mask,1);

  % select out the recalls at just the output positions and trials we want.
  masked_recalls = recalls(rec_mask);
  
  sp_counts = collect(masked_recalls, 1:list_length);

  subj_p_recall = sp_counts / pres_counts;
%endfunction