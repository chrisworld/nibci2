% --
% ass1 main file

close all;
clear all;
clc;

% add library path
addpath('./ignore/Supporting Code Package/');
addpath('./ignore/Supporting Code Package/lda_20160129/reducedOutlierRejection');
addpath('./ignore/Supporting Code Package/eegplot_cp')
addpath('./ignore/eeglab2019_0/')

% erds maps
addpath('./ignore/biosig/biosig/t310_ERDSMaps')

% add internal paths
addpath('./gui')
addpath('./simu')
addpath('./sp')

% --
% some vars
n_ch = 16;


% --
% load data

%% concatenate runs
conc_runs = run_concatenator();

% extract information from concatenated runs
eeg_ = conc_runs.eeg.Data;
eeg_data.time = conc_runs.Marker.Time;
eeg_data.marker = conc_runs.Marker.Data;

BCI = conc_runs.BCI;

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = reshape(permute(eeg_, [2 1 3]), n_ch, []);


%%
% -- 
% resample EEG (optional)

% resample factor
params.rs_factor = 2;

% resample
[eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data.flat, eeg_data.time, eeg_data.marker, params);


%%
% -- 
% prefiltering

[eeg_data.pre, params] = pre_filter_eeg(eeg_data.rs, params, BCI);


%%
% --
% get features with filter bank

% frequency band for hand
fw1 = [5, 10];

% frequency band for foot
fw2 = [11, 25];

% filter
fb = filter_bank(eeg_data.pre, BCI, fw1, fw2);


%%
% --
% train csp

[csp_hand, csp_foot] = train_fb_csp(fb, eeg_data.marker_rs, params, BCI);


%%
% --
% calculate features with bandpower

x_data = calc_features(fb, csp_hand, csp_foot, eeg_data.marker_rs, params, BCI);


%% choose train and test data
x_train = x_data(1:100, :);
y_train = BCI.classlabels(1:100);

x_test = x_data(101:120, :);
y_test = BCI.classlabels(101:120);


%%
% --
% lda train

% train lda
model_lda = lda_train(x_train, y_train);
fprintf('LDA model trained.\n')  


%% save lda model params
save('./trained_params/model_lda.mat', 'model_lda');
fprintf('LDA model params saved.\n')


%%
% --
% test lda prediction

[y_predict, linear_scores, class_probabilities] = lda_predict(model_lda, x_test);


%% calc accuracy
acc = calc_accuracy(y_predict, y_test);

