%%  In Step 06
% Here we prepare data for checking potential baseline issues related to the cross-splicing 
%
% 1. Import the good_data_for_ERP (block 1 and block 2)
% 2. Merge block 1 and block 2
% 3. Time-lock according to grammaticality and phrase type
% 4. Export time-locked data for statitical analysis
% 23.04.2020 (run on March 10 for all the subjects without subj 10, and on March 12 only for subj 10)
% Matteo Maran
% <maran@cbs.mpg.de>
% <matteo.maran.1991@gmail.com>

clear;

%% FOLDERS

fieldtrip_fold = '/data/p_02142/data_analysis_2020/fieldtrip-20200115';
analysis_fold = '/data/p_02142/data_analysis_2020/eeg_analysis_outputs';
subjfile_fold = '/data/p_02142/data_analysis_2020/new_subj_files/';
script_fold  =  '/data/p_02142/data_analysis_2020/scripts/eeg_analysis';

addpath(fieldtrip_fold);
addpath(analysis_fold);
addpath(subjfile_fold);
addpath(script_fold);

%% LOOPING
my_tms            = {'BA44', 'SPL', 'sham'};
my_subj           = [1:8,11:28,30,33];
my_subj           = 10;
for subi = 1:length(my_subj)
    for ti = 1:length(my_tms)
        
        % Define subject and TMS
        c_subj = my_subj(subi);
        c_tms  = my_tms{ti};
        
        %% LOAD DATA FROM BLOCK 1 AND BLOCK 2
        % Load block 1
        c_blk = 1;
        eval(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])   % read subjec.m file
        disp(['READING IN ... ','Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m']);
        
        file_b1_good_data_for_ERP = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_good_data_for_ERP.mat'];
        disp(['Loading: ', file_b1_good_data_for_ERP]);
        load(file_b1_good_data_for_ERP)
        % Assign good_data_for_ERP to b1_good_data_for_ERP
        b1_good_data_for_ERP = good_data_for_ERP;
        clear subjectdata good_data_for_ERP
        
        % Load block 2
        c_blk = 2;
        eval(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])   % read subjec.m file
        disp(['READING IN ... ','Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m']);
        
        file_b2_good_data_for_ERP = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_good_data_for_ERP.mat'];
        disp(['Loading: ', file_b2_good_data_for_ERP]);
        load(file_b2_good_data_for_ERP)
        % Assign good_data_for_ERP to b2_good_data_for_ERP
        b2_good_data_for_ERP = good_data_for_ERP;
        clear good_data_for_ERP  % we still need subjectdata for the output folder
        
        %% CONCATENATE BLOCKS, RE-REF, BASELINE AND CALCULATE THE ERP
        % Concatenate the blocks
        cfg = [];
        cfg.keepsampleinfo = 'no';
        merged_blocks_data = ft_appenddata(cfg, b1_good_data_for_ERP, b2_good_data_for_ERP);
        
        % Re-reference
        cfg = [];
        cfg.demean = 'no';
        cfg.reref = 'yes';
        cfg.refchannel = {'A1' 'A2'};
        prep_merged_blocks_data = ft_preprocessing(cfg, merged_blocks_data);
        
        % Incorrect
        cfg = [];
        cfg.trials  = find(prep_merged_blocks_data.trialinfo == 214 |prep_merged_blocks_data.trialinfo == 114);
        inc_avg    = ft_timelockanalysis(cfg,prep_merged_blocks_data);
        % Corr condition
        cfg = [];
        cfg.trials  = find(prep_merged_blocks_data.trialinfo == 204 |prep_merged_blocks_data.trialinfo == 104 );
        cor_avg    = ft_timelockanalysis(cfg,prep_merged_blocks_data);
        
        % dn
        cfg = [];
        cfg.trials  = find(prep_merged_blocks_data.trialinfo == 104);
        dn_avg    = ft_timelockanalysis(cfg,prep_merged_blocks_data);
        % dv
        cfg = [];
        cfg.trials  = find(prep_merged_blocks_data.trialinfo == 114);
        dv_avg    = ft_timelockanalysis(cfg,prep_merged_blocks_data); 
        % pv
        cfg = [];
        cfg.trials  = find(prep_merged_blocks_data.trialinfo == 204);
        pv_avg    = ft_timelockanalysis(cfg,prep_merged_blocks_data);
        % pn avg
        cfg = [];
        cfg.trials  = find(prep_merged_blocks_data.trialinfo == 214);
        pn_avg    = ft_timelockanalysis(cfg,prep_merged_blocks_data);        
        %% SAVE THE ERPs AND THE PREP_MERGED_BLOCKS DATA       
        cur_out_folder = ['/data/p_02142/data_analysis_2020/eeg_analysis_outputs/', 'outVP', subjectdata.subject_numchar, filesep, 'noBas/'];
        if ~isfolder(cur_out_folder)
            mkdir(cur_out_folder);
        end
        
        % Define filenames
        cor_cur_out_file = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_cor_avg.mat'];
        inc_cur_out_file = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_inc_avg.mat'];
        dn_cur_out_file  = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_dn_avg.mat'];
        dv_cur_out_file  = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_dv_avg.mat']; 
        pn_cur_out_file  = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_pn_avg.mat'];
        pv_cur_out_file  = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_pv_avg.mat'];        
        % Export avg
%         if ~isfile(cor_cur_out_file) && ~isfile(inc_cur_out_file) ...
%                 && ~isfile(dn_cur_out_file) && ~isfile(dv_cur_out_file)  ...
%                 && ~isfile(pn_cur_out_file) && ~isfile(pv_cur_out_file)
            save(cor_cur_out_file, 'cor_avg');
            save(inc_cur_out_file, 'inc_avg');
            save(dn_cur_out_file, 'dn_avg');
            save(dv_cur_out_file, 'dv_avg');
            save(pv_cur_out_file, 'pv_avg');
            save(pn_cur_out_file, 'pn_avg');
            disp(['---EXPORTED: ', cor_cur_out_file]);
            disp(['---EXPORTED: ', inc_cur_out_file]);
            disp(['---EXPORTED: ', dn_cur_out_file]);
            disp(['---EXPORTED: ', dv_cur_out_file]);
            disp(['---EXPORTED: ', pn_cur_out_file]);
            disp(['---EXPORTED: ', pv_cur_out_file]);           
%         else
%             error(['Some avg output files already exist for ', 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])
%         end
        
        % Export prep_merged_blocks_data
%         prep_merged_data_outfile = [cur_out_folder, 'noBas_Sub', sprintf('%02d',c_subj), '_', c_tms, '_prep_merged_blocks_data.mat'];
%         if ~isfile(prep_merged_data_outfile)
%             save(prep_merged_data_outfile, 'prep_merged_blocks_data')
%         else
%             error([prep_merged_data_outfile, ' already exists!!!']);
%         end
        
        %% CLEAR THE VARIABLES
        clear subjectdata cor_cur_out_file inc_cur_out_file cor_avg inc_avg merged_blocks_data b2_FB_data_for_ERP b1_FB_data_for_ERP subjectdata
        clear prep_merged_data_outfile prep_merged_blocks_data cor_cur_out_file inc_cur_out_file cor_avg inc_avg cur_out_folder
    end
end

