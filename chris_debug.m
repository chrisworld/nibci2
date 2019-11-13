% --
% chris debug file

close all;
clear all;
clc;

% octave packages
%pkg load signal;

% add library path
addpath('./ignore/Supporting Code Package/');
addpath('./ignore/Supporting Code Package/lda_20160129/reducedOutlierRejection');


% --
% load data
load('EEGData.mat')

% number of channels
n_ch = 16

% concatenate runs

% eeg format
% [block, ch, time]

% add times and Marker to struct
eeg_data.time = Marker.Time;
eeg_data.marker = Marker.Data;

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = reshape(permute(eeg.Data, [2 1 3]), n_ch, []);
eeg_flat_size = size(eeg_data.flat);






% how this crazy thing was reshaped
%eeg_reshape();




% -- 
% exclude artifacts

% simple thresholding



% -- 
% resample EEG (optional)
params.rs_factor = 2;

[eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data, params);



% -- 
% prefilter ing

% band pass
params.bp_order = 4;
params.bp_f_win_pre = [1, 60];

% get filter coeffs
[b, a] = butter(params.bp_order, params.bp_f_win_pre / (BCI.SampleRate / 2));
params.bp_coeffs = [b; a];

% apply filter
eeg_data.pre = filter(b, a, eeg_data.rs);

% notch filter at 50Hz
params.notch_Wo = 50 / (BCI.SampleRate / 2);
params.notch_Q = 45;
[b, a] = iirnotch(params.notch_Wo, params.notch_Wo / params.notch_Q);
params.notch_coeffs = [b; a];
%freqz(b, a)

% apply filter
eeg_data.pre = filter(b, a, eeg_data.pre);


% some dft
N = 256;
ff = fft(eeg_data.pre(1, 1:N));
Y = 20 * log10( 2 / N * abs(ff(1:N/2)));

%figure(1)
%plot(Y)

% frequency vector
f = linspace(0, BCI.SampleRate / 2 / params.rs_factor, N);
psd = abs(ff(1:N)) .^ 2;

%figure(2)
%plot(f, psd)



% --
% spatial filtering (optional)

eeg_data.spat = laplace_filter(eeg_data.pre);

eeg_spatial_size = size(eeg_data.spat)



% -- 
% epoch trials according to conditions


% trigg




% -- 
% calculate PSD

% test pwelch

% PSD for each epoch
% k = 256;
% N = 1024;
% fs = 128;

% test_signal = cos(2*pi*k / N * [1:4*N]);

% psd = pwelch(test_signal, N, N/2, N, fs);

%figure
%plot(psd)
%size(psd)


params.N = 256;
params.nfft = 512;

[psd, f] = pwelch(eeg_data.spat(1, :), params.N, params.N / 2, params.nfft, BCI.SampleRate/2);

figure
plot(f, psd)
size(psd)

% Average epochs for condition

% pwelch
% in dB


% erds map params
%t = [-3, 0, 5];
%f_borders = [4, 30];
%t_ref = [-2.5, -0.5];