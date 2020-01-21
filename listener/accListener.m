function accListener(block, ei) %#ok<INUSD>
% 
% Callback function for plotting the current adaptive filtering
% coefficients.
global BCI;

% get UserData from the buffer element
blk = 'graz_bci_model/Buffer';
data = get_param(blk,'UserData');

% handles for the figure as well as 
%hFig = BCI.hFig;%data.fig;
%hFig = data.fig;
hFig = gcf;
predicted = data.predicted;

hAxes = hFig.Children;
hLine = hAxes(1).Children.Children;

% read buffer: [samples x channels] -> [channels x samples]
read_buffer = permute(block.InputPort(1).Data, [2 1]);

% get frequency bands
f_bands = load('trained_params/f_bands.mat');

% trial position
trial_pos = floor((BCI.cStep+2) / 4);

% end of this script
if(trial_pos > length(BCI.classlabels))
  return
end

% label
y_true = BCI.classlabels(trial_pos);

% true or false prediction
%y_pred_true = buffer_prediction(read_buffer, y_true, BCI, f_bands.fw1, f_bands.fw2);


m = BCI.markers(BCI.cStep)-1;  

% if a trials starts and until the end of the MI part, classify
if m>=2 && m < 5
    idx = BCI.idx;
    y_pred_true = buffer_prediction(read_buffer, y_true, BCI, f_bands.fw1, f_bands.fw2);
    %disp('Listener: ')
    %disp(toc(BCI.t_start))
    if m == 4

        % limit marker size
        lim_bottom = 20;
        lim_top = 800;

        markerS = get(hLine, 'MarkerSize');
        %markerColor = (markerS - lim_bottom)/(lim_top - lim_bottom);
        %disp(markerColor)
        %set(hLine, 'MarkerFaceColor', [markerColor 0.5 0.5]);

        % change marker according to prediction
        if y_pred_true
            set(hLine, 'MarkerSize', min(max(markerS+20, lim_bottom), lim_top))
            %set(hLine, 'MarkerFaceColor', [markerColor 0.5 0.5]);
        else
            set(hLine, 'MarkerSize', min(max(markerS-20, lim_bottom), lim_top))
            %set(hLine, 'MarkerFaceColor', [markerColor 0.5 0.5]);
        end
    end
    data.predicted(trial_pos, idx+1) = y_pred_true;
    BCI.idx = idx+1;
end

drawnow('expose')
%data.predicted = [predicted, y_pred_true];
set_param(blk, 'UserData', data);


