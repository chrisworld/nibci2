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

sepp = rand;
if BCI.markers(BCI.cStep) == 5
    %disp('Listener: ')
    %disp(toc(BCI.t_start)) 
    markerS = get(hLine, 'MarkerSize');
    if sepp > 0.5
        set(hLine, 'MarkerSize', markerS+10)
    else
        set(hLine, 'MarkerSize', markerS-10)
    end

end


drawnow('expose')
data.predicted = [predicted, round(sepp)];
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