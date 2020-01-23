%% Closing callback TiA and TiD Client
global BCI;

hFig = gcf;
close(hFig);
bufferS = str2num(get_param('graz_bci_model/Buffer','N'));
fig = figure(...
    'Units', 'normalized',...
    'Position', [0.2 0.2 0.6 0.6]);
hAx = axes(fig);
x = (1:size(predicted,2))/(BCI.SampleRate/bufferS);
y = (sum(predicted,1)/BCI.nTrials)*100;
idx = find(x==3);

%chance level calcuation with confidence of 97.5%
%-------------------
%temp = binoinv([0.025 0.975], BCI.nTrials, 0.5);

%chance_lvl = temp(2)/BCI.nTrials*100;
%-------------------

grey = [230, 230, 230]./255;
area(x(idx:end), ones(length(x(idx:end)),1)*100,'basevalue',0,'FaceColor',grey,'Parent',hAx);
hold on
plot(x,y, 'Parent', hAx, 'LineWidth',2);
%stdshade(predicted,0.2,'b')
title(['Average Accuracy for ' num2str(BCI.nTrials) ' Trials'], 'FontSize', 20);

hold on
accHand = sum(predicted(BCI.classlabels == 1,:),1) / sum(BCI.classlabels == 1)*100;
accFoot = sum(predicted(BCI.classlabels == 2,:),1) / sum(BCI.classlabels == 2)*100;

plot(x, accHand, 'Parent', hAx, 'LineWidth', 2);
plot(x, accFoot, 'Parent', hAx, 'LineWidth', 2);
hold on
%plot(x, ones(size(predicted,2))*chance_lvl, 'Parent', hAx,...
%    'lineStyle', '--','LineWidth', 2, 'Color', 'r');

%legend('activity period','average','hand', 'foot','chance level');
legend('activity period','average','hand', 'foot');

xlim([1/(BCI.SampleRate/bufferS), 8])
%xlim([0, 8])

line([3, 3], [0, 100], 'lineStyle', '--', 'Color', 'k', 'LineWidth', 2)
xlabel('Time in s', 'FontSize', 16)
ylabel('Accuracy in %', 'FontSize', 16)

clear 'bufferS' 'cross' 'grey' 'crossAx' 'crossPanel' 'feedbackAx' ...
    'feedbackPanel' 'foot' 'footAx' 'footPanel' 'hand' 'handAx' 'handPanel' 'hAx' 'hFig' 'pos' 'temp'