% Step07 - Create structure for stats
%%  In Step07 - Create structure for stats:
%%
% 1. Import time-locked data from Prepare_TimeLock.m
% 2. Generate the 3 struct to analyze the main effect of grammaticality
% 3. Generate the 3 struct to analyze the main effect of TMS
% 4. Generate the 6 struct to analyze the TMS*grammaticality interaction
%
% Used and updated on May 19, 2020
% Matteo Maran
% <maran@cbs.mpg.de>
% <matteo.maran.1991@gmail.com>

clear;
%% FOLDERS
fieldtrip_fold = '/data/p_02142/data_analysis_2020/fieldtrip-20200115';
analysis_fold = '/data/p_02142/data_analysis_2020/eeg_analysis_outputs';
subjfile_fold = '/data/p_02142/data_analysis_2020/new_subj_files/';
script_fold  =  '/data/p_02142/data_analysis_2020/scripts/eeg_analysis';
main_input_fold = '/data/p_02142/data_analysis_2020/eeg_analysis_outputs/';

addpath(fieldtrip_fold);
addpath(analysis_fold);
addpath(subjfile_fold);
addpath(script_fold);
addpath(main_input_fold);

%% DEFINE STEP, SUBJ AND TMS, INITIALIZE STRUCTS
my_tms            = {'BA44', 'SPL', 'sham'};
my_subj           = [1:8,10:28,30,33];

% Structures for main effect of grammaticality
all_NoBas_main_cor = cell(length(my_subj),1);
all_NoBas_main_inc = cell(length(my_subj),1);

% Structures for main effect of tms
all_NoBas_main_BA44 = cell(length(my_subj),1);
all_NoBas_main_SPL  = cell(length(my_subj),1);
all_NoBas_main_sham = cell(length(my_subj),1);

% Structures for interaction tms*gram
all_NoBas_BA44_cor = cell(length(my_subj),1);
all_NoBas_BA44_inc = cell(length(my_subj),1);
all_NoBas_SPL_cor  = cell(length(my_subj),1);
all_NoBas_SPL_inc  = cell(length(my_subj),1);
all_NoBas_sham_cor = cell(length(my_subj),1);
all_NoBas_sham_inc = cell(length(my_subj),1);

% Structures for dn/dv/pn/pv analysis
all_NoBas_main_dn = cell(length(my_subj),1);
all_NoBas_main_dv = cell(length(my_subj),1);
all_NoBas_main_pn = cell(length(my_subj),1);
all_NoBas_main_pv = cell(length(my_subj),1);

% Structures for dn/dv/pn/pv analysis in each TMS
all_NoBas_BA44_dn = cell(length(my_subj),1);
all_NoBas_BA44_dv = cell(length(my_subj),1);
all_NoBas_BA44_pn = cell(length(my_subj),1);
all_NoBas_BA44_pv = cell(length(my_subj),1);
all_NoBas_SPL_dn = cell(length(my_subj),1);
all_NoBas_SPL_dv = cell(length(my_subj),1);
all_NoBas_SPL_pn = cell(length(my_subj),1);
all_NoBas_SPL_pv = cell(length(my_subj),1);
all_NoBas_sham_dn = cell(length(my_subj),1);
all_NoBas_sham_dv = cell(length(my_subj),1);
all_NoBas_sham_pn = cell(length(my_subj),1);
all_NoBas_sham_pv = cell(length(my_subj),1);

%% LOOPING
for subi = 1:length(my_subj)
    c_subj = my_subj(subi);
    c_sub_infold = [main_input_fold,  'outVP', sprintf('%02d',c_subj), filesep,'noBas/'];
    disp(['########### Loading data for subj', sprintf('%02d',c_subj), ' from ' c_sub_infold]);
    
    %% LOAD THE DATA - COR/INC
    % Load all the cor_avg and inc_avg for the tms conditions and renamed them
    % Load BA44 data
    BA44_cor_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_BA44_cor_avg.mat'];
    BA44_inc_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_BA44_inc_avg.mat'];
    load(BA44_cor_infile); disp(['Loading...',BA44_cor_infile]);
    load(BA44_inc_infile); disp(['Loading...', BA44_inc_infile]);
    c_BA44_cor = cor_avg;
    c_BA44_inc = inc_avg;
    clear cor_avg inc_avg BA44_cor_infile BA44_inc_infile
    
    % Load SPL data
    SPL_cor_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_SPL_cor_avg.mat'];
    SPL_inc_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_SPL_inc_avg.mat'];
    load(SPL_cor_infile); disp(['Loading...',SPL_cor_infile]);
    load(SPL_inc_infile); disp(['Loading...', SPL_inc_infile]);
    c_SPL_cor = cor_avg;
    c_SPL_inc = inc_avg;
    clear cor_avg inc_avg SPL_cor_infile SPL_inc_infile
    
    % Load sham data
    sham_cor_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_sham_cor_avg.mat'];
    sham_inc_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_sham_inc_avg.mat'];
    load(sham_cor_infile); disp(['Loading...',sham_cor_infile]);
    load(sham_inc_infile); disp(['Loading...',sham_inc_infile]);
    c_sham_cor = cor_avg;
    c_sham_inc = inc_avg;
    clear sham_cor_infile sham_inc_infile cor_avg inc_avg

    %% FOR MAIN EFFECT OF TMS - PREPARE AND ASSIGN TO ALL_MAIN_[TMS]
    % Average correct and incorrect avg within each tms and assign the resulting variable to all_main_BA44/SPL/sham
    
    % Average BA44 correct and incorrect waveforms to create an ERP for main effect of grammaticality
    cfg = [];
    c_main_BA44 = ft_timelockgrandaverage(cfg, c_BA44_cor, c_BA44_inc);
    % Assign to the main structure for BA44
    all_NoBas_main_BA44{subi} = c_main_BA44;
    
    % Average SPL correct and incorrect waveforms to create an ERP for main effect of grammaticality
    cfg = [];
    c_main_SPL = ft_timelockgrandaverage(cfg, c_SPL_cor, c_SPL_inc);
    % Assign to the main structure for SPL
    all_NoBas_main_SPL{subi} = c_main_SPL;
    
    % Average sham correct and incorrect waveforms to create an ERP for main effect of grammaticality
    cfg = [];
    c_main_sham = ft_timelockgrandaverage(cfg, c_sham_cor, c_sham_inc);
    % Assign to the main structure for SPL
    all_NoBas_main_sham{subi} = c_main_sham;
    
    clear c_main_BA44 c_main_SPL c_main_sham
    
    %% LOAD THE DATA - DN/DV/PN/PV 
    % BA44
    BA44_dn_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_BA44_dn_avg.mat'];
    BA44_dv_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_BA44_dv_avg.mat'];
    BA44_pn_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_BA44_pn_avg.mat'];
    BA44_pv_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_BA44_pv_avg.mat'];
    load(BA44_dn_infile); disp(['Loading...',BA44_dn_infile]);
    load(BA44_dv_infile); disp(['Loading...', BA44_dv_infile]);
    load(BA44_pn_infile); disp(['Loading...',BA44_pn_infile]);
    load(BA44_pv_infile); disp(['Loading...', BA44_pv_infile]);
    c_BA44_dn = dn_avg;
    c_BA44_dv = dv_avg;
    c_BA44_pn = pn_avg;
    c_BA44_pv = pv_avg;   
    clear dn_avg dv_avg  pn_avg  pv_avg BA44_dn_infile BA44_dv_infile BA44_pn_infile BA44_pv_infile
    % SPL
    SPL_dn_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_SPL_dn_avg.mat'];
    SPL_dv_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_SPL_dv_avg.mat'];
    SPL_pn_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_SPL_pn_avg.mat'];
    SPL_pv_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_SPL_pv_avg.mat'];
    load(SPL_dn_infile); disp(['Loading...',SPL_dn_infile]);
    load(SPL_dv_infile); disp(['Loading...', SPL_dv_infile]);
    load(SPL_pn_infile); disp(['Loading...',SPL_pn_infile]);
    load(SPL_pv_infile); disp(['Loading...', SPL_pv_infile]);
    c_SPL_dn = dn_avg;
    c_SPL_dv = dv_avg;
    c_SPL_pn = pn_avg;
    c_SPL_pv = pv_avg;   
    clear dn_avg dv_avg  pn_avg  pv_avg SPL_dn_infile SPL_dv_infile SPL_pn_infile SPL_pv_infile
    % sham
    sham_dn_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_sham_dn_avg.mat'];
    sham_dv_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_sham_dv_avg.mat'];
    sham_pn_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_sham_pn_avg.mat'];
    sham_pv_infile = [c_sub_infold, 'noBas_Sub', sprintf('%02d',c_subj), '_sham_pv_avg.mat'];
    load(sham_dn_infile); disp(['Loading...',sham_dn_infile]);
    load(sham_dv_infile); disp(['Loading...', sham_dv_infile]);
    load(sham_pn_infile); disp(['Loading...',sham_pn_infile]);
    load(sham_pv_infile); disp(['Loading...', sham_pv_infile]);
    c_sham_dn = dn_avg;
    c_sham_dv = dv_avg;
    c_sham_pn = pn_avg;
    c_sham_pv = pv_avg;   
    clear dn_avg dv_avg  pn_avg  pv_avg sham_dn_infile sham_dv_infile sham_pn_infile sham_pv_infile

    %% FOR MAIN EFFECT OF GRAM - PREPARE AND ASSIGN TO all_NoBas_MAIN_[TMS]
    % Average correct ERPs of the different TMS cond (c_BA44_cor, c_SPL_cor, c_sham_cor) and the same for incorrect
    % in order to have a main response of gramamticality for each subject
    
    % Average ERP for cor of the different TMS
    cfg = [];
    c_main_cor = ft_timelockgrandaverage(cfg, c_BA44_cor, c_SPL_cor, c_sham_cor);
    % Store to struct for stats
    all_NoBas_main_cor{subi} = c_main_cor;
    % Average ERP for inc of the different TMS
    cfg = [];
    c_main_inc = ft_timelockgrandaverage(cfg, c_BA44_inc, c_SPL_inc, c_sham_inc);
    % Store to struct for stats
    all_NoBas_main_inc{subi} = c_main_inc;
    
    % main_dn/dv/pn/pv averaging across TMS
    cfg = [];
    c_main_dn = ft_timelockgrandaverage(cfg, c_BA44_dn, c_SPL_dn, c_sham_dn);
    c_main_dv = ft_timelockgrandaverage(cfg, c_BA44_dv, c_SPL_dv, c_sham_dv);
    c_main_pn = ft_timelockgrandaverage(cfg, c_BA44_pn, c_SPL_pn, c_sham_pn);
    c_main_pv = ft_timelockgrandaverage(cfg, c_BA44_pv, c_SPL_pv, c_sham_pv);
    
    % Store to struct for stats
    all_NoBas_main_dn{subi} = c_main_dn;
    all_NoBas_main_dv{subi} = c_main_dv;
    all_NoBas_main_pn{subi} = c_main_pn;
    all_NoBas_main_pv{subi} = c_main_pv;  
    
    clear c_main_dn c_main_dv c_main_pn c_main_pv c_main_cor c_main_inc;
    
    %% STORE FOR PHRASE*GRAM in each TMS 
    all_NoBas_BA44_dn{subi} = c_BA44_dn;
    all_NoBas_BA44_dv{subi} = c_BA44_dv;
    all_NoBas_BA44_pn{subi} = c_BA44_pn;
    all_NoBas_BA44_pv{subi} = c_BA44_pv;
    
    all_NoBas_SPL_dn{subi} = c_SPL_dn;
    all_NoBas_SPL_dv{subi} = c_SPL_dv;
    all_NoBas_SPL_pn{subi} = c_SPL_pn;
    all_NoBas_SPL_pv{subi} = c_SPL_pv;  
    
    all_NoBas_sham_dn{subi} = c_sham_dn;
    all_NoBas_sham_dv{subi} = c_sham_dv;
    all_NoBas_sham_pn{subi} = c_sham_pn;
    all_NoBas_sham_pv{subi} = c_sham_pv;     
    clear c_BA44_dn c_BA44_dv c_BA44_pn c_BA44_pv c_SPL_dn c_SPL_dv c_SPL_pn c_SPL_pv c_sham_dn c_sham_dv c_sham_pn c_sham_pv   
    %% FOR TMS*GRAM INTERACTION - ASSIGN TO THE STRUCT
    % No need for averaging here as we already have the .avg for each of the cell of the interaction   
    all_NoBas_BA44_cor{subi} = c_BA44_cor;
    all_NoBas_BA44_inc{subi} = c_BA44_inc;
    all_NoBas_SPL_cor{subi}  = c_SPL_cor;
    all_NoBas_SPL_inc{subi}  = c_SPL_inc;
    all_NoBas_sham_cor{subi} = c_sham_cor;
    all_NoBas_sham_inc{subi} = c_sham_inc;   
    clear c_BA44_cor c_BA44_inc c_SPL_cor c_SPL_inc c_sham_cor c_sham_inc
    
    disp(['Sub:', num2str(c_subj), ' - ALL WELL AND DONE!:)']);
end

%% EXPORT THE STRUCTURES
bas_stat_folder = [main_input_fold, 'baseline_stat_folder', filesep];
if ~isfolder(bas_stat_folder)
    mkdir(bas_stat_folder);
end

% Define outputfilenames and export structs
% 1. Main gram
all_NoBas_main_cor_outfile = [bas_stat_folder, 'all_NoBas_main_cor.mat'];
all_NoBas_main_inc_outfile = [bas_stat_folder, 'all_NoBas_main_inc.mat'];
if ~isfile(all_NoBas_main_cor_outfile)
    save(all_NoBas_main_cor_outfile, 'all_NoBas_main_cor');
end
if ~isfile(all_NoBas_main_inc_outfile)
    save(all_NoBas_main_inc_outfile, 'all_NoBas_main_inc');
end
% 2. Gram in tms
all_NoBas_BA44_cor_outfile = [bas_stat_folder, 'all_NoBas_BA44_cor.mat'];
all_NoBas_BA44_inc_outfile = [bas_stat_folder, 'all_NoBas_BA44_inc.mat'];
if ~isfile(all_NoBas_BA44_cor_outfile)
    save(all_NoBas_BA44_cor_outfile, 'all_NoBas_BA44_cor');
end
if ~isfile(all_NoBas_BA44_inc_outfile)
    save(all_NoBas_BA44_inc_outfile, 'all_NoBas_BA44_inc');
end
all_NoBas_SPL_cor_outfile = [bas_stat_folder, 'all_NoBas_SPL_cor.mat'];
all_NoBas_SPL_inc_outfile = [bas_stat_folder, 'all_NoBas_SPL_inc.mat'];
if ~isfile(all_NoBas_SPL_cor_outfile)
    save(all_NoBas_SPL_cor_outfile, 'all_NoBas_SPL_cor');
end
if ~isfile(all_NoBas_SPL_inc_outfile)
    save(all_NoBas_SPL_inc_outfile, 'all_NoBas_SPL_inc');
end
all_NoBas_sham_cor_outfile = [bas_stat_folder, 'all_NoBas_sham_cor.mat'];
all_NoBas_sham_inc_outfile = [bas_stat_folder, 'all_NoBas_sham_inc.mat'];
if ~isfile(all_NoBas_sham_cor_outfile)
    save(all_NoBas_sham_cor_outfile, 'all_NoBas_sham_cor');
end
if ~isfile(all_NoBas_sham_inc_outfile)
    save(all_NoBas_sham_inc_outfile, 'all_NoBas_sham_inc');
end

% 3. Structures for dn/dv/pn/pv analysis
all_NoBas_main_dn_outfile = [bas_stat_folder, 'all_NoBas_main_dn.mat'];
all_NoBas_main_dv_outfile = [bas_stat_folder, 'all_NoBas_main_dv.mat'];
all_NoBas_main_pn_outfile = [bas_stat_folder, 'all_NoBas_main_pn.mat'];
all_NoBas_main_pv_outfile = [bas_stat_folder, 'all_NoBas_main_pv.mat'];
if ~isfile(all_NoBas_main_dn_outfile)
    save(all_NoBas_main_dn_outfile, 'all_NoBas_main_dn');
end
if ~isfile(all_NoBas_main_dv_outfile)
    save(all_NoBas_main_dv_outfile, 'all_NoBas_main_dv');
end
if ~isfile(all_NoBas_main_pn_outfile)
    save(all_NoBas_main_pn_outfile, 'all_NoBas_main_pn');
end
if ~isfile(all_NoBas_main_pv_outfile)
    save(all_NoBas_main_pv_outfile, 'all_NoBas_main_pv');
end

% 4. Structures for dn/dv/pn/pv analysis in each tms
all_NoBas_BA44_dn_outfile = [bas_stat_folder, 'all_NoBas_BA44_dn.mat'];
all_NoBas_BA44_dv_outfile = [bas_stat_folder, 'all_NoBas_BA44_dv.mat'];
all_NoBas_BA44_pn_outfile = [bas_stat_folder, 'all_NoBas_BA44_pn.mat'];
all_NoBas_BA44_pv_outfile = [bas_stat_folder, 'all_NoBas_BA44_pv.mat'];
if ~isfile(all_NoBas_BA44_dn_outfile)
    save(all_NoBas_BA44_dn_outfile, 'all_NoBas_BA44_dn');
end
if ~isfile(all_NoBas_BA44_dv_outfile)
    save(all_NoBas_BA44_dv_outfile, 'all_NoBas_BA44_dv');
end
if ~isfile(all_NoBas_BA44_pn_outfile)
    save(all_NoBas_BA44_pn_outfile, 'all_NoBas_BA44_pn');
end
if ~isfile(all_NoBas_BA44_pv_outfile)
    save(all_NoBas_BA44_pv_outfile, 'all_NoBas_BA44_pv');
end
all_NoBas_SPL_dn_outfile = [bas_stat_folder, 'all_NoBas_SPL_dn.mat'];
all_NoBas_SPL_dv_outfile = [bas_stat_folder, 'all_NoBas_SPL_dv.mat'];
all_NoBas_SPL_pn_outfile = [bas_stat_folder, 'all_NoBas_SPL_pn.mat'];
all_NoBas_SPL_pv_outfile = [bas_stat_folder, 'all_NoBas_SPL_pv.mat'];
if ~isfile(all_NoBas_SPL_dn_outfile)
    save(all_NoBas_SPL_dn_outfile, 'all_NoBas_SPL_dn');
end
if ~isfile(all_NoBas_SPL_dv_outfile)
    save(all_NoBas_SPL_dv_outfile, 'all_NoBas_SPL_dv');
end
if ~isfile(all_NoBas_SPL_pn_outfile)
    save(all_NoBas_SPL_pn_outfile, 'all_NoBas_SPL_pn');
end
if ~isfile(all_NoBas_SPL_pv_outfile)
    save(all_NoBas_SPL_pv_outfile, 'all_NoBas_SPL_pv');
end
all_NoBas_sham_dn_outfile = [bas_stat_folder, 'all_NoBas_sham_dn.mat'];
all_NoBas_sham_dv_outfile = [bas_stat_folder, 'all_NoBas_sham_dv.mat'];
all_NoBas_sham_pn_outfile = [bas_stat_folder, 'all_NoBas_sham_pn.mat'];
all_NoBas_sham_pv_outfile = [bas_stat_folder, 'all_NoBas_sham_pv.mat'];
if ~isfile(all_NoBas_sham_dn_outfile)
    save(all_NoBas_sham_dn_outfile, 'all_NoBas_sham_dn');
end
if ~isfile(all_NoBas_sham_dv_outfile)
    save(all_NoBas_sham_dv_outfile, 'all_NoBas_sham_dv');
end
if ~isfile(all_NoBas_sham_pn_outfile)
    save(all_NoBas_sham_pn_outfile, 'all_NoBas_sham_pn');
end
if ~isfile(all_NoBas_sham_pv_outfile)
    save(all_NoBas_sham_pv_outfile, 'all_NoBas_sham_pv');
end

% Struct for main effect of TMS
all_NoBas_main_BA44_outfile = [bas_stat_folder, 'all_NoBas_main_BA44.mat'];
all_NoBas_main_sham_outfile = [bas_stat_folder, 'all_NoBas_main_sham.mat'];
all_NoBas_main_SPL_outfile = [bas_stat_folder, 'all_NoBas_main_SPL.mat'];
if ~isfile(all_NoBas_main_BA44_outfile)
    save(all_NoBas_main_BA44_outfile, 'all_NoBas_main_BA44')
end
if ~isfile(all_NoBas_main_sham_outfile)
    save(all_NoBas_main_sham_outfile, 'all_NoBas_main_sham')
end
if ~isfile(all_NoBas_main_SPL_outfile)
    save(all_NoBas_main_SPL_outfile, 'all_NoBas_main_SPL')
end
