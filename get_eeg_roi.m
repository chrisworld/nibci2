function [ref, ac, cue, trial, marker_info] = get_eeg_roi(eeg_data, params, BCI)
  % get_eeg_roi(eeg_data, params, BCI)
  % gets the region of interest for eeg classification
  % returns the reference and cue samples
  % eeg_data.marker_rs must have following conventions:
  %   1 init 
  %   2 reference - trial start
  %   3 acoustic
  %   4 cue - cue start (motor imagine)
  %   5 break
  %   6 end run

  % marker functions
  marker_info.func = {'init', 'ref', 'acoustic', 'cue', 'break', 'end_run'};

  % aount of trials -> check cues
  n_trials = length(find(eeg_data.marker_rs == 4));

  % marker positions [trials]
  marker_info.pos = zeros(length(marker_info.func), n_trials);

  % analyse marker
  for m = 1 : length(unique(eeg_data.marker_rs)) - 1

    % print function of marker
    %disp(marker_info.func(m))

    % find sample positions of marker
    marker_info.pos(m, :) = find(eeg_data.marker_rs == m);

  end

  % calculate sample length
  marker_info.ref_samples =  marker_info.pos(3, :) - marker_info.pos(2, :);
  marker_info.ac_samples =  marker_info.pos(4, :) - marker_info.pos(3, :);
  marker_info.cue_samples =  marker_info.pos(5, :) - marker_info.pos(4, :);
  marker_info.trial_samples =  marker_info.pos(5, :) - marker_info.pos(2, :);

  %eeg_spat: [ch, samples]
  % output: [ch, trial, samples]
  % get region of interest
  [eeg_roi_ref_flat, ref_sz] = trigg(eeg_data.spat', marker_info.pos(2, :), 0, marker_info.ref_samples(1), 0);
  [eeg_roi_ac_flat, ac_sz] = trigg(eeg_data.spat', marker_info.pos(3, :), 0, marker_info.ac_samples(1), 0);
  [eeg_roi_cue_flat, cue_sz] = trigg(eeg_data.spat', marker_info.pos(4, :), 0, marker_info.cue_samples(1), 0);
  [eeg_roi_trial_flat, trial_sz] = trigg(eeg_data.spat', marker_info.pos(2, :), 0, marker_info.trial_samples(1), 0);

  ref = reshape(eeg_roi_ref_flat, ref_sz);
  ac = reshape(eeg_roi_ac_flat, ac_sz);
  cue = reshape(eeg_roi_cue_flat, cue_sz);
  trial = reshape(eeg_roi_trial_flat, trial_sz);

  % trial cue marker
  marker_info.trial_cue_pos = marker_info.pos(4, :);
