%%  In Step01 we:
%% 
% 1. Import for each subject the relative continuous EEG signal
% 2. Interpolate around New Segment or DC correction to avoid filte issues
% 3. Interpolate using cubic interpolation from the first pulse to 450ms
% 4. Check if there were additional pulses requiring interpolation (long or short)
% 5. Use a 0.5 Hz high-pass filter
% 6. Save high-pass filtered data
% 7. Save a figure comparing unfiltered data and DC offset
% 8. Save also the cfg used for the subject
% 9. Save a backup copy of the script as run
%10. Export a backup copy of the subject files after step 01 (they are updated at every step of the script)
%
% 
% For the future myself: the backup script does not have yet this comment, which I am adding just now after having it run.
% Keep calm Matteo, breathe. You did a good job.
%
% 30.1.2020
% <maran@cbs.mpg.de>
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
my_subj           = [1:9,11:28,30,33];
my_subj           = [10];  % subject 10 was previously excluded

for subi = 1:length(my_subj)
    for ti = 1:length(my_tms)
        for bi = 1:length(my_blocks)

            
% Define which subject/TMS/block will be analysed and open the respective SubjectXX_TMS_BX.m file
c_subj = my_subj(subi);
c_tms  = my_tms{ti};
c_blk  = my_blocks(bi);
eval(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)])   % read subjec.m file

%% ASSIGN SUBJECT FILE AND READ DATA
fprintf(['------------------------- READING DATA FROM ', ['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk)],'\n']);
fprintf(['Preprocessing eeg file: ', subjectdata.eeg, '\n']);

% Import with pre-processing function
cfg = [];
cfg.dataset         = subjectdata.eeg;
cfg.continuous      = 'yes';
cfg.channel         = {'all', '-EOGV', '-EOGH'};
data_tms_raw_cont   = ft_preprocessing(cfg);

%% LATER CANCEL THIS
% raw_data = data_tms_raw_cont;

%% REMOVE NEW SEGMENT
% Find the samples associated of 'New Segment' marker
[samples_newSegmentDC, info_newSegmentDC] = find_NewSegment_DC(subjectdata);
new_segment_windinterp = data_tms_raw_cont.fsample*0.1;  % 100ms before and after

% Apply NaN around "New Segment" or "DC correction marker"
if length(samples_newSegmentDC) > 1 % so the first New Segment, for starting the recording, is ignored
    for ni = 2:length(samples_newSegmentDC)        
    data_tms_raw_cont.trial{1,1}(:,(samples_newSegmentDC(ni)-new_segment_windinterp):(samples_newSegmentDC(ni)+new_segment_windinterp)) = nan;
    % Interpolate nans
    cfg                         = [];
    cfg.prewindow               = 0.01;     % Window prior to segment to use data points for interpolation
    cfg.postwindow              = 0.01;     % Window after segment to use data points for interpolation
    cfg.method                  = 'pchip';  % pchip? = cubic 
    data_tms_raw_cont           = ft_interpolatenan(cfg, data_tms_raw_cont);    
    end
end

% Add to the subjecdata a field with the samples that were around the DC Correction or New segment markers
fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
fprintf(fid,'\n');
fprintf(fid,'\n%s\n',['%%% STEP01 - Entered @ ' datestr(now)]);
fprintf(fid,'%s',['subjectdata.samples_newSegmentDC = [' ]);
% If there are such markers, add them to the subjecdata field
if length(samples_newSegmentDC) > 1
  for ni = 2:length(samples_newSegmentDC)
    fprintf(fid,'%s', [num2str((samples_newSegmentDC(ni)-new_segment_windinterp)), ', ', num2str((samples_newSegmentDC(ni)+new_segment_windinterp)),';']);
  end
end
% Close the bracket (so the field will exist even if there were no New Segments or DC correction markers
fprintf(fid,'%s\n',[']; % interval of samples which were interpolated due to a New Segment or DC correction marker']);
fclose all;

    
%% ------- LONG INTERPOLATION
% Here we interpolate from -2 to 450ms after each first TMS pulse.
% Note that the EEG triggers S101,111,201,211 refer to the main task.
% The marker S 81 is the value which was used during the practice. Since it is possible that a part
% of the practice was recorded too, we interpolate also S 81 and S  1.
% No DVP marker was present in the practice

% ----- LONG INTERPOLATION
window_for_interp = .3; % duration of window length to be used for interpolation
long_interp_prestim = .002;
long_interp_posstim = .45; 

fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
fprintf(fid,'%s\n',['subjectdata.window_for_interp = ', num2str(window_for_interp), ';']);
fprintf(fid,'%s\n',['subjectdata.long_interp_prestim = ', num2str(long_interp_prestim),';']);
fprintf(fid,'%s\n',['subjectdata.long_interp_posstim = ', num2str(long_interp_posstim), ';']);
fclose all;

% Remove from -2 to 450ms from the first pulse
trigger = {'S 81','S101', 'S111', 'S201', 'S211'};          % Markers in data that reflect TMS-pulse onset
cfg                         = [];
cfg.method                  = 'marker'; % The alternative is 'detect' to detect the onset of pulses
cfg.dataset                 = subjectdata.eeg;
cfg.prestim                 = long_interp_prestim;     % First time-point of range to exclude
cfg.poststim                = long_interp_posstim;     % Last time-point of range to exclude
cfg.trialdef.eventtype      = 'Stimulus';
cfg.trialdef.eventvalue     = trigger ;
cfg_ringing = ft_artifact_tms(cfg);     % Detect TMS artifacts
% Reject Timepoints > replace with nan
cfg_artifact                            = [];
cfg_artifact.artfctdef.ringing.artifact = cfg_ringing.artfctdef.tms.artifact;   % artifact timepoints defined in the previous step    
cfg_artifact.artfctdef.reject           = 'nan';                                                      	% We supply ft_rejectartifact with the original trial structure so it knows where to look for artifacts.
cfg_artifact.artfctdef.minaccepttim     = 0.01;                                	% This specifies the minimum size of resulting trials. The default is too large for the present data, resulting in small artifact-free segments being rejected as well.
data_cont_ring                          = ft_rejectartifact(cfg_artifact,data_tms_raw_cont);% pre_data_cont_ring);  % Reject trials partially
% Cubic interpolation requires at least 2 datapoint at each side, I gave a bit more with 10ms
cfg                         = [];
cfg.prewindow               = window_for_interp;     % Window prior to segment to use data points for interpolation
cfg.postwindow              = window_for_interp;     % Window after segment to use data points for interpolation
cfg.method                  = 'pchip';  % pchip? = cubic 
data_cont_interp            = ft_interpolatenan(cfg, data_cont_ring);
cfg_interp = cfg;

% Store variable for saving the artefact definition
cfg_art_tms = cfg_artifact;

%% LATER CANCEL THIS
% prelong = data_cont_interp;

%% ADDITIONAL LONG INTERPOLATION FOR MISSED TMS EVENTS
% Check if there are additional leftover pulses that require interpolation
[for_long_interp, for_short_interp] = nan_leftover_pulses(cfg_ringing, subjectdata);

% Print to subject file
fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
fprintf(fid,'%s',['subjectdata.additional_long_interp= [' ]);
fclose all;
% Loop through for_long_interp and replace with nans the time-windows of interest
fs_freq = data_cont_interp.fsample;
if isfield(for_long_interp, 'event')
    % Place nans around it
    for li = 1:length(for_long_interp)  % loop through the events requiring the long interpolation
        cur_li_sample = for_long_interp(li).sample;
        % Manually place nans
        temp_data_cont_interp = data_cont_interp;
        start_temp_sample_interp = cur_li_sample-long_interp_prestim*fs_freq;
        end_temp_sample_interp   = cur_li_sample+long_interp_posstim*fs_freq;
        temp_data_cont_interp.trial{1,1}(:,start_temp_sample_interp:end_temp_sample_interp) = nan;
        % Print to subjectdata
        fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
        fprintf(fid,'%s', [num2str(start_temp_sample_interp), ', ', num2str(end_temp_sample_interp),';']);        
    end
    % And cubic interpolation
    cfg                         = [];
    cfg.prewindow               = window_for_interp;     % Window prior to segment to use data points for interpolation
    cfg.postwindow              = window_for_interp;     % Window after segment to use data points for interpolation
    cfg.method                  = 'pchip';  % pchip? = cubic 
    data_cont_interp            = ft_interpolatenan(cfg, temp_data_cont_interp);    
end

% Close bracket and file
fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
fprintf(fid,'%s',[']; % interval samples which required a long interpolation because of missed TMS events']);
fclose all;

clear temp_data_cont_interp for_long_interp

%% ADDITIONAL SHORT INTERPOLATION FOR MISSED TMS EVENTS
% Print to subject file
fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
fprintf(fid,'\n%s',['subjectdata.additional_short_interp= [' ]);
fclose all;

% Loop through for_long_interp and replace with nans the time-windows of interest
if isfield(for_short_interp, 'event')
    % Place nans around it
    for si = 1:length(for_short_interp)
        cur_si_sample = for_short_interp(si).sample;
        % Manually place nans
        si_start_temp_sample_interp = cur_si_sample-0.01*fs_freq;
        si_end_temp_sample_interp   = cur_si_sample+0.06*fs_freq;
        data_cont_interp.trial{1,1}(:,si_start_temp_sample_interp:si_end_temp_sample_interp) = nan;
        % Print to subjectdata
        fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
        fprintf(fid,'%s', [num2str(si_end_temp_sample_interp), ', ', num2str(si_end_temp_sample_interp),';']);        
    end
    % Close bracket and file
    % And cubic interpolation
    cfg                         = [];
    cfg.prewindow               = .01;     % Window prior to segment to use data points for interpolation
    cfg.postwindow              = .01;     % Window after segment to use data points for interpolation
    cfg.method                  = 'pchip';  % pchip? = cubic 
    data_cont_interp            = ft_interpolatenan(cfg, data_cont_interp);    
end

fid = fopen([subjfile_fold 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'],'At');
fprintf(fid,'%s',[']; % interval samples which required a short interpolation because of missed TMS events']);
fclose all;

% cfg = [];
% cfg.preproc.demean = 'yes';
% cfg.viewmode = 'vertical';
% cfg.ylim = [-100 100]
% ft_databrowser(cfg, data_cont_ring)
% ft_databrowser(cfg,temp_data_cont_interp);

clear data_tms_raw_cont data_cont_ring pre_cont_interp for_short_interp

%% ------- FILTERING
% High-pass filter
cfg = [];
cfg.hpfilter = 'yes';
cfg.hpfilttype = 'firws';
cfg.hpfiltwintype = 'kaiser';
cfg.hpfiltdev     = 0.01;
cfg.hpfreq   = 0.5;
cfg.plotfiltresp    = 'no';
data_cont_interp_hpfilt     = ft_preprocessing(cfg,data_cont_interp);
cfg_hp_filter = cfg;

% Save continuous filtered data
datafilt_outputname = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_data_cont_hpfilt.mat'];
if ~isfile(datafilt_outputname)
    save(datafilt_outputname, 'data_cont_interp_hpfilt');
else
    fed = fopen( '/data/p_02142/data_analysis_2020/eeg_analysis_outputs/error_logfile_Step01.txt', 'wt' );
    fprintf(fed,'/n');
    fprintf(fed, ['Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_data_cont_hpfilt.mat already existed, so it was not overwritten']);
    fclose(fed);
end

%% ------- PLOT FILTER AND DC OFFSET
% Generate a plot which shows the unfiltered continuous interpolated signal and the DC offset
sec2plot = 50; % number of seconds of the signal to plot
sampling_rate = data_cont_interp.fsample;
iStart = round(size(data_cont_interp.trial{1},2)./3); % random start point at a 1/3 of the record
iEnd = iStart + sec2plot*sampling_rate;

forPDFfig = figure('visible','off');
plot(data_cont_interp.time{1}(iStart:iEnd),data_cont_interp.trial{1}(18,iStart:iEnd));
hold on;
plot(data_cont_interp.time{1}(iStart:iEnd),data_cont_interp.trial{1}(18,iStart:iEnd)-data_cont_interp_hpfilt.trial{1}(18,iStart:iEnd),'g')
title(['Subject ', subjectdata.subject_numchar, ' - ', subjectdata.TMS, ' Block ', num2str(subjectdata.block)]);
hold off;
legend('Continuous data interpolated', 'DC offset', 'Location','southeast');
pdf_outfilename = [subjectdata.output_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '.pdf'];
saveas(forPDFfig,pdf_outfilename)

% Empty some memory
clear data_cont_interp_hpfilt data_cont_interp

%% ------- SAVE THE CFG OF INTEREST
cfg_fold = [subjectdata.output_fold, 'cfg_files', filesep];
if ~isfolder(cfg_fold)
    mkdir(cfg_fold)
end

% Define filenames
cfg_art_tms_filename = [cfg_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_cfg_art_tms.mat'];
cfg_interp_filename = [cfg_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_cfg_interp.mat'];
cfg_ringing_filename = [cfg_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_cfg_ringing.mat'];
cfg_hp_filter_filename = [cfg_fold, 'Sub', subjectdata.subject_numchar, '_', subjectdata.TMS, '_B', num2str(subjectdata.block), '_cfg_hp_filter.mat'];

save(cfg_art_tms_filename, 'cfg_art_tms');
save(cfg_interp_filename, 'cfg_interp');
save(cfg_ringing_filename, 'cfg_ringing');
save(cfg_hp_filter_filename, 'cfg_hp_filter');

% Export current subjec.m file to pdf
publish(['Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.m'], 'format','pdf', 'outputDir', subjectdata.output_fold);
% Rename file
movefile([subjectdata.output_fold, 'Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf'], [subjectdata.output_fold, 'Step01_Subject', sprintf('%02d',c_subj), '_', c_tms, '_B', num2str(c_blk), '.pdf']);

        end
    end
end

%% BACKUP OF ALL THE SUBJECT FILES AT THE END OF THE CURRENT STEP
cur_step = 'Step01';
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
publish([folder_pdf,'Step01_Import_interpolate.m'],'format','pdf', 'evalCode',false)
% For some reason after publishing the variables disappear
folder_pdf = '/data/p_02142/data_analysis_2020/scripts/eeg_analysis/';
cur_step = 'Step01';
d = yyyymmdd(datetime('now'));
[h,m,s] = hms(datetime('now'));
cur_time = [num2str(d), '_',  sprintf('%02d',h), sprintf('%02d',m),  sprintf('%02d',round(s))];

% !!!!!!!! CHECK THAT THE CURRENT SCRIPT NAME IS CORRECT !!!!!!!!
cur_script_name = 'Step01_Import_interpolate';
movefile([folder_pdf, 'html/', cur_script_name, '.pdf'], ['/data/p_02142/data_analysis_2020/analysis_backup_fold/backup_', cur_step, '/', cur_time, '_', cur_script_name, '.pdf']);
