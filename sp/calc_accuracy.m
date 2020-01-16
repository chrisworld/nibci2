% --
% Calculate accuracy

function acc = calc_accuracy(y_predict, y_true)

  % score accuracy
  correct_pred = sum(y_predict == y_true);
  false_pred = length(y_predict) - correct_pred;
  acc = correct_pred / length(y_predict);

  fprintf('\n---\n correct pred: [%d], false pred: [%d]  \n acc: [%.4f]\n', correct_pred, false_pred,  acc)




