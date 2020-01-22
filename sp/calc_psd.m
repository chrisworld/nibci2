function [psd_c1, psd_c2] = calc_psd(eeg, params, BCI)

  % psd params
  params.N = 64;
  params.nfft = 512;

  % channels
  ch_selection = {'C3', 'Cz', 'C4'};

  % amount of classes
  n_c1 = sum(BCI.classlabels == 1);
  n_c2 = sum(BCI.classlabels == 2);

  % psd init [ch x trials x samples]
  psd_c1 = zeros(3, n_c1, params.nfft/2 + 1);
  psd_c2 = zeros(3, n_c2, params.nfft/2 + 1);

  for ch = 1:length(ch_selection)
    
    % ordering [ch, samples, trials]
    eeg_c1 = squeeze(permute(eeg(ch, :, transpose(BCI.classlabels == 1)), [1, 3, 2]));
    eeg_c2 = squeeze(permute(eeg(ch, :, transpose(BCI.classlabels == 2)), [1, 3, 2]));

    % run all trials
    for tr = 1 : size(eeg_c1, 1)
      % calc psd
      [psd_c1(ch, tr, :), f] = pwelch(eeg_c1(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
      [psd_c2(ch, tr, :), f] = pwelch(eeg_c2(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
    end

  end


  % calc mean of trials
  mu_psd_c1 = squeeze(mean(psd_c1, 2));
  mu_psd_c2 = squeeze(mean(psd_c2, 2));

  % get highest peak
  mu_ch = mean(mu_psd_c1, 1);

  % find max peaks
  [p, v] = findpeaks(mu_ch);

  % set max
  h_max = max(p);
  % set height
  %if length(p) >= 2
  %  h_max = p(2) * 2.5;
  %else
  %  h_max = p(1);
  %end

  % plot
  for ch = 1:length(ch_selection)

    % make a psd plot
    figure(10+ch)
    hold on 
    plot(f, mu_psd_c1(ch, :), '-b', 'LineWidth', 1.5)
    plot(f, mu_psd_c2(ch, :), '-r', 'LineWidth', 1.5)
    hold off
    
    % same scale
    ylim([0 h_max])
    xlim([0 40])

    title(ch_selection(ch))
    ylabel('PSD')
    xlabel('Frequency [Hz]')
    grid()
    legend('hand', 'foot')
    print(['./plots/psd_', char(ch_selection(ch))],'-dpng')
  end

  fprintf('PSD calculated.\n')
