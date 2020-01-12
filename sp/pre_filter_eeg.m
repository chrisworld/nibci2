% --
% pre-filtering of the eeg_signal

function [eeg_data, params] = eeg_reshape(eeg_data, params, BCI)

  % band pass
  params.bp_order = 4;
  params.bp_f_win_pre = [1, 60];

  % get filter coeffs of bandpass filter
  [params.b_bp, params.a_bp] = butter(params.bp_order, params.bp_f_win_pre / (BCI.SampleRate / 2));

  % apply filter
  eeg_data.pre = filter(params.b_bp, params.a_bp, eeg_data.rs);

  % notch filter parameters
  params.notch_Wo = 50 / (BCI.SampleRate / 2);
  params.notch_Q = 45;

  % get filter coeffs of notch filter
  [params.b_notch, params.a_notch] = iirnotch(params.notch_Wo, params.notch_Wo / params.notch_Q);
  %freqz(b, a)

  % apply filter
  eeg_data.pre = filter(params.b_notch, params.a_notch, eeg_data.pre);