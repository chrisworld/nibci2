% --
% concatenates trial runs

function conc_runs = run_concatenator()

  % file dir
  file_dir = './eeg_recordings/trial_runs/';

  % load runs
  trial_run1 = load([file_dir, 'trial_run1.mat'], 'BCI', 'eeg', 'Marker');
  trial_run2 = load([file_dir, 'trial_run2.mat'], 'BCI', 'eeg', 'Marker');
  trial_run3 = load([file_dir, 'trial_run3.mat'], 'BCI', 'eeg', 'Marker');
  trial_run4 = load([file_dir, 'trial_run4.mat'], 'BCI', 'eeg', 'Marker');

  % --
  % concatenate BCI
  conc_runs.BCI = trial_run1.BCI;

  % update n-trials var
  conc_runs.BCI.nTrials = trial_run1.BCI.nTrials + trial_run2.BCI.nTrials + trial_run3.BCI.nTrials + trial_run4.BCI.nTrials;

  % concatenate markers
  conc_runs.BCI.markers = [trial_run1.BCI.markers, trial_run2.BCI.markers, trial_run3.BCI.markers, trial_run4.BCI.markers];

  % concatenate timings
  conc_runs.BCI.timings = [trial_run1.BCI.timings, trial_run2.BCI.timings, trial_run3.BCI.timings, trial_run4.BCI.timings];

  % concatenate classlabels
  conc_runs.BCI.classlabels = [trial_run1.BCI.classlabels; trial_run2.BCI.classlabels; trial_run3.BCI.classlabels; trial_run4.BCI.classlabels];


  % --
  % concatenate eeg
  conc_runs.eeg.Time = [trial_run1.eeg.Time; trial_run2.eeg.Time; trial_run3.eeg.Time; trial_run4.eeg.Time];
  conc_runs.eeg.Data = cat(3, trial_run1.eeg.Data, trial_run2.eeg.Data, trial_run3.eeg.Data, trial_run4.eeg.Data);


  % --
  % concatenate Marker
  conc_runs.Marker.Time = [trial_run1.Marker.Time; trial_run2.Marker.Time; trial_run3.Marker.Time; trial_run4.Marker.Time];
  conc_runs.Marker.Data = [trial_run1.Marker.Data; trial_run2.Marker.Data; trial_run3.Marker.Data; trial_run4.Marker.Data];

  % print message
  fprintf('Trial runs concatenated.\n')
