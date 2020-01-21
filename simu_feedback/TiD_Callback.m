%% Closing callback TiA and TiD Client
global BCI;

hFig = gcf;
close(hFig);
bufferS = str2num(get_param('graz_bci_model/Buffer','N'));
fig = figure(1);
hAx = axes(fig);
x = (1:size(predicted,2))/(BCI.SampleRate/bufferS);
y = (sum(predicted,1)/BCI.nTrials)*100;
idx = find(x==4);
grey = [230, 230, 230]./255;
area(x(idx:end), ones(length(x(idx:end)),1)*100,'basevalue',0,'FaceColor',grey,'Parent',hAx);
hold on
plot(x,y, 'Parent', hAx, 'LineWidth',2);
title(['Average Accuracy for ' num2str(BCI.nTrials) ' Trials']);
hold on

accHand = sum(predicted(BCI.classlabels == 1,:),1) / sum(BCI.classlabels == 1)*100;
accFoot = sum(predicted(BCI.classlabels == 2,:),1) / sum(BCI.classlabels == 2)*100;

plot(x, accHand, 'Parent', hAx, 'LineWidth', 2);
plot(x, accFoot, 'Parent', hAx, 'LineWidth', 2);

legend('activity period','average', 'hand', 'foot');

xlim([0, 8])
line([4, 4], [0, 100], 'lineStyle', '--', 'Color', 'r', 'LineWidth', 2)
xlabel('Time in s')
ylabel('Accuracy in %')

clear 'bufferS' 'cross' 'grey' 'crossAx' 'crossPanel' 'feedbackAx' ...
    'feedbackPanel' 'foot' 'footAx' 'footPanel' 'hand' 'handAx' 'handPanel' 'hAx' 'hFig' 'pos' 'temp'