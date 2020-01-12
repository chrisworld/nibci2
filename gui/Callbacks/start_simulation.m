function start_simulation(time_pre_run, time_pre_cue, time_cue, time_mi,...
        time_break, time_post_run, nTrials)
    
    sim('graz_bci_model.slx');
    assignin('base', 'eeg', eeg);
    assignin('base', 'Marker', Marker);
    
    close_system('graz_bci_model.slx')
    
end