Simulation scripts for Polyn et al., 2009

A Context Maintenance and Retrieval Model of Organizational Processes in Free Recall

Sean M. Polyn, Kenneth A. Norman, and Michael J. Kahana

Psychological Review, Vol. 116 (1), 129-156.

%%%%%%%%%%%%%%%%%%%

Developed by Sean Polyn
sean.polyn@vanderbilt.edu

Scripts, and the latest version of the CMR code, available from:

http://memory.psy.vanderbilt.edu/groups/vcml/wiki/618f3/CMR_Documentation.html

Behavioral Toolbox (Release 1) analysis code available from:

http://memory.psych.upenn.edu/behavioral_toolbox

Acknowledgements: 

Special thanks to Per Sederberg (persed@princeton.edu), for access to
all of his simulation code for TCM-A, upon which a number of these
algorithms were based.  Thanks to Josh McCluey, for preparing the code
for distribution, and to Lynn Lohnas and Neal Morton, for many helpful
suggestions and contributions.

Note:

Add the files in the CMR directory to your Matlab path, or navigate
Matlab to the CMR directory before running the scripts.

Good luck!  Don't panic!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

An overview of the software design
==================================

Several structures are passed back and forth by the simulation
scripts. 

The parameters structure (param).  This determines the configuration
of the CMR model.  It also carries some convenience fields allowing
one to alter aspects of the paradigm (e.g., length of the recall
period), and specifying paths for certain important files (e.g., the
semantic similarities between the studied items).

The data structure (data).  This records the behavioral responses from
the free recall paradigm, and other structural aspects of the
paradigm.  Most important is the recalls matrix (data.recalls), which
contains a record, for each trial, of the serial positions of the
recalled items.  More detail below (helper files).

The network structure (net).  This contains the network itself,
including the representational sub-areas, and the associative weight
matrices.  Some convenience matrices are also attached (e.g., the
semantic association values for the items on the most recent list).
The structure of the network is defined by the parameters structure.
More detail below (Appendix C).

The environment structure (env).  This contains information about what
is happening in the environment, such as the schedule of item
presentation, the length of the recall period, the item patterns, the
trial number, a record of the recalled items, and a few other fields.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

An overview of the scripts
==========================

param_cmr_full.m - This function will create a parameters structure
which can be passed into the simulation code.  The default parameters
are the best-fitting parameters for the Full version of the CMR model
from the manuscript.  Other parameter files:
 - param_cmr_m62.m: The parameters for the Murdock (1962) simulation.

run_taskFR.m - This function creates a data structure to simulate
the source-manipulation experiment described in the manuscript (also
known as 'taskFR').  Other run functions:
 - run_Murd62.m [run the Murdock (1962) experiment]

simulate_fr.m - Given a param structure and an env structure, this
function will run a number of trials of free recall.  The function
creates the network and initializes it.  Then it presents the studied
items, runs the recall period, and records the responses into the data
structure.  The experiment-specific information is specified in the
'run' function, and this same 'simulate_fr' function is used for all
of the simulations reported in the manuscript.

init_network.m - This function calls create_network, and then initializes the
basic network structure.  It initializes the context sub-regions and
creates the appropriate semantic connections based upon the items that
will be presented on the upcoming list.

create_network.m - This function creates the basic network structure,
including the feature layer, the context layer, the associative weight
matrices, and the learning rate matrices.

present_item.m - This function is called each time an item is
presented, updating the context of the network.

present_distraction.m - This function is called each time a task shift
causes a disruption to context during the study period.

fr_task.m - This function sets the network for recall mode by altering
context drift rate (B), which changes between study and recall.  It
runs the recall period and records the responses into the data structure.

recall_item.m - This function is called a number of times during the
recall period.  Each time it creates the input to the decision
competition function, calls the competition function, handles the
output, and determines how much time has elapsed.

decision_accum.m - This function runs the decision competition.  This
is an iterative process in which a number of accumulators are racing
towards a recall threshold.  Once an item crosses threshold, it is
recalled, and the competition ends.

reactivate_item.m - This function is called each time an item is
recalled, updating the context of the network.

context_update.m  This function is called each time an item is
activated in the network and updates the context.

Helper functions
================

calculate_session_patterns.m - Given a param structure, calculates the
number of presentation patterns used in the simulation and the index
of the first distraction.  This accounts for item presentations, task
shifts, and midlist and end-of-list distractions.

create_orthogonal_patterns.m - Returns an env structure which holds
the set of items that could possibly be presented.  Since CMR
currently uses localist item representations, this returns an identity
matrix for each pattern.

create_semantic_structure.m - Creates the appropriate semantic
connections based upon the items that will be presented.

normalize_vector.m - Returns a normalized vector from a given vector.
Used by context_update.

Helper files
============

LSA_tfr.mat - this matlab structure contains the LSA-derived
similarity values between the presented items (calculated as cos theta
of the LSA vectors for any two words).  Contains one cell array of
strings of length 1297, containing all of the words in the wordpool,
and one matrix 'LSA', 1297x1297, containing all of the similarities
between those words.

PolyEtal09_data.mat - this matlab structure contains the results of the
experiment reported in the manuscript.  The CMR code consults this
data structure to match the words presented in a given trial, and the
schedule of task shifts in a given trial.  Contains one structure,
'data', which contains a number of subfields: 'full', all the data
from the experiment; 'co', just the control trials; 'sh', just the
task shift trials.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

How to run the best-fitting parameter set for the source-manipulation
experiment (Table 1, CMR Full):

1) open up matlab
2) make sure the scripts in CMR are in your path, or that you are in
the CMR directory.
3) use the following matlab commands:

param = param_cmr_full;
datapath = 'PolyEtal09_data.mat';
net_data = run_taskFR(param,datapath);

4) to run basic analysis on the these data, follow the steps provided
in the docstring for analyze_taskFR.m (in CMR_repository/fr/TFR).  Then:

res = analyze_taskFR(net_data, sem_mat, noise_mat);

  *Note: Set datapath according to your local setup to point to the
  PolyEtal09_data.mat file located in fr/TFR/

  *Note: Depending on your local setup, you may need to adjust
  param.sem_path{1} to point to the LSA_tfr.mat file located in resources/

How to run the Murdock (1962) simulation:

1) same as above but use the following matlab commands instead:

param = param_cmr_m62;
net_data = run_Murd62(param);
res = analyze_Murd62(net_data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Appendix A.  A list of the fields of the parameters structure:

subregions:  Number of subregions in the network; both feature and
context representations can have subregions.

pres_indices: [description needed]

not_presented_indices:  A cell array in which each cell contains the
indices of the items that are recallable by the network but are not
ever presented to the network.

custom_context_fn:  Handle for the function to perform context update.

c_in_norm: Vector that is 1 to indicate subregions where input context
should be normalized before update, and 0 to indicate that input
context should not be normalized.

recall_task_fn:  Handle for the function to run the recall period.

post_recall_decision:  Not used for these simulations - Check the Polyn Lab CMR
documentation for a description of this parameter.

reset:  Flag; if true, item values are reset to 95% of what they
were previously after being recalled.  This is one way to ensure that
items are not recalled again and again.

can_repeat:  Indicates whether an item can be recalled more than once.

alpha: Not used for these simulations - Check the Polyn Lab CMR
documentation for a description of this parameter.

omega: Not used for these simulations - Check the Polyn Lab CMR
documentation for a description of this parameter.

B_enc:  [beta^{temp}_{enc}   beta^{source}_{enc}] in the manuscript.
A vector of the context integration rate for the temporal and source
context sub-regions during the encoding / study period.

B_rec:  [beta^{temp}_{rec}   beta^{source}_{rec}] in the manuscript.
A vector containing the context integration rate for the temporal and
source context sub-regions during the recall period.

  Note:  The source context integration rates are constrained to be
  equal to one another in the reported simulations.

p_scale: phi_s in the manuscript.  Determines the magnitude of the
primacy learning enhancement.

p_decay: phi_d in the manuscript.  Determines the timecourse of the
decay of the primacy learning enhancement.

gamma_fc: This factor determines the relative strength of pre-existing
associations and experimental associations on the connections between
feature elements and context elements.

lrate_fc_enc: Controls the strength of associations between feature
and context vectors.  FC = feature-to-context; enc = during study / encoding.

lrate_cf_enc: Controls the strength of associations between feature
and context vectors.  CF = context-to-feature; enc = during study / encoding.

lrate_fc_rec: Controls the strength of associations between feature
and context vectors.  FC = feature-to-context; rec = during recall

lrate_cf_rec: Controls the strength of associations between feature
and context vectors.  CF =; rec = during recall

eye_fc: Set to be 1 - param.gamma_fc.  Determines the strength of the
pre-existing associations between feature elements and context
elements.  (eye means "identity matrix", which is how this is
implemented if items are represented as orthonormal vectors)

eye_cf: Set to 0 for the reported simulations (although this parameter
is important for TCM-A fits reported in Sederberg et al., 2008).
Determines the strength of the pre-existing associtions between
context elements and feature elements.

s: A scaling factor for the strength of semantic associations on w_cf
(M^cf in the manuscript).

K: The decay rate for the accumulating elements in the decision competition.

L: The lateral inhibition between units in the decision competition.

eta: The standard deviation of the gaussian noise term in the decision
competition.  In the manuscript, eta = param.eta * sqrt(param.dt/param.tau) 

tau: A time constant in the decision process.  In the manuscript tau =
param.dt / param.tau.

dt: Another time constant on the decision process.  Set to 100 for all
reported simulations.

thresh: The threshold for an accumulating element to win the decision
competition.  Fixed at 1.0 for all reported simulations.

rec_time: The recall process ends when the decision process runs for
this number of cycles.  Fixed to 90000 (interpreted as 90 seconds) for
all reported simulations.

recall_regions:  Specifies which network subregion corresponds to items to
be recalled.  The patterns presented to the specified subregion
compete during the recall process.

init_orthogonal_index: a flag, if true, then each specified context
subregion is initialized to a state that is orthogonal to the study patterns. 

has_semantic_structure:  Specifies whether the subregion has a
semantic structure indictating semantic connections.

sem_path:  A cell array containing the path to the LSA matrix
containing the similarity scores between all the studied items.

orthogonal_patterns:  Specifies whether the model is run using
othogonal patterns, if true, the simple model of semantic associations
can be used.

do_cdfr:  Specifies whether the model is run using a continuous
distractor during the study period.

cdfr_schedule: Specifies the amount of disruption caused by
distraction. Used as a temporary value of beta, the context
integration parameter, as an orthogonal distraction item is presented
to the network. cdfr_schedule(i,j) gives beta for the distraction
preceding list i, item j.

cdfr_disrupt_regions: If do_cdfr is true, specifies which context
regions are disrupted by distraction.

do_dfr:  Specifies whether the model is run using delayed free recall,
with a distractor between the study and recall periods.

dfr_schedule: Specifies the amount of disruption caused by
distraction. Used as a temporary value of beta, the context
integration parameter, as an orthogonal distraction item is presented
to the network. dfr_schedule(i) gives beta for list i.

dfr_disrupt_regions: If do_cdfr is true, specifies which context
regions are disrupted by distraction.

do_shift:  Specifies whether context shifts during the study
period has a disruptive effect on the specified context regions.

shift_trigger_regions: If do_shift is true, this specifies which
context regions can trigger a disruptive shift.

shift_disrupt_regions: If do_shift is true, this specifies which
context regions are disrupted by a shift.

shift_schedule: Specifies the amount of disruption caused by a shift.
This number is used as a temporary value of beta, the context
integration parameter, as an orthogonal distraction item is presented
to the network.   

do_end_list:  A flag, if true, there is disruption to context after
the recall period, prior to the next trial.  This only has an effect
if multiple trials of free recall are being simulated in the same call
to simulate_fr.  (the TFR and M62 simulations do not use this)

end_schedule: Specifies the amount of disruption caused by distraction
before starting a new list. Used as a temporary value of beta, the
context integration parameter, as an orthogonal distraction item is
presented to the network. end_schedule(i) gives beta for distraction
after list i. There is no distraction after the last list.

end_disrupt_regions: If do_end_list is true, specifies which context
regions are disrupted by post-list distraction.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Appendix B.  A list of the fields of the data structure (data).

[field descriptions needed]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Appendix C.  A list of the fields of the network structure (net).

c_sub: each sub-field of this cell array contains information about a
different sub-region of context.

f_sub: each sub-field of this cell array contains information about a
different sub-region of the feature layer.

f: a vector containing the activation values of all of the feature
elements.

c: a vector containing the activation values of all of the context
elements. 

lrate_fc: a matrix containing the learning rate for each of the
associative elements in w_fc.

lrate_cf: a matrix containing the learning rate for each of the
associative elements in w_cf.

lrate_fc_enc, lrate_cf_enc.  These matrices determine the values of the
above matrices during study.

lrate_fc_rec, lrate_cf_rec: These matrices determine the values of the
above matrices during recall.

w_fc: the associative elements connecting each element of f to each
element of c.

w_cf: the associative elements connecting each element of c to each
element of c.

c_in: contains the most recent input to the context layer.  This is
saved for the user's convenience.

sem_mat: contains the semantic association values for the items on the
current list, pulled from the LSA similarity matrix.  This is for the
user's convenience.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Appendix D.  A list of the fields of the environment structure (env).

present_index: 

present_distraction_index:

init_index: 

patterns: 

pool_to_item_map:

timer:

list_index:

list_num:

n_presented_items:
 
[other field descriptions needed]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Appendix E.  FAQ (questions that haven't been asked but might):

Q1.  The parameters in your param_cmr_*.m files do not match those
reported in the Polyn et al. manuscript.  Why?

A1.  Some notational choices were made in preparing the manuscript.
In two cases these change the values of parameters reported (eta and
tau of the decision process), and in the rest, these just correspond
to slightly different names.  A rundown:

 - the symbol tau (in the manuscript) = param.dt / param.tau 
 - the symbol eta (in the manuscript) = param.eta * sqrt(param.dt/param.tau)
 - the symbol beta (in manuscript) is B here.
 - the symbol L^{CF}_{sw} is a subset of lrate_cf here.
 - the symbol L^{CF}_{tw} is a subset of lrate_cf here, and is fixed at 1.
 - the symbols phi_s and phi_d are param.p_scale and param.p_decay,
   respectively. 

Q2.  The code is crashing because it can't find my semantic similarity
matrix!

A2.  First, make sure that the CMR directory is in your Matlab path.
Alternately, make sure the path in your param structure specified in
param.sem_path corresponds to the location of your semantic similarity
file on your local disk.

Q3.  When I run analysis X, the result mismatches the published
version by [some small amount].  What is responsible for this discrepancy?  

A3.  There are a number of reasons that the analysis code provided
here may mismatch the published version by a small amount.  If the
analysis is on simulated data, the model is stochastic, and will
produce slightly different results each time.  For analysis on the
behavioral data, there are a number of possibilities: (1) the
published analyses used a slightly different semantic matrix than the
one provided here (though they are both based on the LSA project and
are very similar to one another); (2) some of the relabeling analyses
are stochastic and will change a small amount when re-run; (3) the
original versions of certain analyses may have selected slightly
different sets of recall transitions than the current scripts (e.g.,
which trials were considered practice).  For large discrepancies,
there is certainly the possibility of a bug in the distributed
software, so we'd appreciate hearing about it!

Q4.  How do I run all the fancy behavioral analyses you reported in
the manuscript?

A4.  We are working on a second distribution to accompany this one that
helps one do all sorts of fancy behavioral analyses of recall
sequences.  The documentation is the tricky part!  Email me if you
want to be notified of such a release.


