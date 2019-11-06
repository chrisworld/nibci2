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
load('eeg_data.mat')

% concatenate runs

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = squeeze(reshape(eeg, 1, 16, []));

% check it
N = 1024
k = 1

block_size = 4
block_len = N / block_size

test_signal = sin(2 * pi * k / N * [1:N]);

b_signal = zeros(block_size, block_len);

for n = 1 : block_size
  n
  b_signal(n, :) = test_signal((n-1) * block_len + 1 : n * block_len);
end

b_signal = cat(3, b_signal, b_signal);
b_signal = cat(3, b_signal, b_signal);
b_signal = cat(3, b_signal, b_signal);

r_signal = squeeze(reshape(b_signal, 1, [], 8));

size(b_signal)
size(r_signal)

figure(1)
plot(r_signal(:, 2))



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



% --
% spatial filtering (optional)



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