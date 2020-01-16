% --
% calculate bandpower features from csp

function x_data = calc_features(fb, csp_hand, csp_foot, marker, params, BCI)

  % choose best csp eigenvectors
  C_hand = [csp_hand(:, 1:2), csp_hand(:, 15:16)];
  C_foot = [csp_foot(:, 1:2), csp_foot(:, 15:16)];

  % amount of csp channels per pipeline
  n_csp_ch = size(C_hand, 2);

  % transform bandpass signals [channels x samples]
  s_csp_band_hand = C_hand' * squeeze(fb(1, :, :));
  s_csp_band_foot = C_foot' * squeeze(fb(2, :, :));

  % get trials [channels x samples x trials]
  [s_csp_roi_h.ref, s_csp_roi_h.ac, s_csp_roi_h.cue, s_csp_roi_h.trial, marker_info] = get_eeg_roi(s_csp_band_hand, marker, params, BCI);
  [s_csp_roi_f.ref, s_csp_roi_f.ac, s_csp_roi_f.cue, s_csp_roi_f.trial, marker_info] = get_eeg_roi(s_csp_band_foot, marker, params, BCI);

  % calculate band power for each frequency band
  bp_hand = squeeze(permute(log10(sum(s_csp_roi_h.trial.^2, 2)), [2, 3, 1]));
  bp_foot = squeeze(permute(log10(sum(s_csp_roi_f.trial.^2, 2)), [2, 3, 1]));

  % data for training and testing
  x_data = [bp_hand, bp_foot];

  fprintf('Bandpower features calculated with size: [%d, %d].\n', size(x_data))