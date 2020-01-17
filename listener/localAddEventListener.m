function eventhandle = localAddEventListener
    %blk = 'graz_bci_model/TiA and TiD Client';
    blk = 'graz_bci_model/Buffer';
    eventhandle = add_exec_event_listener(blk,'PostOutputs',@accListener);
    %eventhandle = add_exec_event_listener(
end