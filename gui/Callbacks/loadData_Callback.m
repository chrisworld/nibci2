function loadData_Callback(hObject, eventdata)
    handles = guidata(hObject);
    [FileName,PathName] = uigetfile('*.mat','Select mat file');
    load([PathName FileName]);
    
    set(handles.fig, 'UserData', d);
    
    guidata(hObject, handles);
end