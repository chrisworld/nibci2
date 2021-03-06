% --
% Predicts the samples in the buffer and compares it to the actual classlabel

function y_pred_true = buffer_prediction(read_buffer, y_true, BCI, fw1, fw2)

  % resample factor
  params.rs_factor = 1;

  % filter band
  fb = filter_bank(read_buffer, params, BCI, fw1, fw2);

  % read csp params
  csp = load('csp.mat');

  % calculate features
  x_data = calc_features_online(fb, csp.csp_hand, csp.csp_foot);

  % load traned lda model
  m = load('model_lda.mat');

  % predict label
  [y_pred, lin_scores, p_class] = lda_predict(m.model_lda, x_data);

  % correct predicted output
  y_pred_true = y_pred == y_true;

  % print message
  %fprintf('actual label: [%d], predicted label: [%d], output: [%d]\n', y_true, y_pred, y_pred_true)