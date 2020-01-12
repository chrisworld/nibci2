% Fitlerbank with two bands for hand and feet movement

function fb = filter_bank(eeg, BCI)

  % f range: [1, 60]Hz

  % TODO
  % use prior knowlege

  fb = zeros(2, size(eeg))

  % band pass
  ord = 4;
  fw1 = [1, 30];
  fw2 = [30, 60];

  % get filter coeffs of bandpass filter
  [b1, a1] = butter(ord, fw1 / (BCI.SampleRate / 2));
  [b2, a2] = butter(ord, fw2 / (BCI.SampleRate / 2));

  % apply filter
  fb(1, :) = filter(b1, a1, eeg);
  fb(2, :) = filter(b1, a1, eeg);