function start_Callback(hObject, eventdata)

    handles = guidata(hObject);
    global BCI

    time_pre_run = str2double(handles.preRunEdit.String);
    time_pre_cue = str2double(handles.preCueEdit.String);
    time_cue = str2double(handles.cueEdit.String);
    time_mi = str2double(handles.miEdit.String);
    time_break = str2double(handles.breakEdit.String);
    time_post_run = str2double(handles.postRunEdit.String);
    nTrials = str2double(handles.trialsEdit.String);
    
%     data = struct(  'preRun', time_pre_run,...
%                     'preCue', time_pre_cue,...
%                     'cue', time_cue,...
%                     'mi', time_mi,...
%                     'break', time_break,...
%                     'postRun', time_post_run,...
%                     'nTrials', nTrials);
    assignin('base','time_pre_run', time_pre_run);
    assignin('base','time_pre_cue', time_pre_cue);
    assignin('base','time_cue', time_cue);
    assignin('base','time_mi', time_mi);
    assignin('base','time_break',time_break);
    assignin('base','time_post_run', time_post_run);
    assignin('base','nTrials', nTrials);
    
    
    set(handles.fig, 'OuterPosition', [0 0 1 1]);
    %start_simulation(time_pre_run, time_pre_cue, time_cue, time_mi,...
       %time_break, time_post_run, nTrials);

    set(handles.background, 'Visible', 'off');
    assignin('base', 'handles', handles);
    
%---%---%---%---%---%---%---%---% comment on mac version
    
            sim('graz_bci_model.slx');
            save_system('graz_bci_model.slx');
            close_system('graz_bci_model.slx');


            %eeg = evalin('base', 'eeg');
             assignin('base', 'eeg', eeg);
             assignin('base', 'Marker', Marker);
             %assignin('base', 'BCI', BCI);
             assignin('base', 'tout', tout);
% 
% 
% 
% 
            v = genvarname(['workspace_' date]);
            d.eeg = eeg;
            d.Marker = Marker;
            d.BCI = BCI;
            d.tout = tout;

            save(['data/' v '.mat'],'d');
            set(handles.fig, 'UserData', d);

%---%---%---%---%---%---%---%---% comment on mac version
    
    %postProcessing;
    %set(handles.fig, 'OuterPosition',[0 0 1 1]);
    %set(handles.eegPlot, 'Visible', 'on');
    %set(handles.axesEEG, 'Visible', 'on');
    set(handles.fig, 'OuterPosition', [0 0 0.3 1])
    set(handles.dataScreen, 'Visible', 'on');
    
    set(handles.background, 'Visible', 'off');
    

    guidata(hObject, handles);
    
end
    
    
    