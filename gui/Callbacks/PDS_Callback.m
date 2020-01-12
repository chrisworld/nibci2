function PDS_Callback(hObject, eventdata)
    handles = guidata(hObject);
    
    set(handles.fig3, 'Visible', 'on');
    calcPSD(handles);
    
    guidata(hObject, handles);
end