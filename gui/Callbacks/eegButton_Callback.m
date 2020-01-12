function eegButton_Callback(hObject, eventdata)
    handles = guidata(hObject);
    
    eeg = handles.fig.UserData.eeg.Data;
    n_ch = size(eeg,2);
    
    if(isvalid(handles.fig2))
        set(handles.fig2, 'Visible', 'on');    
        eegplot(reshape(permute(eeg, [2 1 3]), n_ch, []));
        guidata(hObject,handles)
    else
        handles.fig2 = figure(...
        'Units','normalized',...
        'OuterPosition',[0.3, 0.3, 0.7, 0.7],...
        'Visible','on'); 
        eegplot(reshape(permute(eeg, [2 1 3]), n_ch, []));
        guidata(hObject, handles)
    end
    
    %guidata(hObject, handles);
end