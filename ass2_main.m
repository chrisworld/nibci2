% --
% ass2 main file

close all;
clear all;
clc;

%% add library path

% change directory
cd('C:/Users/christian/git/nibci2')

% remove internal paths
rmpath('./simu')
rmpath('./simu/TiA_client')

addpath('./ignore/Supporting Code Package/');
addpath('./ignore/Supporting Code Package/eegplot_cp')
addpath('./ignore/Supporting Code Package/csp_20160122');
addpath('./ignore/Supporting Code Package/lda_20160129');
addpath('./ignore/Supporting Code Package/lda_20160129/reducedOutlierRejection');

% add internal paths
addpath('./gui')
addpath('./simu_feedback')
addpath('./simu_feedback/TiA_client')
addpath('./sp')
addpath('./listener')
addpath('./pictures')
addpath('./trained_params')


%%
% set number of splits á 30 trials for the the first part

% open_system('graz_bci_model');
% nTrials = 4
% 
% for i=1:nTrials
%     set_param('graz_bci_model', 'SimulationCommand', 'start');
% 
%     filename = ['./eeg_recordings/trial_runs/trail_run', num2str(i)];
%     save(filename);
%     pause(2)
% end


%% concatenate runs
conc_runs = run_concatenator();

% extract information from concatenated runs
eeg_ = conc_runs.eeg.Data;
eeg_data.time = conc_runs.Marker.Time;
eeg_data.marker = conc_runs.Marker.Data;

BCI = conc_runs.BCI;

%% reshape eeg to 1 x 16 x numSamples
n_ch = 16;
eeg_data.flat = reshape(permute(eeg_, [2 1 3]), n_ch, []);
fprintf('Flatened signal.\n')


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

%% save f_bands
save('./trained_params/f_bands.mat', 'fw1', 'fw2');

%% filter
fb = filter_bank(eeg_data.pre, params, BCI, fw1, fw2);
fprintf('Filterbank applied with fw1:[%d, %d] and fw2:[%d, %d].\n', fw1, fw2)


%%
% --
% train csp

[csp_hand, csp_foot] = train_fb_csp(fb, eeg_data.marker_rs, params, BCI);


%%
% --
% calculate features with bandpower

x_data = calc_features(fb, csp_hand, csp_foot, eeg_data.marker_rs, params, BCI);


%% choose train and test data

% test train set ratio
n_train = round(size(x_data, 1) / 10 * 8);

% training samples
x_train = x_data(1:n_train, :);
y_train = BCI.classlabels(1:n_train);

% test samples
x_test = x_data(n_train+1:end, :);
y_test = BCI.classlabels(n_train+1:end);


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

% calc accuracy
acc = calc_accuracy(y_predict, y_test);




%% predition test with buffer

% trial for testing
i_trial = 9;
y_true = BCI.classlabels(i_trial);

% lda of training data
[y_predict, linear_scores, class_probabilities] = lda_predict(model_lda, x_train(i_trial, :));

% get roi [channels x samples x trials]
[pre.ref, pre.ac, pre.cue, pre.trial, marker_info] = get_eeg_roi(eeg_data.pre, eeg_data.marker_rs, params, BCI);

% test buffer
y_pred_true = buffer_prediction(pre.trial(:, :, i_trial), y_true, BCI, fw1, fw2);

n_samples = size(pre.trial, 2);

score = [];
jump = 64;
for si = 1:jump:n_samples-1
  read_buffer = pre.trial(:, si:si+jump, i_trial);
  y_pred_true = buffer_prediction(read_buffer, y_true, BCI, fw1, fw2);
  %i_trial = i_trial + 1;
  score = [score, y_pred_true];
end
mu_score = mean(score);

fprintf('trial: [%d], true label: [%d], lda_predict: [%d], buffer_predict correct: [%d], score: [%d]\n', i_trial, y_true, y_predict, y_pred_true, mu_score)
