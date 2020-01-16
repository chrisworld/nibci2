% training of CSP with filterbands

function [csp_hand, csp_foot] = train_fb_csp(fb, marker, params, BCI)

  % file dir
  file_dir = './trained_params/';

  % file name
  file_name = [file_dir, 'csp.mat'];

  % get trials [channels x samples x trials]
  [fb_hand.ref, fb_hand.ac, fb_hand.cue, fb_hand.trial, marker_info] = get_eeg_roi(squeeze(fb(1, :, :)), marker, params, BCI);
  [fb_foot.ref, fb_foot.ac, fb_foot.cue, fb_foot.trial, marker_info] = get_eeg_roi(squeeze(fb(2, :, :)), marker, params, BCI);

  % train csp with each filter band separately [samples x channels x trials] -> [channels x channels]
  csp_hand = csp_train(permute(fb_hand.trial(:, :, BCI.classlabels==1), [2, 1, 3]), permute(fb_hand.trial(:, :, BCI.classlabels==2), [2, 1, 3]), 'standard');
  csp_foot = csp_train(permute(fb_foot.trial(:, :, BCI.classlabels==1), [2, 1, 3]), permute(fb_foot.trial(:, :, BCI.classlabels==2), [2, 1, 3]), 'standard');

  % save important vars
  save(file_name, 'csp_hand', 'csp_foot');

  % print message
  fprintf('Trained CSP with filter bands and saved to: %s. CSP size:[%d, %d].\n', file_name, size(csp_hand))  