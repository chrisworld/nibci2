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
eeg_ = eeg;

%load('eeg_data120.mat')
%eeg_ = eeg.Data;

% number of channels
n_ch = 16

% concatenate runs

% eeg format
% [block, ch, time]

% add times and Marker to struct
eeg_data.time = Marker.Time;
eeg_data.marker = Marker.Data;

% reshape eeg to 1 x 16 x numSamples
eeg_data.flat = reshape(permute(eeg_, [2 1 3]), n_ch, []);
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
% epoch trials according to conditions

% get region of interest -> reference and cue samples
[eeg_roi.ref, eeg_roi.ac, eeg_roi.cue, eeg_roi.trial, marker_info] = get_eeg_roi(eeg_data, params, BCI);
size_trial = size(eeg_roi.trial)

% [ch, samples, trials]

size(BCI.classlabels)
size(eeg_roi.cue)

%BCI.classlabels == 1


% -- 
% calculate PSD

% psd params
params.N = 64;
params.nfft = 512;

% channels
ch_selection = {'C3', 'Cz', 'C4'};

for ch = 1:length(ch_selection)
  
  % ordering [ch, samples, trials]
  eeg_c1 = squeeze(permute(eeg_roi.cue(ch, :, transpose(BCI.classlabels == 1)), [1, 3, 2]));
  eeg_c2 = squeeze(permute(eeg_roi.cue(ch, :, transpose(BCI.classlabels == 2)), [1, 3, 2]));

  % init place holder
  psd_c1 = zeros(size(eeg_c1, 1), params.nfft/2 + 1);
  psd_c2 = zeros(size(eeg_c1, 1), params.nfft/2 + 1);

  % run all trials
  for tr = 1 : size(eeg_c1, 1)
    % calc psd
    [psd_c1(tr, :), f] = pwelch(eeg_c1(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
    [psd_c2(tr, :), f] = pwelch(eeg_c2(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
  end

  % make a psd plot
  figure(1+ch)
  hold on 
  plot(f, mean(psd_c1, 1), '-b', 'LineWidth', 1.5)
  plot(f, mean(psd_c2, 1), '-r', 'LineWidth', 1.5)
  hold off
  %ylim([-15 20])
  title(ch_selection(ch))
  ylabel('PSD')
  xlabel('Time [s]')
  grid()
  legend('class 1', 'class 2')
  %print(['P300_std_' char(ch_selection(i))],'-dpng')
end


%figure
%plot(f, psd)
%size(psd)

clear psd f;
size_spat = size(eeg_data.spat)




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
%erds_maps.c1 = calcErdsMap(sGes_train(:, 3), header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 1);


% plot erds maps
%plotErdsMap(erds_maps.c1);



% --
% Analyze eeg data

% ERP check at acoustic

ac_mean = mean(eeg_roi.ac, 3);
ac_size = size(ac_mean)

% std
ac_std = std(eeg_roi.ac, 0, 3);



% time vector
t = 0 : params.rs_factor / BCI.SampleRate : size(eeg_roi.ac, 2) * params.rs_factor / BCI.SampleRate - params.rs_factor / BCI.SampleRate;

% print everything
%%{
for ch = 1:length(ch_selection)
  figure(10+ch)
  hold on 
  plot(t, ac_mean(ch,:), '-b', 'LineWidth', 1.5)
  plot(t, ac_mean(ch,:) + ac_std(ch,:), '--b')
  plot(t, ac_mean(ch,:) - ac_std(ch,:), '--b')
  hold off
  %ylim([-15 20])
  title(ch_selection(ch))
  xlabel('Time [s]')
  ylabel('Volt [uV]')
  legend('mean', 'mean + std', 'mean - std')
  %print(['P300_std_' char(ch_selection(i))],'-dpng')
end
%}




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




    