function ERP_Callback(hObject, handles)
    handles = guidata(hObject);
    
    if~(strcmp(handles.fig4.Visible,'on'))
        set(handles.fig4, 'Visible', 'on')
    end
        
    
    calcERP(handles);
    
    guidata(hObject, handles);
end