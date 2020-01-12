function calcPDS(handles)
    %global BCI;
    %global handles;
    
    eeg = handles.fig.UserData.eeg.Data;
    Marker = handles.fig.UserData.Marker;
    BCI = handles.fig.UserData.BCI;
    n_ch = size(eeg,2);


    eeg_data.time = Marker.Time;
    eeg_data.marker = Marker.Data;

    % reshape eeg to 1 x 16 x numSamples
    eeg_data.flat = reshape(permute(eeg, [2 1 3]), n_ch, []);

    % resample factor
    params.rs_factor = 2;

    % resample
    [eeg_data.rs, eeg_data.time_rs, eeg_data.marker_rs] = resample_eeg(eeg_data, params);

    %eegplot(eeg_data.flat);

    %% ------------------------------------------------------------------------
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

    %% ------------------------------------------------------------------------
    % spatial filtering (optional)

    eeg_data.spat = laplace_filter(eeg_data.pre);

    %% ------------------------------------------------------------------------
    % get region of interest -> reference and cue samples
    [eeg_roi.ref, eeg_roi.ac, eeg_roi.cue, eeg_roi.trial, marker_info] = get_eeg_roi(eeg_data, params, BCI);

    %% ------------------------------------------------------------------------
    % psd

    % psd params
    params.N = 64;
    params.nfft = 512;

    % channels
    ch_selection = {'C3', 'Cz', 'C4'};

    for ch = 1:length(ch_selection)
        
      handle_name = ['handles.pds' ch_selection{ch}];
        
      % ordering [ch, samples, trials]
      eeg_c1 = squeeze(permute(eeg_roi.cue(ch, :, transpose(BCI.classlabels == 1)), [1, 3, 2]));
      eeg_c2 = squeeze(permute(eeg_roi.cue(ch, :, transpose(BCI.classlabels == 2)), [1, 3, 2]));

      % init place holder
      psd_c1 = zeros(size(eeg_c1, 1), params.nfft/2 + 1);
      psd_c2 = zeros(size(eeg_c1, 1), params.nfft/2 + 1);
      
      
      % run all trials
      for tr = 1 : size(eeg_c1, 1)
        % calc psd
        [psd_c1(tr, :), f] = (pwelch(eeg_c1(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2));
        [psd_c2(tr, :), f] = pwelch(eeg_c2(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
      end

      % make a psd plot
      %figure(10+ch)
      %hold on 
      set(handles.fig3, 'currentaxes', eval(handle_name));
      plot(f, mean(psd_c1, 1)', '-b', 'LineWidth', 1.5)
      hold on
      plot(f, mean(psd_c2, 1)', '-r', 'LineWidth', 1.5)
      hold off
      ylim([0 25])
      title(ch_selection(ch))
      ylabel('PSD')
      xlabel('Time [s]')
      grid()
      legend('class 1', 'class 2')
    end

end