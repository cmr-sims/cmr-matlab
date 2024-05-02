%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIMULATION SCRIPTS FOR LOHNAS, POLYN AND KAHANA (in revision)
% Expanding the scope of memory search: Intralist and interlist 
% effects in free recall
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Developed by Lynn Lohnas
(Mostly, however, shamelessly modified from code by Sean Polyn and Per Sederberg)
ll95@nyu.edu

These scripts were written for use with Matlab version 7.8.0 (R2009a),
but should work with any recent version of Matlab. Before running the scripts, add this 
folder to your Matlab path or change the Matlab directory to this folder.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

===========
File Descriptions
===========


Simulation functions
=============

NOTE: by default, the simulation scripts assume that the LSA files are in the same directory as the model code. So you'll either need to move these files to be in the same directory as the simulation code, or change param.sem_path to reflect the directory of where the file is currently located.

run_fr.m - Using a param structure and data as input, simulates sessions of free recall.
This code can be used to generate model predictions for Simulations 1,2,4 in
the manuscript. See Helper Files below for loading in the relevant parameters. E.g.
run_fr(param, data)

simulate_fr.m - Given a param structure and a data structure, this
function will run a free recall session.  The function
creates the network and initializes it.  Then it presents the studied
items, runs the recall period, and records the responses into the data
structure. This function is called on by run_fr, and thus is used to generate
CMR2 predictions for Simulations 1,2,4 reported in the manuscript.

create_orthogonal_patterns.m - This function is used to create the orthonormal
feature vectors and the environment for presenting items.

init_network.m - This function initializes the
basic network structure, including the feature layer, the context layer, the 
associative weight matrices, and the learning rate matrices, to the values after
the first list has been presented. It also initializes 
the context sub-regions and creates the appropriate pre-experimental weights
between items. This code is perhaps the most dense, as we take advantage of 
vector and matrix properties to initialize everything at once, rather than presenting
one item at a time. Note that we can't take advantage of this on future lists, 
as it gets more complicated once items are retrieved and thus presented more than once.

create_semantic_structure.m - Set up the pre-experimental context-to-item
associations under the assumption that this matrix stores semantic information.

present_item.m - This function is called each time an item is presented.

ifr_recall_period.m - Simulates a recall period in immediate free recall. 

efr_recall_period.m - Simulates a recall period in externalized free recall. 

retrieve_item.m - Sets up the network and environment to retrieve an item from the
decision process, handles the output, and determines how much time has elapsed.

reactivate_item.m - This function is called each time an item is retrieved by the
model. It is identical to present_item except that the learning matrices don't get updated.

decision_accum.m - This function runs the decision competition.  This
is an iterative process in which a number of accumulators are racing
towards a recall threshold.  Once an item crosses threshold, it is
recalled, and the competition ends.

present_distraction.m - Presents a distractor/disruption item. This is identical to
present_item except that the learning matrices don't get updated.

run_lbl.m - Using a param structure as input, simulates sessions of the 
list-before-last paradigm. This code can be used to generate model predictions for
Simulation 3 by loading J08_param.

simulate_lbl.m - Given a param structure and a data structure, this
function will run a session of the list-before-last paradigm.  The function
creates the network and initializes it.  Then it presents the studied
items, runs the recall period, and records the responses into the data
structure. This function is called on by run_lbl, and thus is used to generate
CMR2 predictions for Simulation 3.

Analysis functions (type 'help FCN_NAME' for further details)
============

spc.m - Calculates a serial position curve from free recall data

crp.m - Calculates conditional response probability as a function of lag

lag_crp_pli.m - Calculates conditional response probability as a function
only for prior list intrusions (PLIs) when successively recalled from the 
same presentation list

list_lag_crp.m - Calculates conditional response probability as a function
of list-lag between two successively recalled prior-list intrusions.

p_rec.m - Calculates the probability of correct recall per trial for each subject.

p_reject.m - For the externalized free recall (EFR) experiment, returns the rejection probabilities for a given recalls matrix.

prop_pli.m - Calculates the probability of recall for PLIs per trial for each subject.

pli_recency.m - Calculates the proportion of PLIs recalled as a function of list recency.

prop_target.m - Calculates the proportion of target list recalls per trial for each subject, as a
function of between-list task and list-length.

prop_interv.m - Calculates the proportion of intervening list recalls per trial for each subject, as a function of between-list task.

Helper files
=======

For each reported simulation, there are 3 files required for simulations,
plus 1 wrapper function for analyses:
1) XY_data.mat - data structure (see Appendix B)
2) XY_param.mat - parameter structure (see Appendix A)
3) XY_LSA.mat - latent semantic analysis values for all items in the word pool
4) XY_plot.m - creates the plots/tables with the analyses reported in the manuscript
where X is the first letter of the last name of the first author of the
article from which the data was originally reported, and Y is the last
two digits of the year in which that article was published (or is currently
under review).

apply_by_index.m - This applies a particular function to each individual subject,
which is more efficient as less clunky than looping through subjects to calculate
each analysis.

apply_by_index_ordered.m - Same principles as the previous function, but this function ensures that the trials are in the same order as they were presented, which is a bit more time-consuming but necessary for intrusion information across sessions.

catcell.m - concatenates the row vectors in a cell array into a single vector

collect.m - Returns the number of times each of a set of values appears in a matrix.

count.m - Returns the number of times a value appears in a vector.

make_clean_recalls_mask2d.m - makes a logical matrix the same size a recalls matrix (see this function
or spc for more details, or examine data.recalls from any data structure for an example),
which is only true at output positions of items recalled for the first time from the correct list

make_intrusions.m - makes a matrix storing convenient information about recalled intrusions.

normalize_vector.m - normalizes a vector to have length 1.

publishFig.m - makes the figures look nicer.

possible_transitions - calculates the denominator for crp.m.

subj_means_across_sessions.m - for subjects who participated in multiple sessions of an experiment and the
number of observations differs across tasks, takes the mean across all sessions for a particular subject.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

======================
Common structures and variables
======================

Several structures are passed through the simulation scripts:

param: Structure containing relevant fixed parameter values and algorithm-determined
parameter values. It also carries some convenience fields allowing
one to alter aspects of the paradigm (e.g., length of the recall
period), and specifying paths for certain important files (e.g., the
semantic similarities between the studied items).

data: Structure containing the experimental and, when completed, simulated CMR2 data.
This records the behavioral responses from
the free recall paradigm, and other structural aspects of the paradigm.
data.net is set from running a simulation of CMR2, where the fields of data.net match data,
except that data.net is produced from the simulation rather than experimental data.

net: Structure containing information about the CMR2 network, 
i.e. the context and feature layers, and the associative weight matrices.

env: Structure containing information about what
is happening in the environment, such as the schedule of item
presentation, the length of the recall period, the item patterns, the
trial number, a record of the recalled items, and a few other fields.


Fields of the param structure that may change across simulations
=========================================

B_enc: beta_{enc} in the manuscript.  Context drift rate during the encoding period.

B_rec: beta_{rec} in the manuscript.  Context drift rate duringthe recall period.

p_scale: phi_s in the manuscript.  Determines the magnitude of the
primacy learning enhancement.

p_decay: phi_d in the manuscript.  Determines the timecourse of the
decay of the primacy learning enhancement.

K: kappa in the manuscript. The decay rate in the decision competition.

L: lambda in the manuscript. The lateral inhibition between items in the decision competition.

eta: The standard deviation of the Gaussian noise term in the decision
competition.  In the manuscript, eta = param.eta * sqrt(param.dt/param.tau) 

gamma_cf: Relative strength of pre-existing associations and experimental 
associations on the connections from context elements to feature elements.

B_end_list: beta^recall_post in the manuscript. Context drift rate after the recall period 
before the next study period begins.

gamma_fc: Relative strength of pre-existing associations and experimental 
associations on the connections from feature elements to context elements.

alpha, omega: parameters governing items' decision competition thresholds.

s: strength of semantic associations on w_cf (M^{CF}_{pre} in the manuscript).

c_thresh: minimum threshold that the dot product between a retrieved item's context
and the previous state of context have to exceed for the item to be recalled.

fixed for each simulation:

n_patterns: total number of unique items presented to the model, including disruption items.

thresh: The threshold for an accumulating element to win the decision
competition. See Equation for more details.

recall_task_fn: which type of recall function to use, i.e. standard free recall (Simulations 1,3,4)
or externalized free recall (Simulation 2). Note that this function is only defined based on how
items are verbalized, and thus this also can be used for the list-before-last paradigm. 

data_path: Path to the structure containing the lists of items to simulate with CMR2.

sem_path: Path to the LSA matrix containing the similarity values between all
the studied items.

nreruns: Number of times the experimental data is simulated with the model. Figures shown in the
article were generated with nreruns = 10, but by default we set nreruns = 1.

list_length: self-explanatory, but in principle this section lists all fields that change
across simulations. For Simulations 1,2,4 this is a scalar; for Simulation 3 this is a
vector with the list-length in a particular row corresponding to the just-presented list.

n_dimensions: number of dimensions for the context and feature layers and association matrices
(all set to be the same). for each of the simulations here, n_dimensions = n_patterns.

first_distraction_index: for clarity, we always assign the first x "patterns" or indices as the items being
presented, and then the distractors afterwards, so it's helpful to keep track of what the first
distractor's index should be. In an earlier version of this code, this number and n_patterns were calculated
based on the presented stimuli and disruption schedules, but given that these numbers don't change with
simulations and so don't have to be calculated anew each time, to (hopefully) make the code a little easier
by taking out a function, here they're just hard-coded.

rec_time: total "time" allowed for each recall period, matched to experiment.

max_outputs: maximum number of items that can be output, always equal to the
list-length. note that for accurate estimates of recall probability, CMR2 rarely uses this
restriction to limit output (instead, recall terminates based on rec_time, defined above).

npatterns_competing: number of patterns competing in the decision competition. for
computational reasons (and some limiting factors on the leaky accumulator process),
we limit this to be 4*list_length, though in Simulation 3 it's kept constant across recall periods.

lrate_fc_enc: Set to be param.gamma_fc.  The learning rate for the
associations from feature elements to context elements, M^{FC} (w_fc in net).

eye_fc: Set to 1 - param.gamma_fc.  Determines the strength of the
pre-existing associations  from feature elements to context elements.

lrate_cf_enc: learning rate for the source context to item features
associations in M^{CF} (w_cf in net).

eye_cf: Set to 1 - param.gamma_cf. Determines the strength of the
pre-existing associations from context elements to feature elements.

******** Special for Simulation 3

B_end_list_norecall: Context drift rate after list presentation and before presentation
of the next list when there is only a pause between lists. In the manuscript, beta^pause_post.

B_rec_target: In the manuscript, beta^in_rec. Context drift rate during recall once the model
is putatively recalling items IN the target list. (Here, B_rec is the context drift rate
during recall only for items OUTside the target list, corresponding to beta^out_rec.)

B_end_list_recall: Context drift rate after a recall period and before presentation
of the next list (i.e., analogous to B_end_list for standard FR tasks).

thresh_lblbl_last: minimum value that the dot product between an item's retrieved
context and the previous state of context must exceed for an item to be recalled.

thresh_lbl_last: when recall is outside the target list, the dot product between an item's
retrieved context and the previous state of context must be less than this value.

Fields of the network structure (net)
=======================

c_sub: each sub-field of this cell array contains information about a
different sub-region of the context layer.

f_sub: each sub-field of this cell array contains information about a
different sub-region of the feature layer.

pScale, pDecay: copied over from the param structure.

f: a vector containing the activation values of all of the feature
elements.

c: a vector containing the activation values of all of the context
elements. 

lrate_fc_enc, lrate_cf_enc: see values in param.

lrate_fc_rec, lrate_cf_rec: learning rates during recall. For all of the simulations
considered here, these are set to 0.

w_fc: the associative elements connecting each element of f to each
element of c (M^FC in manuscript).

w_cf: the associative elements connecting each element of c to each
element of c (M^CF in manuscript).

c_in: contains the most recent input to the context layer.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

======
Example
======

Assuming the data files are in the path DATAPATH, to the best-fit parameter set for Simulation 1:
param structures assume that all of the data and LSA files are the current folder.
If not, you will need to change param.data_path and param.sem_path
From a Matlab command window (either from the CMR2 directory or with CMR2
added to your path), type:
load K02_param; 
load DATAPATH/K02_data;
data = run_fr(param,data);
K02_plot

To run the best-fit parameter set for Simulation 2:

Because L13_data.mat has two data structures (data_efr,data_ifr), the
user must specify which data set to simulate. Further, this data set
has two param structures. These are identical except specifying 
the free recall function to use (EFR or IFR). To simulate both data sets:
load DATAPATH/L13_data;
load L13_param;
data_efr = run_fr(param_efr,data_efr);
data_ifr = run_fr(param_fr,data_ifr);
L13_plot(data_efr,data_ifr)

