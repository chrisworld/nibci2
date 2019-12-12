function calcERP(handles)
    eeg = handles.fig.UserData.eeg.Data;
    Marker = handles.fig.UserData.Marker;
    BCI = handles.fig.UserData.BCI;
    n_ch = size(eeg,2);

    ch_selection = {'C3', 'Cz', 'C4'};
    
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
    
        % ERP check at acoustic

    % mean
    erp.ac_mean = mean(eeg_roi.ac, 3);

    % std
    erp.ac_std = std(eeg_roi.ac, 0, 3);

    % time vector
    %erp.t = -0.5 : params.rs_factor / BCI.SampleRate : (size(eeg_roi.ac, 2) - 0.5 * BCI.SampleRate / params.rs_factor) * params.rs_factor / BCI.SampleRate - params.rs_factor / BCI.SampleRate;
    T = params.rs_factor / BCI.SampleRate;
    erp.t = -0.5 : T : 0.5;
    
    % print erp 
    for ch = 1:length(ch_selection)

      handle_name = ['handles.erp' ch_selection{ch}];
      % plot
      %figure(20+ch)
      set(handles.fig4, 'currentaxes', eval(handle_name)); 
      
      plot(erp.t, erp.ac_mean(ch,:), '-b', 'LineWidth', 1.5)
      hold on
      plot(erp.t, erp.ac_mean(ch,:) + erp.ac_std(ch,:), '--b')
      xline(0)
      plot(erp.t, erp.ac_mean(ch,:) - erp.ac_std(ch,:), '--b')
      hold off
      %ylim([-15 20])
      title(ch_selection(ch))
      ylabel('Volt [uV]')
      xlabel('Time [s]')
      legend('mean', 'mean + std', 'mean - std')
    end

end