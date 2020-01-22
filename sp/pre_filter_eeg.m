% --
% pre-filtering of the eeg_signal

function [eeg_pre, params] = pre_filter_eeg(eeg, params, BCI)

  % band pass
  params.bp_order = 4;
  params.bp_f_win_pre = [3, 40];

  % get filter coeffs of bandpass filter
  [params.b_bp, params.a_bp] = butter(params.bp_order, params.bp_f_win_pre / (BCI.SampleRate / 2 / params.rs_factor));

  % apply filter
  eeg_pre = filter(params.b_bp, params.a_bp, eeg);

  % notch filter parameters
  params.notch_Wo = 50 / (BCI.SampleRate / 2 / params.rs_factor);
  params.notch_Q = 45;

  % get filter coeffs of notch filter
  [params.b_notch, params.a_notch] = iirnotch(params.notch_Wo, params.notch_Wo / params.notch_Q);
  %freqz(b, a)

  % apply filter
  eeg_pre = filter(params.b_notch, params.a_notch, eeg_pre);

  % print message
  fprintf('Pre-filtering of signal done.\n')