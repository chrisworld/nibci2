% --
% ass2 debug file

close all;
clear all;
clc;

% octave packages
%pkg load signal;

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

% number of channels
n_ch = 16


% --
% concatenate runs

% eeg format
% [block, ch, time]

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
fw1 = [1, 30];
fw2 = [30, 60];

% filter
fb = filter_bank(eeg_data.spat, BCI, fw1, fw2);

size(fb)


% --
% train csp

% get trials
[eeg_c1.ref, eeg_c1.ac, eeg_c1.cue, eeg_c1.trial, marker_info] = get_eeg_roi(squeeze(fb(1, :, :)), eeg_data.marker_rs, params, BCI);
[eeg_c2.ref, eeg_c2.ac, eeg_c2.cue, eeg_c2.trial, marker_info] = get_eeg_roi(squeeze(fb(2, :, :)), eeg_data.marker_rs, params, BCI);


% csp training
% class dims: [samples x channels x trials]
csp = csp_train(permute(eeg_c1.trial, [2, 1, 3]), permute(eeg_c2.trial, [2, 1, 3]), 'standard');

size(csp)




% -- 
% epoch trials according to conditions

[eeg_roi.ref, eeg_roi.ac, eeg_roi.cue, eeg_roi.trial, marker_info] = get_eeg_roi(eeg_data.spat, eeg_data.marker_rs, params, BCI);