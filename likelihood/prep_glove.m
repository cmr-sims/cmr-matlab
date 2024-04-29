function out = prep_glove(glove_filepath, wp_filepath, ...
                          out_filepath, expt_prefix)
%
% % EXAMPLE:
% glove_filepath = '/Users/polyn/Science/Analysis/GLOVE/glove.6B.300d.txt'; 
% wp_filepath = '/Users/polyn/Science/Analysis/fr_database/exp_files/SedeEtal06/wordpool.txt';
% out_filepath = '/Users/polyn/matlab/CMR_sims/fr/SE06/';
% expt_prefix = 'se06';
%
% glove_filepath = ''; wp_filepath = '';
% out_filepath = '/Users/polyn/matlab/CMR_sims/fr/TFRLTP/';
% expt_prefix = 'tfrltp';
%
% prep_glove(glove_filepath, wp_filepath, ...
%            out_filepath, expt_prefix)
%
% % NOTE:
% requires the wordpool file to have one word per line, lowercase
%


% run the BASH script I wrote to create a text file
% using the unix function

% $1 = the glove file
% $2 = the wordpool file
% %3 = the output file

% UNCOMMENT THIS IF NEEDED
% script_path = '/Users/polyn/Science/Analysis/GLOVE/grab_glove_vectors';

% cmd_string = [script_path ' ' glove_filepath ' ' wp_filepath ' ' out_filepath];
% [status, result] = unix(cmd_string,'-echo');
% END UNCOMMENT THIS IF NEEDED

out_vecfile = strcat(expt_prefix,'_glove_vectors.txt');

% load in the GLOVE vectors and snip off the word strings
fid = fopen(fullfile(out_filepath,out_vecfile));

C = textscan(fid, ...
             ['%s', repmat('%f', [1,300])], ...
             'CollectOutput', 1);

% then C{2} has the vectors, so we can run pdist 'cosine'
% Note that pdist 'cosine' is actually 1-cosine

Mv = pdist(C{2}, 'cosine');
M = squareform(Mv);
M = 1-M;

% the raw similarity scores
sem_mat = M;

outsemfile = strcat(expt_prefix,'_glove_raw.mat');
save(fullfile(out_filepath,outsemfile), 'sem_mat');

% the scaled similarity scores

% add minimum value to everyone so there are no negative values
lowest = min(min(M));
M = M-lowest;
% scale things so largest is 1
biggest = max(max(M));
M = M./biggest;
% set diagonal to zero
M(1:size(M,2)+1:end)=0;

sem_mat = M;
outsemfile = strcat(expt_prefix,'_glove.mat');
save(fullfile(out_filepath,outsemfile), 'sem_mat');


