function logl = tcm_general_bin(param, data, var_param)
%TCM_GENERAL_BIN   Get log likelihood using a binary implementation of TCM.
%
%  logl = tcm_general_bin(param, data, var_param)
  
if isstruct(data)
  % write out the data to a text file
  data_file = tempname(tempdir);
  write_data_tcmbin(data, data_file);
  temp_data = true;
else
  % already written as text
  data_file = data;
  temp_data = false;
end

if isstruct(param)
  param_file = tempname(tempdir);
  write_param_tcmbin(param, param_file);  
  temp_param = true;
else
  param_file = param;
  temp_param = false;
end

if isfield(param, 'debug_input') && param.debug_input
  disp_file(param_file);
end

if isstruct(param) && isfield(param, 'sem_file') && ...
      isfield(param, 'S') && all(param.S ~= 0)
  logl = tcmbin(data_file, param_file, param.sem_file, param.itemno_file);
else
  logl = tcmbin(data_file, param_file);
end

if temp_data
  delete(data_file);
end
if temp_param
  delete(param_file);
end


function disp_file(filename)

  fid = fopen(filename, 'r');
  fprintf('%s:\n', filename);
  c = textscan(fid, '%s', 'Delimiter', '\n');
  for i = 1:length(c{1})
    fprintf('%s\n', c{1}{i});
  end
  fclose(fid);

