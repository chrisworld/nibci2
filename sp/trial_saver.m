% --
% saves a trial run

function trial_saver(trial_run_id, BCI, eeg, Marker)

  % file dir
  file_dir = './eeg_recordings/trial_runs/';

  % file name
  file_name = [file_dir, 'trial_run', int2str(trial_run_id), '.mat'];

  % save important vars
  save(file_name, 'trial_run_id', 'BCI', 'eeg', 'Marker');

  % print message
  fprintf('Saved trial run to file: %s\n', file_name)