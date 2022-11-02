%%  In Step05 we:
%% 
% 1. Import for each subject the ICA components
% 2. Manually check the ICA
% 3. Export a structure with the result of ICA inspection
% 4. Export ICA-cleaned data
%
% 12.02.2020
% Matteo Maran
% <maran@cbs.mpg.de>
% <matteo.maran.1991@gmail.com>

clear;
%% FOLDERS

fieldtrip_fold  = '/data/p_02142/data_analysis_2020/fieldtrip-20200115';
analysis_fold   = '/data/p_02142/data_analysis_2020/eeg_analysis_outputs';
subjfile_fold   = '/data/p_02142/data_analysis_2020/new_subj_files/';
script_fold     =  '/data/p_02142/data_analysis_2020/scripts/eeg_analysis';
utilties_fold   = '/data/p_02142/data_analysis_2020/scripts/utilities/';
 
addpath(fieldtrip_fold);
addpath(analysis_fold);
addpath(subjfile_fold);
addpath(script_fold);
addpath(utilties_fold);

%% LOOPING
cur_step = 'Step05';
my_tms            = {'BA44', 'SPL', 'sham'};
my_blocks         = [1,2];
my_subj           = [1:9,11:28,30,33];
my_subj           = [30,33];

for subi = 1:length(my_subj)
    for ti = 1:length(my_tms)
        for bi = 1:length(my_blocks)
                                                          
        %% READ SUBJECT.M FILE AND IMPORT SUBJECT COMP AND DATA FOR ICA
        % Open the correct SubjecXX_XX_XX.m file
        c_subj = my_subj(subi);
        c_tms  = my_tms{ti};
        c_blk  = my_blocks(bi);
        eval(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])   % read subjec.m file
        disp(['READING IN ... ','Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m']);
               
        % Define the name of the component file
        comp_outfilename = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_comp.mat'];
        if isfile(comp_outfilename)
            load(comp_outfilename);
        else
            error([comp_outfilename, ' does not exist!'])
        end
        
        % Define the name of the data for ica fila
        dataica_outfilename = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_data_for_ica.mat'];
        if isfile(dataica_outfilename)
            load(dataica_outfilename);
        else
            error([dataica_outfilename, ' does not exist!'])
        end        
 
        % Check that info matches between subject.m and comp/dat_for_ica
        orig_dataset = find_dataset_struct(comp);
        if strcmp(orig_dataset, subjectdata.eeg)
            disp(['----------- COMP DATA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk), ' CORRECTLY READ IN -----']);
        else
            error(['----- COMP DATA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' B', num2str(c_blk), ' DOES NOT MATCH']);
            fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
            line2print = ['Comp does not match with orig dataset for subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
            fprintf(fileID,line2print);
            fprintf(fileID,'\n');
            fclose(fileID);
        end   
        
        orig_dataset = find_dataset_struct(data_for_ica);
        if strcmp(orig_dataset, subjectdata.eeg)
            disp(['----------- DATA_for_ICA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk), ' CORRECTLY READ IN -----']);
        else
            error(['----- DATA_for_ICA FOR SUBJ ',  sprintf('%02d',c_subj), ' ', c_tms, ' B', num2str(c_blk), ' DOES NOT MATCH']);
            fileID = fopen([analysis_fold, filesep, cur_step, '_logfile.txt'],'a+');
            line2print = ['Data for ica does not match with orig dataset for subject ', sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk)];
            fprintf(fileID,line2print);
            fprintf(fileID,'\n');
            fclose(fileID);
        end   
        
        %% ENSURE THAT BAD CHANS ARE NOT THERE
        if length(data_for_ica.label) + length(subjectdata.bad_channels) ~= 63 && sum(ismember(subjectdata.bad_channels, data_for_ica.label)) ~= 0
            error(['BAD CHANS STILL IN FOR SUBJ  ',  sprintf('%02d',c_subj), ' ', c_tms, ' BLOCK ', num2str(c_blk), ' !!!'])
        else
            disp(['Bad chans are correctly out for Subj ',  sprintf('%02d',c_subj), ' ', c_tms, ' block ', num2str(c_blk), ' :)']);
        end
                
        %% PRINT THE COMMENT FROM VISUAL INSPECTION
        fprintf('\n');
        input(['####### ',char(subjectdata.signal_check), '   PRESS ENTER TO CONTINUE'])
        
        %% INSPECT ICA COMPONENTS      
        cfg = [];
        cfg.layout = 'easycapM1.mat';
        lyo = ft_prepare_layout(cfg);
        % Components inspection (Maren function)
        [icclass,icfreq] = tms_mg_component_browser(comp,lyo,[],[],[0.5 80],mg_colormap_coolwarm);
        
        %% APPEND ICA INFO AND BAD COMPONENTS TO SPECIFIC SUBJECTFILE
        append_ICA_comment(subjectdata, comp, icclass);

        %% UNSURE ABOUT SOME COMPONENTS
        ICA_unsure_prompt = 'Are there components that you have not removed because you were not sure (place only the number)?       ';
        ICA_unsure_answ = input(ICA_unsure_prompt,'s');
 
        fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
        fprintf(fid,'%s\n',['subjectdata.comp_unsure =   [', ICA_unsure_answ, ']; % component number which were not removed because not sure']);
        fclose all;        

        %% SAVE COMPONENT INSPECTION RESULT
        icclass_outfilename = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_icclass.mat'];
        icfreq_outfilename  = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_icfreq.mat'];
        
        % If the files do not already exist, export
        if ~isfile(icclass_outfilename)
            save(icclass_outfilename, 'icclass')
        else
            error([icclass_outfilename, ' ALREADY EXISTS!!!']);
        end
        if ~isfile(icfreq_outfilename)
            save(icfreq_outfilename, 'icfreq')
        else
            error([icfreq_outfilename, ' ALREADY EXISTS!!!']);
        end
                
        %% REMOVE ICA COMPONENTS FROM DATA
        comp_rejected = [find(icclass.clsdata)];
        cfg = [];
        cfg.component = comp_rejected; % to be removed component(s)
        data_after_ica = ft_rejectcomponent(cfg, comp, data_for_ica);
                
        %% SAVE DATA CLEANED AFTER ICA
        data_after_ica_outfilename  = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_data_after_ica.mat'];
        if ~isfile(data_after_ica_outfilename)
            save(data_after_ica_outfilename, 'data_after_ica')
        else
            error([data_after_ica_outfilename ' ALREADY EXISTS'])
        end        

        %% EXPORT CURRENT SUBJECT.M FILE AS A PDF
        publish(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'], 'format','pdf', 'outputDir', subjectdata.output_fold);
        % Rename file
        movefile([subjectdata.output_fold, 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf'], [subjectdata.output_fold, 'Step02_Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf']);

        %% CLEAR VARIABLES
        clear data_after_ica_outfilename data_after_ica comp_rejected icfreq_outfilename icclass_outfilename
        clear icfreq icclass orig_dataset subjectdata dataica_outfilename comp_outfilename data_for_ica comp
        end
    end
end


%% BACKUP OF ALL THE SUBJECT FILES AT THE END OF THE CURRENT STEP
cur_step = 'Step05';
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
publish([folder_pdf,'Step05_ICA_inspection.m'],'format','pdf', 'evalCode',false)
% For some reason after publishing the variables disappear
folder_pdf = '/data/p_02142/data_analysis_2020/scripts/eeg_analysis/';
cur_step = 'Step05';
d = yyyymmdd(datetime('now'));
[h,m,s] = hms(datetime('now'));
cur_time = [num2str(d), '_',  sprintf('%02d',h), sprintf('%02d',m),  sprintf('%02d',round(s))];

% !!!!!!!! CHECK THAT THE CURRENT SCRIPT NAME IS CORRECT !!!!!!!!
cur_script_name = 'Step05_ICA_inspection';
movefile([folder_pdf, 'html/', cur_script_name, '.pdf'], ['/data/p_02142/data_analysis_2020/analysis_backup_fold/backup_', cur_step, '/', cur_time, '_', cur_script_name, '.pdf']);
