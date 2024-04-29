function sem_mat = prep_sem_mat(sem_mat)
%PREP_SEM_MAT   Prepare a semantic similarity matrix for simulation.
%
%  sem_mat = prep_sem_mat(sem_mat)

% scale off-diagonal similarity to range from 0 to 1
temp = sem_mat;
l = size(sem_mat, 1);
temp(1:(l+1):end) = NaN;
sem_mat = (temp - min(temp(:))) ./ (range(temp(:)));

% set diagonal (self-similarity) to 0
sem_mat(1:(l+1):end) = 0;

