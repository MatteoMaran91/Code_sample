%%  In Step08_Cluster_stast we
%%
% 1. Import the struc for stats generated in Create_struct_stats
% 2. Run the cluster-based permuation test for the main effect of grammaticality
% 3. Run the cluster-based permuation test for the main effect of TMS
% 4. Run the cluster-based permuation test for the Gram*TMS interaction
%
% This stats are run in the time-window 0-1, as they are the mains stats of
% interest
%
% Matteo Maran
% 23 April 2020 - used and updated on 19 May 2020 
% Outputs in: twInterest_stats_results_20200519_133300/
% <maran@cbs.mpg.de>
% <matteo.maran.1991@gmail.com>

% Cluster-based permutation test settings http://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/#within-subjects-experiments
clear;
%% FOLDERS
fieldtrip_fold      = '/data/p_02142/data_analysis_2020/fieldtrip-20200115';
analysis_fold       = '/data/p_02142/data_analysis_2020/eeg_analysis_outputs';
subjfile_fold       = '/data/p_02142/data_analysis_2020/new_subj_files/';
script_fold         =  '/data/p_02142/data_analysis_2020/scripts/eeg_analysis';
main_input_fold     = '/data/p_02142/data_analysis_2020/eeg_analysis_outputs/baseline_stat_folder/';

% Create a unique stat folder with time in the folder name
d = yyyymmdd(datetime('now'));
[h,m,s] = hms(datetime('now'));
cur_time = [num2str(d), '_',  sprintf('%02d',h), sprintf('%02d',m),  sprintf('%02d',round(s))];
stat_output_fold    = [main_input_fold, 'twInterest_stats_results_', cur_time, filesep];
if ~isfolder(stat_output_fold)
    mkdir(stat_output_fold);
end
addpath(fieldtrip_fold);
addpath(analysis_fold);
addpath(subjfile_fold);
addpath(script_fold);
addpath(main_input_fold);


%% LOAD THE STRUCT FOR STATISTICS
% In main_input_fold we have the structs for stats, defined as all_[exp condition and/or TMS].mat
%Baseline2_Create_struct_stats;
% my_struc2import = dir([main_input_fold 'all*.mat']);
% for struci = 1:length(my_struc2import)
%       cur_strucfile = [main_input_fold,my_struc2import(struci).name]; % current file
%       load(cur_strucfile); disp(['Loading....', cur_strucfile]);
% end

% We load only the struct of interest
load([main_input_fold, 'all_NoBas_BA44_cor.mat']);
load([main_input_fold, 'all_NoBas_BA44_inc.mat']);
load([main_input_fold, 'all_NoBas_SPL_cor.mat']);
load([main_input_fold, 'all_NoBas_SPL_inc.mat']);
load([main_input_fold, 'all_NoBas_sham_cor.mat']);
load([main_input_fold, 'all_NoBas_sham_inc.mat']);

load([main_input_fold, 'all_NoBas_main_BA44.mat']);
load([main_input_fold, 'all_NoBas_main_SPL.mat']);
load([main_input_fold, 'all_NoBas_main_sham.mat']);

load([main_input_fold, 'all_NoBas_main_cor.mat']);
load([main_input_fold, 'all_NoBas_main_inc.mat']);
%% DEFINE THE NEIGHBOURS TO BE USED FOR STATS (SAME AS THE ONES USED FOR INTERPOLATION)
% Load the template previously used
neighbour_file = '/data/p_02142/data_analysis_2020/scripts/utilities/new_templates/updated_20200309_164202_easycapM11_neighb.mat';
load(neighbour_file);
Nsub = length(all_NoBas_BA44_cor);


%% STAT MAIN EFFECT OF GRAMMATICALITY and GRAM IN EACH CONDITION
cfg = [];
cfg.channel     = 'EEG';
cfg.neighbours  = neighbours; % defined a1s above
cfg.latency     = [0 1];
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 2;
cfg.neighbours = neighbours;  % same as defined for the between-trials experiment
cfg.tail = 0;
cfg.clustertail = 0;
cfg.alpha = 0.025;
cfg.numrandomization = 5000;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
% Main effect of gram
noBas_main_gram_stat = ft_timelockstatistics(cfg, all_NoBas_main_inc{:}, all_NoBas_main_cor{:});
% Gram in BA44
noBas_BA44_gram_stat = ft_timelockstatistics(cfg, all_NoBas_BA44_inc{:}, all_NoBas_BA44_cor{:});
% Gram in SPL
noBas_SPL_gram_stat = ft_timelockstatistics(cfg, all_NoBas_SPL_inc{:}, all_NoBas_SPL_cor{:});
% Gram in sham
noBas_sham_gram_stat = ft_timelockstatistics(cfg, all_NoBas_sham_inc{:}, all_NoBas_sham_cor{:});

%% Export 
% Main
cur_main_gram_file = [stat_output_fold, 'noBas_main_gram_stat.mat'];
if ~isfile(cur_main_gram_file); save(cur_main_gram_file, 'noBas_main_gram_stat', '-v7.3');end
% BA44
cur_BA44_gram_file = [stat_output_fold, 'noBas_BA44_gram_stat.mat'];
if ~isfile(cur_BA44_gram_file); save(cur_BA44_gram_file, 'noBas_BA44_gram_stat', '-v7.3');end
% SPL
cur_SPL_gram_file = [stat_output_fold, 'noBas_SPL_gram_stat.mat'];
if ~isfile(cur_SPL_gram_file); save(cur_SPL_gram_file, 'noBas_SPL_gram_stat', '-v7.3');end
% sham
cur_sham_gram_file = [stat_output_fold, 'noBas_sham_gram_stat.mat'];
if ~isfile(cur_sham_gram_file); save(cur_sham_gram_file, 'noBas_sham_gram_stat', '-v7.3');end

%% TMS MAIN EFFECT
cfg = [];
cfg.channel     = 'EEG';
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = [0 1];
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesFunivariate';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 2;
cfg.neighbours = neighbours;  % same as defined for the between-trials experiment
cfg.tail = 1;  % If 0: For a dependent samples F-statistic, it does not make sense to calculate a two-sided critical value
cfg.clustertail = 1;% If 0: For a dependent samples F-statistic, it does not make sense to calculate a two-sided critical value
cfg.alpha = 0.05;  % I would have used 0.025 for cfg.tail and cfg.clustertail= 0
cfg.numrandomization = 5000;
cfg.design(1,1:3*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub) 3*ones(1,Nsub)];
cfg.design(2,1:3*Nsub)  = [1:Nsub 1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
noBas_main_TMS_stat = ft_timelockstatistics(cfg, all_NoBas_main_BA44{:}, all_NoBas_main_SPL{:}, all_NoBas_main_sham{:});

% Export the stat
cur_main_TMS_file = [stat_output_fold, 'noBas_main_TMS_stat.mat'];
if ~isfile(cur_main_TMS_file); save(cur_main_TMS_file, 'noBas_main_TMS_stat', '-v7.3');end

%% INTERACTION TMS*GRAM- PREPARE THE DIFF WAVES FOR CLUSTER STATISTIC
% Load these structures if they exist, or create them
% Define the filenames
all_NoBas_BA44_diffwave_outfile = [main_input_fold, 'all_NoBas_BA44_diffwave.mat', '-v7.3'];
all_NoBas_SPL_diffwave_outfile  = [main_input_fold, 'all_NoBas_SPL_diffwave.mat', '-v7.3'];
all_NoBas_sham_diffwave_outfile = [main_input_fold, 'all_NoBas_sham_diffwave.mat', '-v7.3'];

% Load if they exsist
if isfile(all_NoBas_BA44_diffwave_outfile) && isfile(all_NoBas_SPL_diffwave_outfile) && isfile(all_NoBas_sham_diffwave_outfile)
    load(all_NoBas_BA44_diffwave_outfile);
    load(all_NoBas_SPL_diffwave_outfile);
    load(all_NoBas_SPL_diffwave_outfile);
else
    % Create them
    all_NoBas_BA44_diffwave = cell(Nsub,1);
    all_NoBas_SPL_diffwave  = cell(Nsub,1);
    all_NoBas_sham_diffwave = cell(Nsub,1);
    % Loop through the subject and calculate the ELAN for each TMS of condition
    for subi = 1:Nsub
        % Calcualte diff wave
        cfg = [];
        cfg.operation = 'subtract';
        cfg.parameter = 'avg';
        c_NoBas_BA44_ELAN = ft_math(cfg,all_NoBas_BA44_inc{subi}, all_NoBas_BA44_cor{subi});
        c_NoBas_SPL_ELAN  = ft_math(cfg,all_NoBas_SPL_inc{subi}, all_NoBas_SPL_cor{subi});
        c_NoBas_sham_ELAN = ft_math(cfg,all_NoBas_sham_inc{subi}, all_NoBas_sham_cor{subi});
        % Place them in the cell
        all_NoBas_BA44_diffwave{subi} = c_NoBas_BA44_ELAN;
        all_NoBas_SPL_diffwave{subi}  = c_NoBas_SPL_ELAN;
        all_NoBas_sham_diffwave{subi} = c_NoBas_sham_ELAN;
        clear c_NoBas_BA44_ELAN c_NoBas_SPL_ELAN c_NoBas_sham_ELAN
    end 
    % As they do not exist yet, save the structures for eventual possible sue
    save(all_NoBas_BA44_diffwave_outfile, 'all_NoBas_BA44_diffwave', '-v7.3');
    save(all_NoBas_SPL_diffwave_outfile, 'all_NoBas_SPL_diffwave', '-v7.3');
    save(all_NoBas_sham_diffwave_outfile, 'all_NoBas_sham_diffwave', '-v7.3');    
end


%% TMS*GRAM INTERACTION
cfg = [];
cfg.channel     = 'EEG';
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = [0 1];
cfg.avgovertime = 'no';
cfg.parameter   = 'avg';
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesFunivariate';
cfg.correctm = 'cluster';
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan = 2;
cfg.neighbours = neighbours;  % same as defined for the between-trials experiment
cfg.tail = 1;  % If 0: For a dependent samples F-statistic, it does not make sense to calculate a two-sided critical value
cfg.clustertail = 1;% If 0: For a dependent samples F-statistic, it does not make sense to calculate a two-sided critical value
cfg.alpha = 0.05;  % I would have used 0.025 for cfg.tail and cfg.clustertail= 0
cfg.numrandomization = 5000;
cfg.design(1,1:3*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub) 3*ones(1,Nsub)];
cfg.design(2,1:3*Nsub)  = [1:Nsub 1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
noBas_GramTMS_interaction_stat = ft_timelockstatistics(cfg, all_NoBas_BA44_diffwave{:}, all_NoBas_SPL_diffwave{:}, all_NoBas_sham_diffwave{:});

% Export the stat
cur_GramTMS_file = [stat_output_fold, 'noBas_GramTMS_interaction_stat.mat'];
if ~isfile(cur_GramTMS_file); save(cur_GramTMS_file, 'noBas_GramTMS_interaction_stat', '-v7.3');end


