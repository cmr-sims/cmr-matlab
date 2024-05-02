function subj_means = subj_means_across_sessions(analysis_matrix, subjects)

% take the mean of the analysis according to the subject. that's it!
subj_means = apply_by_index(@means_by_subj, ...
                           subjects, ...
			   1, ...
                           {analysis_matrix});

function subj_means = means_by_subj(analysis_matrix)

subj_means = nanmean(analysis_matrix,1);