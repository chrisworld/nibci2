%% Preload script for the Graz_bci_basic %%
% Called by model call back functions "InitFcn"

% Define global storage variable
global BCI;
%global fig;
%fig.fig = figure();


BCI.black = imread('black.png');
BCI.hand = imread('hand.png');
BCI.foot = imread('foot.png');
BCI.cross = imread('cross.png');

imshow(BCI.black);

%BCI.hFig = figure(...
    %'Units', 'normalized',...
    %'Position', [0, 0, 1, 1]);
%imshow(cross);



% Initialization parameters
%set_param(bdroot, 'SolverName', 'FixedStepDiscrete');

set_param(bdroot, 'SolverName', 'FixedStep');
%set_param('graz_bci_model','StartFcn','localAddEventListener');
set_param(bdroot, 'FixedStep', [ num2str(1) '/' num2str(BCI.SampleRate)])