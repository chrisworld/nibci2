%% Init Buffer Callback
global BCI;

bufferS = get_param('graz_bci_model/Buffer','N');


nSample = BCI.trialPeriod * BCI.SampleRate/str2double(bufferS);
predicted = zeros(BCI.nTrials, nSample);
data.predicted = predicted ;

set_param('graz_bci_model/Buffer','UserData', data);