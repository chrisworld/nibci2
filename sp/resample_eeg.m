function [eeg_rs, time_rs, marker_rs] = resample_eeg(eeg, eeg_time, eeg_marker, params)

  eeg_rs = zeros(size(eeg, 1), ceil(size(eeg, 2) / params.rs_factor));

  % for each channel
  for ch = 1 : size(eeg, 1)
    eeg_rs(ch, :) = resample(eeg(ch, :), 1, params.rs_factor);
  end

  % only each downsampled time
  time_rs = eeg_time(1:params.rs_factor:end);

  m = eeg_marker;

  % get downsampled marker
  for r = 1 : params.rs_factor - 1

    % shift and add
    m = m + circshift(eeg_marker, r);
  end

  % get only each downsampled marker
  marker_rs = m(1:params.rs_factor:end);

  % print message
  fprintf('Resampled eeg with factor: [%d].\n', params.rs_factor)
