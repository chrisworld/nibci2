%% script to perform all calculations

global handles;
global BCI;
n_ch = size(eeg.Data,2);
eeg_ = eeg.Data;


eeg_data.time = Marker.Time;
eeg_data.marker = Marker.Data;

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = reshape(permute(eeg_, [2 1 3]), n_ch, []);

% resample factor
params.rs_factor = 2;

% resample
[eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data, params);

%eegplot(eeg_data.flat);

%% ------------------------------------------------------------------------
% prefiltering

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

%% ------------------------------------------------------------------------
% spatial filtering (optional)

eeg_data.spat = laplace_filter(eeg_data.pre);


params.N = 256;
params.nfft = 512;

[psd, f] = pwelch(eeg_data.spat(1, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);

plot(f, psd, 'Parent', handles.psd);
