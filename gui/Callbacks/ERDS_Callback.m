function ERDS_Callback(hObject, eventdata)
    handles = guidata(hObject);
    
    %set(handles.fig4, 'Visible','on');
    
    calcERDS(handles);
guidata(hObject, handles);