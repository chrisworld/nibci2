function [ref, cue] = get_eeg_roi(eeg_data, params, BCI)
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

  % analyse marker
  for m = 1 : length(unique(eeg_data.marker_rs)) - 1

    switch m

      % init
      case 1
        disp('init')
        marker_pos.ini = find(eeg_data.marker_rs == m);
        time_marker.ini = (marker_pos.ini - 1) / (BCI.SampleRate / params.rs_factor);

      % reference
      case 2
        disp('ref')
        marker_pos.ref = find(eeg_data.marker_rs == m);
        time_marker.ref = (marker_pos.ref - 1) / (BCI.SampleRate / params.rs_factor);
        
      % acoustic
      case 3
        disp('acoustic')
        marker_pos.ac = find(eeg_data.marker_rs == m);
        time_marker.ac = (marker_pos.ac - 1) / (BCI.SampleRate / params.rs_factor);

      % cue
      case 4
        disp('cue')
        marker_pos.cue = find(eeg_data.marker_rs == m);
        time_marker.cue = (marker_pos.cue - 1) / (BCI.SampleRate / params.rs_factor);
        
      % break
      case 5
        disp('break')
        marker_pos.break = find(eeg_data.marker_rs == m);
        time_marker.break = (marker_pos.break - 1) / (BCI.SampleRate / params.rs_factor);

      % end run
      case 6
        disp('end run')
        marker_pos.end = find(eeg_data.marker_rs == m);
        time_marker.end = (marker_pos.end - 1) / (BCI.SampleRate / params.rs_factor);

      otherwise
        disp('other value')
    end

  end

  % calculate sample length
  ref_samples =  marker_pos.ac - marker_pos.ref;
  cue_samples =  marker_pos.break - marker_pos.cue;

  % get region of interest
  [eeg_roi_ref_flat, ref_sz] = trigg(eeg_data.spat', marker_pos.ref, 0, ref_samples(1), 0);
  [eeg_roi_cue_flat, cue_sz] = trigg(eeg_data.spat', marker_pos.cue, 0, cue_samples(1), 0);

  ref = reshape(eeg_roi_ref_flat, ref_sz);
  cue = reshape(eeg_roi_cue_flat, cue_sz);