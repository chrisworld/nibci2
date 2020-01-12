function [sys,x0,str,ts] = timings(t,x,u,flag)

global BCI;
global handles;

switch flag,
  case 0 % Initialization
      [sys,x0,str,ts]   = mdlInitializeSizes;
      BCI.t_start = tic;
      BCI.cStep = 1;
      %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
      BCI.ax = axes(handles.fig);
      imshow(BCI.x, 'Parent', BCI.ax);
      % Get rid of tool bar and pulldown menus that are along top of figure.
      set(gcf, 'Toolbar', 'none', 'Menu', 'none');
      BCI.stopSim = false;
      
  case 3 % Outputs
      if BCI.cStep > length(BCI.markers)
          out = false;
          stopSim = true;
      elseif toc(BCI.t_start) > BCI.timings(BCI.cStep)
          out = BCI.markers(BCI.cStep);
          stopSim = false;
          switch BCI.markers(BCI.cStep),
              case 2
                  imshow(BCI.x_cross, 'Parent', BCI.ax);
                  %pause(2)
                  %disp(toc(BCI.t_start))
                  %sound(BCI.y(1:BCI.Fs),BCI.Fs)
              case 3
                  sound(BCI.y(1:BCI.Fs),BCI.Fs)                  
        
              case 4
                  Paradigm
              case 5
                  imshow(BCI.x, 'Parent', BCI.ax);

          end
          BCI.cStep = BCI.cStep+1;
      else
          out = false;
          stopSim = false;
      end
      sys = double([out, stopSim]);
      
  case 9 % Stopping model
      %close gcf
      %set(handles.fig,'OuterPosition', [0 0 1 1]);
      %set(handles.background, 'Visible', 'off');
      %handles.fig.OuterPosition = [0 0 1 1];
      %handles.background.Visible = 'off';
     
  case { 1, 2, 4} % Other states
      sys=[];

  otherwise % Unexpected flags (error handling)
      error(['Unhandled flag = ',num2str(flag)]);
end
% end function


function [sys,x0,str,ts] = mdlInitializeSizes()
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.

global BCI;

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2;  % dynamically sized
sizes.NumInputs      = 0;  % dynamically sized
sizes.DirFeedthrough = 1;  % has direct feedthrough
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = [];
ts  = [1/BCI.SampleRate 0];   % set sample time
