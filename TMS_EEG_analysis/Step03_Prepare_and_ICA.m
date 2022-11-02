%%  In Step03
%%
% 1. Import for each subject the data which have manually cleaned and inspected
% 2. We remove the bad channels
% 3. We re-reference to the average of the good channels
% 4. Run ICA
% 5. Save the ICA output
%
% 3 Feburary 2020
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
cur_step = 'Step03';
my_tms            = {'BA44', 'SPL', 'sham'};
my_blocks         = [1,2];
my_subj           = [1:8,10:28,30,33];
subj_to_check     = [5, 10, 13, 24, 25, 28];
my_subj           = setdiff(my_subj, subj_to_check);

for subi = 1:length(my_subj)
    for ti = 1:length(my_tms)
        for bi = 1:length(my_blocks)
            
            %% IMPORT THE GOOD TRIALS AND CHECK THAT IT IS THE CORRECT FILE
            % Open the correct SubjecXX_XX_XX.m file
            c_subj = my_subj(subi);
            c_tms  = my_tms{ti};
            c_blk  = my_blocks(bi);
            eval(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])   % read subjec.m file
            
            % Load the data
            clean_data_filename = [subjectdata.output_fold, 'Sub', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk),'_data_dvp_trialClean.mat'];
            if ~isfile(clean_data_filename)
                error('Clean data file not found!')
                fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
                line2print = ['Clean data file not found for subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
                fprintf(fileID,line2print);
                fprintf(fileID,'\n');
                fclose(fileID);
            else
                load(clean_data_filename);
            end
            
            % Check that info matches between subject.m and data
            orig_dataset = find_dataset_struct(data_dvp_trialClean);
            if strcmp(orig_dataset, subjectdata.eeg)
                disp(['----------- CLEAN TRIAL DATA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk), ' CORRECTLY READ IN -----']);
            else
                error(['----- CLEAN TRIAL DATA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' B', num2str(c_blk), ' DOES NOT MATCH']);
                fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
                line2print = ['Clean data does not match with orig dataset for subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
                fprintf(fileID,line2print);
                fprintf(fileID,'\n');
                fclose(fileID);
            end
            
            %% CHECK THAT THE BAD TRIALS HAVE BEEN REMOVED
            % Create a vector of artefact samples and check that they are not member of the data
            art_vector = [];
            data_vector = [];
            error_count = 0;
            if ~isempty (subjectdata.art_visual)
                % Sample point vector of art
                for ai = 1:size(subjectdata.art_visual,1)
                    art_vector = [art_vector, subjectdata.art_visual(ai,1):subjectdata.art_visual(ai,2)];
                end
                % Sample point vector of signal
                for tr_i = 1:size(data_dvp_trialClean.sampleinfo,1)
                    data_vector = [data_vector, data_dvp_trialClean.sampleinfo(tr_i,1):data_dvp_trialClean.sampleinfo(tr_i,2)];
                end
                % Compare them and if there are samplles overalapping print an error
                if sum(ismember(art_vector, data_vector)) > 0
                    warning('Samples with artefact still present in the data - skipping this dataset');
                    error_count = 1;
                    % Print error to a file
                    fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
                    line2print = ['Samples with artefact still present in the data for subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
                    fprintf(fileID,line2print);
                    fprintf(fileID,'\n');
                    fclose(fileID);
                else
                    disp('No overlap in the data with marked artefacts:)');
                end
            end
            
            %% PARANOIA MIA (but note that not closing earlier if statement might result in skipping ICA for all datasets with no visual artefact marked)
            if error_count == 0
                %% REMOVE THE BAD CHANNELS FROM THE DATA
                % Create a variable coding the selection of channels
                my_chans = {'all'};
                bad_chans = subjectdata.bad_channels;
                % Check that the bad chans actually exist in the data
                if ~isempty(bad_chans)
                    for b_chi = 1:length(bad_chans)
                        c_b_chi = bad_chans{b_chi};
                        if ~ismember(c_b_chi, data_dvp_trialClean.label)
                            %                     c_b_chi = input([c_b_chi, ' does not exist in the channel, possibly because of a typo. Write again the channel...'], 's');
                            % Print error to file
                            fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
                            line2print = ['Non existing channel marked as badchan for Subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
                            fprintf(fileID,line2print);
                            fprintf(fileID,'\n');
                            fclose(fileID);
                            error_count = error_count +1;
                            warning(line2print);
                        else
                            my_chans{b_chi+1} = ['-', c_b_chi];   % +1 because we will always have 'all' in the first position
                        end
                    end
                end
                %% PARANOIA MIA ATTO II (avoid running ICA on datasets which still have bad channels in)
                if error_count == 0
                    
                    %% CHAN SELECTION
                    % Select only the good channels
                    cfg = [];
                    cfg.channel = my_chans;
                    data2reref = ft_preprocessing(cfg, data_dvp_trialClean);
                    
                    %% RE-REFERENCE BEFORE ICA
                    % Re-reference to the common average of the (good) channels left
                    cfg = [];
                    cfg.reref       = 'yes';
                    cfg.channel     = 'all';
                    cfg.refchannel  = 'all';
                    data_for_ica = ft_preprocessing(cfg, data2reref);
                    
                    %% RUN ICA WITH PCA OPTION TO ACCOUNT FOR THE RANK REDUCITON
                    cfg            = [];
                    cfg.runica.pca = length(data_for_ica.label) -1;    %rank(data_for_ica.trial{1})  % account for rank reduction due to the exclusion of channels
                    cfg.method     = 'runica';
                    comp           = ft_componentanalysis(cfg, data_for_ica);      %comp
                    
                    %% EXPORT THE COMPONENTS AND THE SUBJECT FILE AS A PDF
                    comp_outfilename = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_comp.mat'];
                    if ~isfile(comp_outfilename)
                        save(comp_outfilename, 'comp')
                        % Export current subjec.m file to pdf
                        publish(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'], 'format','pdf', 'outputDir', subjectdata.output_fold);
                        % Rename file
                        movefile([subjectdata.output_fold, 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf'], [subjectdata.output_fold, 'Step03_Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf']);
                        
                        %% DISPLAY STATUS
                        disp(['####################### ICA COMPONENTS FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk), ' EXPORTED #######################']);
                        
                    else
                        % Print error to a file
                        fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
                        line2print = ['Comp already existing present in the data for subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
                        fprintf(fileID,line2print);
                        fprintf(fileID,'\n');
                        fclose(fileID);
                        warning(line2print);
                    end
                    %% CLEAR VARIABLES
                    clear line2print data_vector b_chi c_b_chi error_count art_vector data_dvp_trialClean data2reref data_for_ica comp comp_outfilename subjectdata my_chans bad_chans orig_dataset clean_data_filename
                end
            end
        end
    end
end

%% BACKUP OF ALL THE SUBJECT FILES AT THE END OF THE CURRENT STEP
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
publish([folder_pdf,'Step03_Prepare_and_ICA.m'],'format','pdf', 'evalCode',false)
% For some reason after publishing the variables disappear
folder_pdf = '/data/p_02142/data_analysis_2020/scripts/eeg_analysis/';
cur_step = 'Step03';
d = yyyymmdd(datetime('now'));
[h,m,s] = hms(datetime('now'));
cur_time = [num2str(d), '_',  sprintf('%02d',h), sprintf('%02d',m),  sprintf('%02d',round(s))];

% !!!!!!!! CHECK THAT THE CURRENT SCRIPT NAME IS CORRECT !!!!!!!!
cur_script_name = 'Step03_Prepare_and_ICA';
movefile([folder_pdf, 'html/', cur_script_name, '.pdf'], ['/data/p_02142/data_analysis_2020/analysis_backup_fold/backup_', cur_step, '/', cur_time, '_', cur_script_name, '.pdf']);
