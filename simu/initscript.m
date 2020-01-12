%% Preload script for the Graz_bci_basic %%
% Called by model call back functions "InitFcn"

% Define global storage variable
global BCI;
global handles;
dims = get(groot, 'Screensize');
h = 720;
w = 1200;
BCI.x = zeros(h,w);
x_cross = BCI.x;
x_cross(round(h/2)-round(h/14):round(h/2)+round(h/14), round(w/2)-round(w/5):round(w/2)+round(w/5)) = 1;
x_cross(round(h/2)-round(w/5):round(h/2)+round(w/5), round(w/2)-round(h/14):round(w/2)+round(h/14)) = 1;

BCI.x_cross = x_cross;

imshow(BCI.x);
%BCI.ax = gca;

load train;
BCI.Fs = Fs;
BCI.y = y;

clear y Fs x_cross h w dims

% Initialization parameters
%set_param(bdroot, 'SolverName', 'FixedStepDiscrete');
set_param(bdroot, 'SolverName', 'FixedStep');
set_param(bdroot, 'FixedStep', [ num2str(1) '/' num2str(BCI.SampleRate)])