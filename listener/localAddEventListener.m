function eventhandle = localAddEventListener
    blk = 'graz_bci_model/To Workspace';
    eventhandle = add_exec_event_listener(blk,'PreOutput',@accListener);
end