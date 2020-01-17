function [psd_c1, psd_c2] = calc_psd(eeg, params, BCI)

  % psd params
  params.N = 64;
  params.nfft = 512;

  % channels
  ch_selection = {'C3', 'Cz', 'C4'};

  for ch = 1:length(ch_selection)
    
    % ordering [ch, samples, trials]
    eeg_c1 = squeeze(permute(eeg(ch, :, transpose(BCI.classlabels == 1)), [1, 3, 2]));
    eeg_c2 = squeeze(permute(eeg(ch, :, transpose(BCI.classlabels == 2)), [1, 3, 2]));

    % init place holder
    psd_c1 = zeros(size(eeg_c1, 1), params.nfft/2 + 1);
    psd_c2 = zeros(size(eeg_c2, 1), params.nfft/2 + 1);

    % run all trials
    for tr = 1 : size(eeg_c1, 1)
      % calc psd
      [psd_c1(tr, :), f] = pwelch(eeg_c1(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
      [psd_c2(tr, :), f] = pwelch(eeg_c2(tr, :), hanning(params.N), params.N / 2, params.nfft, BCI.SampleRate/2);
    end

    % make a psd plot
    figure(10+ch)
    hold on 
    plot(f, mean(psd_c1, 1), '-b', 'LineWidth', 1.5)
    plot(f, mean(psd_c2, 1), '-r', 'LineWidth', 1.5)
    hold off
    
    % same scale
    ylim([0 15])

    title(ch_selection(ch))
    ylabel('PSD')
    xlabel('Time [s]')
    grid()
    legend('hand', 'foot')
    %print(['P300_std_' char(ch_selection(i))],'-dpng')
  end

  fprintf('PSD calculated.\n')
