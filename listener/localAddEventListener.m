function eventhandle = localAddEventListener
    %blk = 'graz_bci_model/TiA and TiD Client';
    %blk = 'graz_bci_model/Buffer';
    blk = 'graz_bci_model/To Workspace';
    %eventhandle = add_exec_event_listener(blk,'PostUpdate',@accListener);
    eventhandle = add_exec_event_listener(blk,'PreOutput',@accListener);
    %eventhandle = add_exec_event_listener(
end