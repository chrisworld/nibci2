%% Preload script for the Graz_bci_model
% Called by model call back functions "PreLoadFcn" 

clear %all;

% Add the library (with sub folders) to the matlab path
addpath('TiA_client');

% Define global storage variable
global BCI;

%% Definitions for the "TiA/TiD Client" block
% This is a combined client to receive raw data via TiA and events via TiD.
% The packet ID is a unique ascending value for incomming data packets.
% The timestamp represents the TiA timestamp, which is a uint64 in 
% microseconds since the TiA server start. TiD events are aligned 
% according to the Packet ID
% The Sys/Sim time port shows the difference between the system time and the 
% simulation time. An ascending value indicates, that the simulation is running
% too slow! (a slowly decreasing sys/sim time can occur because of rounding 
% errors within the calculation)

BCI.TiATiD_client.TiA_server_ip     = '127.0.0.1';
BCI.TiATiD_client.TiA_server_port	= 9000;
BCI.TiATiD_client.protocol          = 'tcp';
BCI.TiATiD_client.TiA_version       = '1.0';
BCI.TiATiD_client.use_TiD           = 0;
BCI.TiATiD_client.TiD_server_ip     = '127.0.0.1';
BCI.TiATiD_client.TiD_server_port   = 9100;

% Get config data from signalserver for TiA/TiD Client
try
  [BCI.SampleRate, BCI.Blocksize, BCI.sig_info_labeled, BCI.ch_info] = ...
      TiA_matlab_get_config(BCI.TiATiD_client.TiA_server_ip,...
                            BCI.TiATiD_client.TiA_server_port,...
                            BCI.TiATiD_client.TiA_version);
catch err
  BCI.sig_info_labeled = {-1, 'not-conncted', -1, -1 ,-1 ,-1};
  disp(' ');
  disp(err.message);
  disp('ERROR: SignalServer is not connected!');
  disp(' ');
  return;
end

% sig_info without labels for reading data in TiA/TiD Client
BCI.sig_info = BCI.sig_info_labeled;
BCI.sig_info(:,2) = [];
BCI.sig_info = cell2mat(BCI.sig_info);

%% Display TiA/TiD protocol connection info
BCI.server_info{1} = BCI.TiATiD_client.protocol;
BCI.server_info{2} = BCI.TiATiD_client.TiA_server_ip;
BCI.server_info{3} = BCI.TiATiD_client.TiA_server_port;
BCI.server_info{4} = BCI.TiATiD_client.TiA_version;

disp('# TiA/TiD protocol connection info:');
disp(' ');
disp('SignalServer Information (protocol, server-IP, server-port):');
disp(BCI.server_info);
disp('Sampling Rate and Blocksize:');
disp([BCI.SampleRate BCI.Blocksize]);
disp('Signal Types Info:  (Flag, Type, BS, NrCh, Fs)');
disp(BCI.sig_info_labeled);
disp('Channel Info:  (Name, Type)');
disp(BCI.ch_info);

%% Generate timings
BCI.nTrials = 10;

time_pre_run    = 5;
time_pre_cue    = 2;
time_cue        = 1;
time_mi         = 5;
time_break      = 2;
time_post_run   = 5;

% start run
markers = 1;
rel_timings = 0;
rel_timings(end+1) = rel_timings(end) + time_pre_run;
for cTrial = 1:BCI.nTrials
    % trial start
    markers(end+1) = 2;
    % cue start
    markers(end+1) = 3;
    rel_timings(end+1) = rel_timings(end) + time_pre_cue;
    % mi start
    markers(end+1) = 4;
    rel_timings(end+1) = rel_timings(end) + time_cue;
    % break start
    markers(end+1) = 5;
    rel_timings(end+1) = rel_timings(end) + time_mi;
    % break
    rel_timings(end+1) = rel_timings(end) + time_break + 2*rand(1);
end
% end run marker
markers(end+1) = 6;
rel_timings(end) = rel_timings(end) + time_post_run;


BCI.markers = markers;
BCI.timings = rel_timings;
BCI.bufferSize = 64;
BCI.trialPeriod = time_pre_cue+time_cue+time_mi;
clear 'cTrial' 'markers' 'rel_timings' 'time_break' 'time_cue' 'time_mi' 'time_post_run' 'time_pre_cue' 'time_pre_run'
% clear 'offset' 'tMat' 'nSample' 'bufferS' 'timeInterval' 'duration' 'offsetMat' 'timings'

%% Generate classlabels
classlabels = crossvalind('Kfold',BCI.nTrials,2);
BCI.classlabels = classlabels;
clear 'classlabels'