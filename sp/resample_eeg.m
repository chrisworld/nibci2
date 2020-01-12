function [eeg_rs, time_rs, marker_rs] = resample_eeg(eeg_data, params)

  eeg_rs = zeros(size(eeg_data.flat, 1), ceil(size(eeg_data.flat, 2) / params.rs_factor));

  % for each channel
  for ch = 1 : size(eeg_data.flat, 1)
    eeg_rs(ch, :) = resample(eeg_data.flat(ch, :), 1, params.rs_factor);
  end

  % only each downsampled time
  time_rs = eeg_data.time(1:params.rs_factor:end);

  m = eeg_data.marker;

  % get downsampled marker
  for r = 1 : params.rs_factor - 1

    % shift and add
    m = m + circshift(eeg_data.marker, r);
  end

  % get only each downsampled marker
  marker_rs = m(1:params.rs_factor:end);
