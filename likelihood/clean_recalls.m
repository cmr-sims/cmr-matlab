function varargout = clean_recalls(varargin)
%CLEAN_RECALLS   Remove repeats and intrusions from a recalls matrix.
%
%  For likelihood-based fitting, when using a simple model that cannot
%  account for repeats or intrusions, we need to remove them from
%  the data. This function strips them from the recall sequence.
%
%  The downside of this approach is that some previously non-adjacent
%  recalls are treated as adjacent. The other option would be to
%  remove the entire list if there are any intrusions or repeats in
%  the recall period. For TFRLTP, this would remove about 60% of
%  lists, so it doesn't seem like a great option.
%
%  The first input must be a recalls matrix. Additional inputs will
%  be cleaned in the same manner as the recalls matrix; they will
%  be passed out in the same order as they are input.
%
%  [clean_rec, clean_m1, clean_m2, ...] = clean_recalls(recalls, m1, m2, ...)

% the first input is recalls; use that to make the clean mask
mask = make_clean_recalls_mask2d(varargin{1});

varargout = cell(1, length(varargin));
for i = 1:length(varargout)
  % get this matrix
  orig = varargin{i};
  
  % initialize the clean version
  if isnumeric(orig)
    clean = zeros(size(orig));
  elseif iscell(orig)
    clean = cell(size(orig));
  else
    error('Invalid matrix type.')
  end
  
  % strip out unmasked recalls
  for j = 1:size(orig, 1)
    seq = orig(j, mask(j,:));
    clean(j, 1:length(seq)) = seq;
  end
  
  varargout{i} = clean;
end

