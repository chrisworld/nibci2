function calcERDS(handles)
    
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
    
     %get region of interest -> reference and cue samples
    [eeg_roi.ref, eeg_roi.ac, eeg_roi.cue, eeg_roi.trial, marker_info] = get_eeg_roi(eeg_data, params, BCI);

        % erds map

    % erds map params
    erds_params.t = [-(marker_info.ref_samples(1) + marker_info.ac_samples(1) - 1) / (BCI.SampleRate / params.rs_factor), 0, marker_info.cue_samples(1) / (BCI.SampleRate / params.rs_factor)];
    erds_params.f_bord = [4, 30];
    erds_params.t_ref = [-(marker_info.ref_samples(1)  + marker_info.ac_samples(1) - 1) / (BCI.SampleRate / params.rs_factor), -marker_info.ac_samples(1) / (BCI.SampleRate / params.rs_factor)];

    % header train
    header_train.SampleRate = BCI.SampleRate / params.rs_factor;

    % trigger for the cue
    header_train.TRIG = marker_info.trial_cue_pos;

    % class labels for training
    header_train.Classlabel = transpose(BCI.classlabels);

    % permute to get [samples, ch]
    data = permute(eeg_data.spat, [2, 1]);

    % calculate erds maps
    erds_maps.c1 = calcErdsMap(data, header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 1);
    erds_maps.c2 = calcErdsMap(data, header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 2);

    % plot erds maps
    plotErdsMap(erds_maps.c1);
    plotErdsMap(erds_maps.c2);

end