% --
% calculate bandpower features from csp

function x_data = calc_features_online(fb, csp_hand, csp_foot)

  % choose best csp eigenvectors
  C_hand = [csp_hand(:, 1:2), csp_hand(:, 15:16)];
  C_foot = [csp_foot(:, 1:2), csp_foot(:, 15:16)];

  % transform bandpass signals [channels x samples]
  s_csp_band_hand = C_hand' * squeeze(fb(1, :, :));
  s_csp_band_foot = C_foot' * squeeze(fb(2, :, :));

  % calculate band power for each frequency band -> [trials x channels]
  bp_hand = permute(log10(sum(s_csp_band_hand.^2, 2)), [2, 1]);
  bp_foot = permute(log10(sum(s_csp_band_foot.^2, 2)), [2, 1]);

  % data for training and testing
  x_data = [bp_hand, bp_foot];
