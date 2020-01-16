% --
% ass2 debug file
% csp training and pipline

% clear all
close all;
clear all;
clc;

% add library path
addpath('./ignore/Supporting Code Package/');
addpath('./ignore/Supporting Code Package/eegplot_cp')
addpath('./ignore/Supporting Code Package/csp_20160122');
addpath('./ignore/Supporting Code Package/lda_20160129');
addpath('./ignore/Supporting Code Package/lda_20160129/reducedOutlierRejection');
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
% concatenate runs, eeg format: [block, ch, time]

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
[eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data.flat, eeg_data.time, eeg_data.marker, params);


% -- 
% prefiltering
[eeg_data.pre, params] = pre_filter_eeg(eeg_data.rs, params, BCI);


% --
% get features with filter bank

% amount of bandpass filter
n_band = 2;

% frequency band for hand
fw1 = [5, 10];

% frequency band for foot
fw2 = [11, 25];

% filter
fb = filter_bank(eeg_data.pre, BCI, fw1, fw2);


% --
% train csp

% get trials [channels x samples x trials]
[fb_hand.ref, fb_hand.ac, fb_hand.cue, fb_hand.trial, marker_info] = get_eeg_roi(squeeze(fb(1, :, :)), eeg_data.marker_rs, params, BCI);
[fb_foot.ref, fb_foot.ac, fb_foot.cue, fb_foot.trial, marker_info] = get_eeg_roi(squeeze(fb(2, :, :)), eeg_data.marker_rs, params, BCI);

% number of samples per trial
n_samples_per_trial = size(fb_hand.trial, 2);

% train csp with each filter band separately [samples x channels x trials] -> [channels x channels]
csp_hand = csp_train(permute(fb_hand.trial(:, :, BCI.classlabels==1), [2, 1, 3]), permute(fb_hand.trial(:, :, BCI.classlabels==2), [2, 1, 3]), 'standard');
csp_foot = csp_train(permute(fb_foot.trial(:, :, BCI.classlabels==1), [2, 1, 3]), permute(fb_foot.trial(:, :, BCI.classlabels==2), [2, 1, 3]), 'standard');


% --
% obtain features

% choose best csp eigenvectors
C_hand = [csp_hand(:, 1:2), csp_hand(:, 15:16)];
C_foot = [csp_foot(:, 1:2), csp_foot(:, 15:16)];

% amount of csp channels per pipeline
n_csp_ch = size(C_hand, 2);

% transform bandpass signals [channels x samples]
s_csp_band_hand = C_hand' * squeeze(fb(1, :, :));
s_csp_band_foot = C_foot' * squeeze(fb(2, :, :));

% get trials [channels x samples x trials]
[s_csp_roi_h.ref, s_csp_roi_h.ac, s_csp_roi_h.cue, s_csp_roi_h.trial, marker_info] = get_eeg_roi(s_csp_band_hand, eeg_data.marker_rs, params, BCI);
[s_csp_roi_f.ref, s_csp_roi_f.ac, s_csp_roi_f.cue, s_csp_roi_f.trial, marker_info] = get_eeg_roi(s_csp_band_foot, eeg_data.marker_rs, params, BCI);

% calculate band power for each frequency band
bp_hand = squeeze(permute(log10(sum(s_csp_roi_h.trial.^2, 2)), [2, 3, 1]));
bp_foot = squeeze(permute(log10(sum(s_csp_roi_f.trial.^2, 2)), [2, 3, 1]));

% data for training and testing
x_data = [bp_hand, bp_foot];

% choose train and test data
x_train = x_data(1:100, :);
y_train = BCI.classlabels(1:100);

x_test = x_data(101:120, :);
y_test = BCI.classlabels(101:120);


% some prints
fprintf('n_samples_per_trial: %d\n', n_samples_per_trial)
fprintf('n_csp_ch: %d\n', n_csp_ch)
fprintf('x_data size: (%d, %d)\n', size(x_data))
fprintf('x_train size: (%d, %d)\n', size(x_train))
fprintf('x_test size: (%d, %d)\n', size(x_test))


% --
% lda train

% train lda
model_lda = lda_train(x_train, y_train);

% test lda prediction
[y_h, linear_scores, class_probabilities] = lda_predict(model_lda, x_test);

% score accuracy
correct_pred = sum(y_h == y_test);
false_pred = length(y_h) - correct_pred;
acc = correct_pred / length(y_h);

fprintf('\n---\n correct pred: [%d], false pred: [%d]  \n acc: [%.4f]\n', correct_pred, false_pred,  acc)
