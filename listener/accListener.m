function accListener(block, ei) %#ok<INUSD>
% 
% Callback function for plotting the current adaptive filtering
% coefficients.
global BCI;

% get UserData from the buffer element
data = get_param(block.BlockHandle,'UserData');

% handles for the figure as well as 
%hFig = BCI.hFig;%data.fig;
%hFig = data.fig;
hFig = gcf;
predicted = data.predicted;

hAxes = hFig.Children;
hLine = hAxes.Children;
%disp(toc(BCI.t_start))

% read buffer: [samples x channels] -> [channels x samples]
read_buffer = permute(block.OutputPort(1).Data, [2 1]);

% get frequency bands
f_bands = load('trained_params/f_bands.mat');

% true or false prediction
%y_pred_true = buffer_prediction(read_buffer, BCI, f_bands.fw1, f_bands.fw2);

m = BCI.markers(BCI.cStep)-1;  

% if a trials starts and until the end of the MI part, classify
if m>=2 && m < 5
    idx = BCI.idx;
    y_pred_true = buffer_prediction(read_buffer, BCI, f_bands.fw1, f_bands.fw2);
    %disp('Listener: ')
    %disp(toc(BCI.t_start))
    if m == 4

        % limit marker size
        lim_bottom = 20;
        lim_top = 800;

        markerS = get(hLine, 'MarkerSize');

        % change marker according to prediction
        if y_pred_true
            set(hLine, 'MarkerSize', min(max(markerS+10, lim_bottom), lim_top))
        else
            set(hLine, 'MarkerSize', min(max(markerS-10, lim_bottom), lim_top))
        end
    end
    data.predicted(idx+1) = data.predicted(idx+1) + y_pred_true;
    BCI.idx = idx+1;
    disp(BCI.idx)
end

drawnow('expose')
%data.predicted = [predicted, y_pred_true];
set_param(block.BlockHandle, 'UserData', data);







%t = block.OutputPort(1).Data;
%disp(t)
%disp(BCI.classlabels(BCI.cStep))
%size(t)
%######################################
% function applying CSP filtering and applying classification from here!
%######################################

%sepp = get_param(block.OutputPort(3), 'Data')

% stemPlot  = get_param(block.BlockHandle,'UserData');
% 
% est = block.Dwork(2).Data;
% set(stemPlot(2),'YData',est);
% drawnow('expose');