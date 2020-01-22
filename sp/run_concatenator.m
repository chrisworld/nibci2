% --
% concatenates trial runs

function conc_runs = run_concatenator()

  % file dir
  file_dir = './eeg_recordings/trial_runs/';

  % get files
  files = dir([file_dir, '*.mat']);

  % if no files
  if length(files) == 0

    fprintf('***no files to concatenate')
    return
  end

  % init conc_runs
  conc_runs.date = date;

  % fist file to init conc_runs
  trial_run1 = load([file_dir, files(1).name], 'BCI', 'eeg', 'Marker');
  fprintf('concatenate file: %s \n', files(1).name)

  conc_runs.BCI = trial_run1.BCI;
  conc_runs.eeg.Time = trial_run1.eeg.Time;
  conc_runs.eeg.Data = trial_run1.eeg.Data;
  conc_runs.Marker.Time = trial_run1.Marker.Time;
  conc_runs.Marker.Data = trial_run1.Marker.Data;


  % --
  % concatenate BCI run files

  for file_idx = 2:length(files)

    % print file name
    fprintf('concatenate file: %s \n', files(file_idx).name)

    % load file
    trial_run = load([file_dir, files(file_idx).name], 'BCI', 'eeg', 'Marker');

    % update n-trials var
    conc_runs.BCI.nTrials = conc_runs.BCI.nTrials + trial_run.BCI.nTrials;

    % concatenate markers
    conc_runs.BCI.markers = cat(2, conc_runs.BCI.markers, trial_run.BCI.markers);

    % concatenate timings
    conc_runs.BCI.timings = cat(2, conc_runs.BCI.timings, trial_run.BCI.timings);

    % concatenate classlabels
    conc_runs.BCI.classlabels = cat(1, conc_runs.BCI.classlabels, trial_run.BCI.classlabels);


    % --
    % concatenate eeg
    conc_runs.eeg.Time = cat(1, conc_runs.eeg.Time, trial_run.eeg.Time);
    conc_runs.eeg.Data = cat(3, conc_runs.eeg.Data, trial_run.eeg.Data);


    % --
    % concatenate Marker
    conc_runs.Marker.Time = cat(1, conc_runs.Marker.Time, trial_run.Marker.Time);
    conc_runs.Marker.Data = cat(1, conc_runs.Marker.Data, trial_run.Marker.Data);

  end
  
  % print message
  fprintf('--Trial runs concatenated.\n')

