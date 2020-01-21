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
addpath('./simu/TiA_client')
addpath('./sp')


% --
% some vars
n_ch = 16;


% --
% collect data

% run simulink always before

%% save run 1
trial_saver(1, BCI, eeg, Marker);


%% save run 2
trial_saver(2, BCI, eeg, Marker);


%% save run 3
trial_saver(3, BCI, eeg, Marker);


%% save run 4
trial_saver(4, BCI, eeg, Marker);


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
% spatial filtering (optional)

eeg_data.spat = laplace_filter(eeg_data.pre);


%%
% -- 
% epoch trials according to conditions

% get region of interest -> reference and cue samples
[eeg_roi.ref, eeg_roi.ac, eeg_roi.cue, eeg_roi.trial, marker_info] = get_eeg_roi(eeg_data.spat, eeg_data.marker_rs, params, BCI);


%%
% --
% calculate psd

[psd_c1, psd_c2] = calc_psd(eeg_roi.cue, params, BCI)


%%
% --
% ERDS maps

calc_erds(eeg_data.spat, marker_info, params, BCI)
