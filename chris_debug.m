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
addpath('./ignore/Supporting Code Package/eegplot_cp')
addpath('./ignore/eeglab2019_0/')

% erds maps
addpath('./ignore/biosig/biosig/t310_ERDSMaps')

% --
% load data
load('eeg_data10.mat')

% number of channels
n_ch = 16

% concatenate runs

% eeg format
% [block, ch, time]

% add times and Marker to struct
eeg_data.time = Marker.Time;
eeg_data.marker = Marker.Data;

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = reshape(permute(eeg, [2 1 3]), n_ch, []);
%eeg_flat_size = size(eeg_data.flat);




% -- 
% exclude artifacts

% simple thresholding



% -- 
% resample EEG (optional)

% resample factor
params.rs_factor = 2;

% resample
[eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data, params);



% -- 
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


% some dft
%N = 256;
%ff = fft(eeg_data.pre(1, 1:N));
%Y = 20 * log10( 2 / N * abs(ff(1:N/2)));

%figure(1)
%plot(Y)

% frequency vector
%f = linspace(0, BCI.SampleRate / 2 / params.rs_factor, N);
%psd = abs(ff(1:N)) .^ 2;

%figure(2)
%plot(f, psd)
%clear N ff Y f psd)



% --
% spatial filtering (optional)

eeg_data.spat = laplace_filter(eeg_data.pre);

% debug stuff
%eeg_data.spat = eeg_data.spat(1:2, :)
%eeg_spatial_size = size(eeg_data.spat)


% --
% plot whole eeg
%eegplot_cp(eeg_data.spat, 125, 64, 10, {'C3', 'Cz', 'C4'}, eeg_data.marker_rs)


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

[psd, f] = pwelch(eeg_data.spat(1, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);

%figure
%plot(f, psd)
%size(psd)

clear psd f;
size_spat = size(eeg_data.spat)


% -- 
% epoch trials according to conditions

% get region of interest -> reference and cue samples
[eeg_roi.ref, eeg_roi.cue, eeg_roi.trial, marker_info] = get_eeg_roi(eeg_data, params, BCI);

size_trial = size(eeg_roi.trial)


% erds map params
erds_params.t = [-(marker_info.ref_samples(1) + marker_info.ac_samples(1) - 1) / (BCI.SampleRate / params.rs_factor), 0, marker_info.cue_samples(1) / (BCI.SampleRate / params.rs_factor)];
erds_params.f_bord = [4, 30];
erds_params.t_ref = [-(marker_info.ref_samples(1)  + marker_info.ac_samples(1) - 1) / (BCI.SampleRate / params.rs_factor), -marker_info.ac_samples(1) / (BCI.SampleRate / params.rs_factor)]

% header train
header_train.SampleRate = BCI.SampleRate / params.rs_factor;

% trigger for the cue sample index -> 4
header_train.TRIG = marker_info.trial_cue_pos;

% class labels for training
header_train.Classlabel = transpose(BCI.classlabels)

% permute to get [samples, ch]
data = permute(eeg_data.spat, [2, 1]);

data_sz = size(data)

% load data and save as variables
load('./ignore/test_data/sGes.mat')
load('./ignore/test_data/hGes.mat')
sGes_train = sGes;
hGes_train = hGes
size(sGes_train)

% calculate erds maps
%erds_maps.c1 = calcErdsMap(data, header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 1);
erds_maps.c1 = calcErdsMap(sGes_train(:, 3), header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 1);

%erds_maps.c1 = calcErdsMap(sGes_train(:, 3), hGes_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 2);

%erds_maps.c1 = calcErdsMap(sGes_train(:, 3), header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 2);

%save('erds_maps.mat', 'erds_maps_c1', 'erds_maps_c2');


% load pre calculated erds_maps
%load('erds_maps.mat')

% plot erds maps
plotErdsMap(erds_maps.c1);

%plotErdsMap(erds_maps.c2);



% --
% Analyze eeg data

%eeg_final = eeg_data.spat;
%eeglab;

%pop_eegplot()

%eegplot_cp(signal, 125 , fs, 10,labels, marker) 

% plot eeg
%eegplot_cp(eeg_data.spat, 128, 64, 10, {'C3', 'Cz', 'C4'}, eeg_data.marker_rs)


% my update plot function test
% fig = figure(100);

% x = [0 : 10];
% t = [0 : 10];

% fs = 64;

% % plot update
% for u = 1 : 3
%   t = [u * 10 : (u+1) * 10]
%   eeg_plot_update(fig, x, t, fs);
% end




    