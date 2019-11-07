% --
% chris debug file

close all;
clear all;
clc;

% octave packages
%pkg load signal;

% add library path
addpath('./ignore/Supporting Code Package/');


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
eeg_flat_size = size(eeg_data.flat)






% how this crazy thing was reshaped
%eeg_reshape();




% -- 
% exclude artifacts

% simple thresholding



% -- 
% resample EEG (optional)
params.resample_factor = 2;

eeg_data.rs = zeros(size(eeg_data.flat, 1), size(eeg_data.flat, 2) / 2);

for ch = 1 : size(eeg_data.flat, 1)
  eeg_data.rs(ch, :) = resample(eeg_data.flat(ch, :), 1, params.resample_factor);
end



% -- 
% prefilter ing

% band pass
params.filter_order = 4;
params.f_window_pre = [1, 60];

% get filter coeffs
[b, a] = butter(params.filter_order, params.f_window_pre / (BCI.SampleRate / 2));

% apply filter
eeg_data.pre = filter(b, a, eeg_data.rs);

% notch filter at 50Hz
%[b, a] = iirnotch(50 / (BCI.SampleRate / 2))

% apply filter
%eeg_data.pre = filter(b, a, eeg_data.pre);


% some dft
N = 256;
ff = fft(eeg_data.pre(1, 1:2*N));
Y = 20 * log10( 2 / N * abs(ff(1:N)));

%figure(1)
%plot(Y)

% frequency vector
f = linspace(0, BCI.SampleRate / 2 / params.resample_factor, N);
psd = abs(ff(1:N)) .^ 2;

%figure(2)
%plot(f, psd)



% --
% spatial filtering (optional)

eeg_data.filt = laplace_filter(eeg_data.pre);

size(eeg_data.filt)



% -- 
% epoch trials according to conditions

% trigg



% -- 
% calculate PSD

% PSD for each epoch

% Average epochs for condition

% pwelch
% in dB


% erds map params
%t = [-3, 0, 5];
%f_borders = [4, 30];
%t_ref = [-2.5, -0.5];