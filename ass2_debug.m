% --
% ass2 debug file

% clear all
close all;
clear all;
clc;

% add library path
addpath('./ignore/Supporting Code Package/');
addpath('./ignore/Supporting Code Package/lda_20160129/reducedOutlierRejection');
addpath('./ignore/Supporting Code Package/eegplot_cp')
addpath('./ignore/Supporting Code Package/csp_20160122');
addpath('./ignore/eeglab2019_0/')

% erds maps
addpath('./ignore/biosig/biosig/t310_ERDSMaps')

% add internal paths
addpath('./gui')
addpath('./simu')
addpath('./sp')


% --
% load data

load('./eeg_recordings/Trial120_eeg')
eeg_ = eeg.Data;

% some given params
n_ch = 16;
n_trials = length(BCI.classlabels);
n_classes = length(unique(BCI.classlabels));
fprintf('n_ch: %d, n_trials: %d, n_classes: %d\n', n_ch, n_trials, n_classes)


% --
% concatenate runs

% eeg format: [block, ch, time]

% add times and Marker to struct
eeg_data.time = Marker.Time;
eeg_data.marker = Marker.Data;

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = reshape(permute(eeg_, [2 1 3]), n_ch, []);


% -- 
% resample EEG (optional)

% resample factor
params.rs_factor = 2;

% resample
[eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data, params);


% -- 
% prefiltering
[eeg_data, params] = pre_filter_eeg(eeg_data, params, BCI);


% --
% spatial filtering (optional)
eeg_data.spat = laplace_filter(eeg_data.pre);


% --
% get features with filter bank

% feature windows

% frequency band for hand
fw1 = [1, 15];

% frequency band for foot
fw2 = [15, 30];

% filter
fb = filter_bank(eeg_data.spat, BCI, fw1, fw2);


% --
% train csp

% get trials [channels x samples x trials]
[eeg_c1.ref, eeg_c1.ac, eeg_c1.cue, eeg_c1.trial, marker_info] = get_eeg_roi(squeeze(fb(1, :, :)), eeg_data.marker_rs, params, BCI);
[eeg_c2.ref, eeg_c2.ac, eeg_c2.cue, eeg_c2.trial, marker_info] = get_eeg_roi(squeeze(fb(2, :, :)), eeg_data.marker_rs, params, BCI);

n_samples_per_trial = size(eeg_c1.trial, 2);


% get class labeled signals with dimensions: [samples x channels x trials]
data_class.hand = permute(eeg_c1.trial(:, :, BCI.classlabels==1), [2, 1, 3]);
data_class.foot = permute(eeg_c1.trial(:, :, BCI.classlabels==2), [2, 1, 3]);

% csp training [samples x channels x trials] -> [channels x channels]
csp = csp_train(data_class.hand, data_class.foot, 'standard');


% --
% obtain features

% choose best two csp eigenvectors
C = [csp(:, 1), csp(:, 3)];
n_csp_ch = size(C, 2);

% transform signal [channels x samples]
s_csp_band_hand = C' * squeeze(fb(1, :, :));
s_csp_band_foot = C' * squeeze(fb(2, :, :));

% get trials [channels x samples x trials]
[s_csp_roi_h.ref, s_csp_roi_h.ac, s_csp_roi_h.cue, s_csp_roi_h.trial, marker_info] = get_eeg_roi(s_csp_band_hand, eeg_data.marker_rs, params, BCI);
[s_csp_roi_f.ref, s_csp_roi_f.ac, s_csp_roi_f.cue, s_csp_roi_f.trial, marker_info] = get_eeg_roi(s_csp_band_foot, eeg_data.marker_rs, params, BCI);

% some prints
fprintf('n_samples_per_trial: %d\n', n_samples_per_trial)
fprintf('n_csp_ch: %d\n', n_csp_ch)
fprintf('csp size: (%d, %d)\n', size(csp))
fprintf('c size: (%d, %d)\n', size(C))
fprintf('s_csp_band_hand: (%d, %d)\n', size(s_csp_band_hand))

% init csp signal [channels x samples x trials]
s_csp = zeros(n_csp_ch, n_samples_per_trial, n_trials);

% get filtered trials for each class
s_csp(:, BCI.classlabels==1, :) = s_csp_roi_h.trial(:, BCI.classlabels==1, :);
s_csp(:, BCI.classlabels==2, :) = s_csp_roi_f.trial(:, BCI.classlabels==2, :);

% calculate band power
x_train = log10(sum(s_csp .^ 2, 3));

fprintf('x_train size: (%d, %d)\n', size(x_train))


% --
% lda train
