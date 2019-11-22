function fig = eeg_plot_update(fig, x, t, fs)
  % This is a lightwight eeg plot updated function
  % give a figure to update and the data
  % params:
  %   fig - input figure to update
  %   x - input eeg signal
  %   fs - sampling frequency


  h = animatedline('Marker','o');
  addpoints(h, t, x);
  drawnow




end