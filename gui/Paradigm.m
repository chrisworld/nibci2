dims = get(groot, 'Screensize');
h = dims(4);
w = dims(3);

global BCI;
x = BCI.x;
label = BCI.classlabels(floor((BCI.cStep+1)/4));
if label == 1
    x_trans = 0;
    y_trans = 5;
else
    x_trans = 5;
    y_trans = 0;
end


translated = imtranslate(BCI.x_cross, [x_trans,y_trans]);
%for i=1:20
temp = tic;
while(toc(temp) < 1)
    for i=1:100
        imshow(translated, 'Parent', BCI.ax);
        translated = imtranslate(translated, [x_trans,y_trans]);
    end
    %temp2 = toc(temp);
end

