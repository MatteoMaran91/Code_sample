%%  In Step02 we:
%% 
% 1. Import for each subject the high-pass filtered data
% 2. Epoch around the DVP
% 3. Check if there are bad channels and bad trials
% 4. Annotate which are the bad channels
%
% 30.1.2020
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
my_blocks         = [1,2];
my_subj           = [10, 13:28,30,33];


for subi = 1:length(my_subj)
    for ti = 1:length(my_tms)
        for bi = 1:length(my_blocks)

        %% IMPORT HP-FILTERED DATA
        % Open the correct SubjecXX_XX_XX.m file
        c_subj = my_subj(subi);
        c_tms  = my_tms{ti};
        c_blk  = my_blocks(bi);
        eval(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])   % read subjec.m file
        % Load the data
        hp_data_filename = [subjectdata.output_fold, 'Sub', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk),'_data_cont_hpfilt.mat']; 
        load(hp_data_filename);
        % Check that info matches between subject.m and data
        orig_dataset = find_dataset_struct(data_cont_interp_hpfilt);
        if strcmp(orig_dataset, subjectdata.eeg)
            disp(['----------- HP FILT DATA FOR SUBJ',  sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk), ' CORRECTLY READ IN -----']);
        else
            error(['----- HP-FILT DATA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' B', num2str(c_blk), ' DOES NOT MATCH']);
        end
        
        %% RE-EPOCH FILTERED DATA TO DVP OF THE SECOND WORD
        % We keep some more milliseconds on the left for future low-pass filter, and a long interval on the right to get also blinks
        % Re-epoch
        cfg = [];
        cfg.dataset                 = subjectdata.eeg;
        cfg.trialdef.prestim        = .25;         % prior to event onset
        cfg.trialdef.poststim       = 2;            % after event onset
        cfg.trialdef.eventtype      = 'Stimulus'; % see above
        cfg.trialdef.eventvalue     = {'S104', 'S114', 'S204', 'S214'};     % DVP markers 
        cfg = ft_definetrial(cfg);                % make the trial definition matrix
        trl = cfg.trl; 
        data_dvp = ft_redefinetrial(cfg, data_cont_interp_hpfilt);

        %% CHECK CHANNELS
        % First check if there are any obvious bad channels. This inspection serves as preliminary for
        % the future manual check of the data
        check_channel_avg(data_dvp);
        proceed_answ = 'N';
        while proceed_answ == 'N'
            proceed_answ = input('READY TO PROCEED? Y/N           ', 's');
        end
        close all;
                
        %%  MANUAL CHECK OF DATA
        % Manual check of the trials (do not apply baseline correction as we have already high-pass filtered so it is not necessary
        % The two following configuration options should be added to have baseline correction only in visualization
        % cfg.preproc.demean = 'yes';           
        % cfg.preproc.baselinewindow = [-0.25 -0.001];        
        cfg=[];
        cfg.channel = 'EEG';
        cfg.viewmode = 'vertical';
        cfg.ylim = [-40, 40];
        artf=ft_databrowser(cfg,data_dvp);
        
        % Update subjectdata file
        vis_marked_intervals = artf.artfctdef.visual.artifact;
        fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
        fprintf(fid,'\n');
        fprintf(fid,'%s\n',['%%% STEP02 - Entered @ ' datestr(now)]);
        fprintf(fid,'%s',['subjectdata.art_visual = [' ]);        
        % If there are such markers, add them to the subjecdata field
        if size(vis_marked_intervals,1) > 0
          for vi = 1:size(vis_marked_intervals,1)  % loop through the intervals marked
            fprintf(fid,'%s', [num2str(vis_marked_intervals(vi,1)), ',', num2str(vis_marked_intervals(vi,2)),';']);
          end
        end
        % Close the bracket (so the field will exist even if there were no New Segments or DC correction markers
        fprintf(fid,'%s\n',[']; % intervals of samples which were visually marked as artifact in Step 02']);
        fclose all;        
        
        %% MARK AS ARTEFACT INTERVALS THAT WERE INTERPOLATED DUE TO NEW SEGMEND OR DC CORRECTION
        % Note that only if these samples are present in the interval the trial will be removed
        % Update the artifact configuration in order to remove the sample points which were interpolated
        interpolated_intervals = [];
        % New Segment/DC
        for ii = 1:size(subjectdata.samples_newSegmentDC,1)
            cur_interval = subjectdata.samples_newSegmentDC(ii,:);
            if ~isempty(cur_interval)
                interpolated_intervals = [interpolated_intervals; cur_interval];
            end
        end                    
        updated_marked_intervals = sortrows([vis_marked_intervals; interpolated_intervals]);
        
        %% REMOVE TRIALS MARKED AS ARTEFACT      
        % Removal of the trials marked as artefact
        updated_artf = artf;
        updated_artf.artfctdef.visual.artifact = updated_marked_intervals;
        cfg = [];
        cfg.artfctdef.reject = 'complete';          
        cfg.artfctdef.visual.artifact = updated_artf.artfctdef.visual.artifact;
        data_dvp_trialClean = ft_rejectartifact(cfg, data_dvp);  
        
        clear data_dvp;
        
        %% GENERAL COMMENTS ON THE EEG SIGNAL
        append_EEG_comment(subjectdata);
        
        %% FINAL CHECK OF THE CHANNELS
        % A GUI asks for input from to check which are the bad channels
        bad_chan_list = GUI_bad_channels(data_dvp_trialClean);
        % Update the subjecdata file
        fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
        fprintf(fid,'%s',['subjectdata.bad_channels = {' ]);
        if ~isempty(bad_chan_list)
          for bcii = 1:length(bad_chan_list)
              if bcii ~= length(bad_chan_list)
                fprintf(fid,'%s', ['''', bad_chan_list{bcii},'''',',',]);
              else
                fprintf(fid,'%s', ['''', bad_chan_list{bcii},'''']);                  
              end  
          end
        end
        % Close the bracket (so the field will exist even if there were no New Segments or DC correction markers
        fprintf(fid,'%s\n',['}; % bad channels defined in Step 02']);
        fclose all;
        disp('Subjec.m file updated');
        
        %% EXPORT DATA FOR ICA        
        dataDVP_output_filename = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_data_dvp_trialClean.mat'];
        save(dataDVP_output_filename, 'data_dvp_trialClean');
        
        %% SAVE THE CFG OF INTEREST
        cfg_fold = [subjectdata.output_fold, 'cfg_files', filesep];
        if ~isfolder(cfg_fold)
            mkdir(cfg_fold)
        end

        % Define filenames
        updated_artf_filename = [cfg_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_updated_artf.mat'];
        artf_filename = [cfg_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_artf.mat'];
        
        save(updated_artf_filename, 'updated_artf');
        save(artf_filename, 'artf');

        % Export current subjec.m file to pdf
        publish(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'], 'format','pdf', 'outputDir', subjectdata.output_fold);
        % Rename file
        movefile([subjectdata.output_fold, 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf'], [subjectdata.output_fold, 'Step02_Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf']);

        %% CLEAR VARIABLES
        clear hp_data_filename data_dvp vis_marked_intervals updated_marked_intervals data_dvp_trialClean  bad_chan_list dataDVP_output_filename cfg_fold data_dvp_trialClean updated_artf_filename  artf_filename        
        
        end
    end
end
     
%% BACKUP OF ALL THE SUBJECT FILES AT THE END OF THE CURRENT STEP
cur_step = 'Step02';
subjfile_backup(cur_step)


%% BACKUP OF THE CURRENT SCRIPT AS AN .M FILE
% Create a folder if it is not there
d = yyyymmdd(datetime('now'));
[h,m,s] = hms(datetime('now'));
cur_time = [num2str(d), '_',  sprintf('%02d',h), sprintf('%02d',m),  sprintf('%02d',round(s))]; 
% Set the general backup fold
general_bkpfold = '/data/p_02142/data_analysis_2020/analysis_backup_fold/backup_';
bkp_fold = [general_bkpfold, cur_step, filesep];
if ~isfolder(bkp_fold)
    mkdir(bkp_fold)
end
% Define a unique filename
full_filename_location = mfilename('fullpath');
only_filename = mfilename;
backup_filename  =  [bkp_fold, only_filename, '_used_', cur_time, '.m'];

% Copy the current script in the backup folder
this_script=strcat(full_filename_location, '.m');
copyfile(this_script,backup_filename);
disp('----------- .M BACKUP COMPLETED ---------');   

%% BACKUP OF THE CURRENT SCRIPT AS A PDF FILE
folder_pdf = '/data/p_02142/data_analysis_2020/scripts/eeg_analysis/';
publish([folder_pdf,'Step02_Manual_data_check.m'],'format','pdf', 'evalCode',false)
% For some reason after publishing the variables disappear
folder_pdf = '/data/p_02142/data_analysis_2020/scripts/eeg_analysis/';
cur_step = 'Step02';
d = yyyymmdd(datetime('now'));
[h,m,s] = hms(datetime('now'));
cur_time = [num2str(d), '_',  sprintf('%02d',h), sprintf('%02d',m),  sprintf('%02d',round(s))];

% !!!!!!!! CHECK THAT THE CURRENT SCRIPT NAME IS CORRECT !!!!!!!!
cur_script_name = 'Step02_Manual_data_check';
movefile([folder_pdf, 'html/', cur_script_name, '.pdf'], ['/data/p_02142/data_analysis_2020/analysis_backup_fold/backup_', cur_step, '/', cur_time, '_', cur_script_name, '.pdf']);
