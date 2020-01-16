function l = laplace_filter(X)

  % C3a: FC3, C5, C1, CP3
  C3_idx = 8;
  Cz_idx = 10;
  C4_idx = 12;

  l = zeros(3, length(X));

  l(1, :) = X(C3_idx, :);
  l(2, :) = X(Cz_idx, :);
  l(3, :) = X(C4_idx, :);

  fprintf('Laplace filtering not implemented, only C3, Cz and C4 selected.\n')

  %FC3_idx = 2;
  %C5_idx = 5;


  % laplace filter 
  %Fz_art_lap = art(Fz_index, :) - 1/4 * ( art(AFz_index, :) + art(FC2_index, :) + art(F2_index, :) + art(F1_index, :) );
  %Cz_art_lap = art(Cz_index, :) - 1/4 * ( art(FC2_index, :) + art(CPz_index, :) + art(C2_index, :) + art(C1_index, :) );
  %Oz_art_lap = art(Oz_index, :) - 1/4 * ( art(POz_index, :) + art(Iz_index, :) + art(O2_index, :) + art(O1_index, :) );


  %    'FCzb'    'eeg'
  %    'FC3a'    'eeg'
  %    'FCza'    'eeg'
  %    'FC4a'    'eeg'
  %    'C5a'     'eeg'
  %    'C3'      'eeg'
  %    'C1b'     'eeg'
  %    'C1a'     'eeg'
  %    'Cz'      'eeg'
  %    'C2a'     'eeg'
  %    'C2b'     'eeg'
  %    'C4'      'eeg'
  %    'C6a'     'eeg'
  %    'CP3a'    'eeg'
  %    'CPza'    'eeg'
  %    'CP4a'    'eeg'