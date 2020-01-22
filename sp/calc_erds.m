function calc_erds(eeg, marker_info, params, BCI)

  % erds map params
  erds_params.t = [-(marker_info.ref_samples(1) + marker_info.ac_samples(1) - 1) / (BCI.SampleRate / params.rs_factor), 0, marker_info.cue_samples(1) / (BCI.SampleRate / params.rs_factor)];
  erds_params.f_bord = [4, 30];
  erds_params.t_ref = [-(marker_info.ref_samples(1)  + marker_info.ac_samples(1) - 1) / (BCI.SampleRate / params.rs_factor), -marker_info.ac_samples(1) / (BCI.SampleRate / params.rs_factor)];

  % header train
  header_train.SampleRate = BCI.SampleRate / params.rs_factor;

  % trigger for the cue sample index -> 4
  header_train.TRIG = marker_info.trial_cue_pos;

  % class labels for training
  header_train.Classlabel = transpose(BCI.classlabels);

  % permute to get [samples, ch]
  data = permute(eeg, [2, 1]);

  % calculate erds maps
  erds_maps.c1 = calcErdsMap(data, header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 1);
  erds_maps.c2 = calcErdsMap(data, header_train, erds_params.t, erds_params.f_bord, 'ref', erds_params.t_ref, 'sig', 'boot', 'alpha', 0.01, 'class', 2);

  % plot erds maps: ERS is blue and ERD is red
  plotErdsMap(erds_maps.c1);
  plotErdsMap(erds_maps.c2);

  fprintf('ERDS calculated.\n')