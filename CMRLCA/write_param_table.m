function write_param_table(file, gaparam, param_vec, param_latex, varargin)
%WRITE_PARAM_TABLE
%
%  write_param_table(file, gaparam, param_vec, param_latex, varargin)

if ~exist('param_latex', 'var')
  param_latex = struct;
end

n_param = length(param_vec);
names = {gaparam.name};

fid = fopen(file, 'w');
fprintf(fid, '\\begin{tabular}{lccc} \\toprule\n');
fprintf(fid, '  & Best fit & Lower limit & Upper limit \\\\ \\midrule\n');

% enter the parameters
for i = 1:n_param
  % get latex code for this param name
  if isfield(param_latex, names{i})
    latex = param_latex.(names{i}).code;
    format = param_latex.(names{i}).format;
  else
    latex = names{i};
    format = '%g';
  end
  
  % best fit and search range
  best = param_vec(i);
  param_range = gaparam(i).range;
  
  format_str = ['  %s & ' format ' & %g & %g \\\\\n'];
  fprintf(fid, format_str, ...
          latex, best, param_range(1), param_range(2));
end

for i = 1:2:length(varargin)
  fprintf(fid, '  %s & %g & & \\\\\n', varargin{i}, varargin{i+1});
end

fprintf(fid, '  \\bottomrule\n');
fprintf(fid, '\\end{tabular}\n');
