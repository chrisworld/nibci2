function [sys,x0,str,ts] = timings(t,x,u,flag)

global BCI;
%global fig;

switch flag,
  case 0 % Initialization
      [sys,x0,str,ts]   = mdlInitializeSizes;
      BCI.t_start = tic;
      BCI.cStep = 1;
      BCI.stopSim = false;
      
  case 3 % Outputs
      if BCI.cStep > length(BCI.markers)
          out = false;
          stopSim = true;
      elseif toc(BCI.t_start) > BCI.timings(BCI.cStep)
          out = BCI.markers(BCI.cStep);
          stopSim = false;
          hFig = gcf;
          hAxes = hFig.Children;
          switch BCI.markers(BCI.cStep),
          case 2
              imshow(BCI.cross, 'Parent', hAxes);
          case 3
              %hFig = gcf;
              %hAxes = hFig.Children;    
              %disp('case 3')
              label = BCI.classlabels(floor((BCI.cStep+1)/4));

              %disp(toc(BCI.t_start))
              if label == 1
                imshow(BCI.hand, 'Parent', hAxes);
              else
                imshow(BCI.foot, 'Parent', hAxes);
              end
          %case 4
              %disp('case 4')
              %disp(toc(BCI.t_start))

              %plot(1,1, '.g', 'MarkerSize', 200, 'Parent', hAxes);
          case 5
              imshow(BCI.black, 'Parent', hAxes);
              %disp('case 5')
              %disp(toc(BCI.t_start))
          end
          
          %if out == 4
              %BCI.hFig = plot(1,1, '.g', 'MarkerSize', 200, 'Parent',hAxes);
          %end
          
          %hAxes = 
          %end
          %data = get_param('graz_bci_model/Buffer', 'UserData');
          %hAxes = data.fig.Children;
          %if out == 1
          %  disp(hAxes)
          %end
          %disp(out)
          
          
          BCI.cStep = BCI.cStep+1;
      else
          out = false;
          stopSim = false;
      end
      %data = get_param('graz_bci_model/Buffer', 'UserData');
      %hAxes = data.fig.Children;
      %if out == 1
          %imshow([0 0 0], 'Parent', hAxes);
      %    disp(hAxes)
      %end  
      sys = double([out, stopSim]);
      
  case 9 % Stopping model
     
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