
function equal = eeg_reshape()

  % check it
  N = 10;
  k = 1;

  disp("---eeg-reshape")
  block_size = 4;
  block_len = 4 * N / block_size;

  test_signal = sin(2 * pi * k / N * [1:4*N]);
  test_signal = linspace(1, 4 * N, 4 * N);

  t_s1 = size(test_signal);

  % blocked signal
  b_signal = zeros(block_size, block_len);

  for n = 1 : block_size
    b_signal(n, :) = test_signal((n-1) * block_len + 1 : n * block_len);
  end
  b_s1 = size(b_signal);

  b_signal = cat(3, b_signal, b_signal);
  b_s2 = size(b_signal);

  b_signal = permute(b_signal, [2 1 3]);
  b_s3 = size(b_signal);

  r_signal = squeeze(reshape(b_signal, 1, []));
  r_s = size(r_signal);

  r_signal = reshape(r_signal, [], 2)';

  equal = isequal(r_signal(1, :), test_signal)


  % plot test and restored function
  %figure(14)
  %hold on
  %plot(r_signal(1, :))
  %plot(test_signal, '-r')
  %hold off


  % old reshape
  % probably wrong
  %eeg_data.flat = squeeze(reshape(eeg, 1, 16, []));