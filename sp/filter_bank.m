% --
% Fitlerbank with two bands for hand and feet movement

function fb = filter_bank(eeg, BCI, fw1, fw2)
  % filter_bank
  % filter time series signal (2D)
  % f range: [1, 60]Hz

  fb = zeros([2, size(eeg)]);

  % band pass
  ord = 4;

  % get filter coeffs of bandpass filter
  [b1, a1] = butter(ord, fw1 / (BCI.SampleRate / 2));
  [b2, a2] = butter(ord, fw2 / (BCI.SampleRate / 2));

  % apply filter
  fb(1, :, :) = permute(filtfilt(b1, a1, eeg'), [2 1]);
  fb(2, :, :) = permute(filtfilt(b2, a2, eeg'), [2 1]);

  % print message
  fprintf('Filterbank applied with fw1:[%d, %d] and fw2:[%d, %d].\n', fw1, fw2)




