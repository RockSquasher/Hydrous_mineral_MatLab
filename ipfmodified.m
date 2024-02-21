 function ipf(arg1,arg2,arg3,arg4)
% Keyboard-operated Interactive Peak Fitter for data in separate x,y
% vectors, or in a single y vector, or in a 2xn or nx2 data matrix with x
% values in row/column 1 and y values in row/column 2 (e.g. [x y]). It's
% basically peakfit.m with an outer wrapper of user interface. Press K key
% for list of keyboard commands. Version 13.5: May, 2021; Added Pearson IV
% function (Shift-K ,shape 49),   a variably asymmetrical
% peak shape, equivalent to an exponentially skewed Gaussian.
%  One input argument:
%   ipf(y) or ipf([x;y]) or ipf([x;y]');
%  Two input arguments:
%   ipf(x,y) or ipf([x;y],center) or ipf([x;y]',center);
%  Three input arguments:
%   ipf(x,y,center) or ipf(y,center,window) or 
%   ipf([x;y],center,window) or ipf([x;y]',center,window);
%  Four input arguments:
%   ipf(x,y,center,window);
% See http://terpconnect.umd.edu/~toh/spectrum/ifpinstructions.html
% See http://terpconnect.umd.edu/~toh/spectrum/CurveFittingC.html
% See http://www.wam.umd.edu/~toh/spectrum/InteractivePeakFitter.htm
% T. C. O'Haver (toh@umd.edu).
%
% Example 1: 
% x=[0:.005:1];y=humps(x);ipf(x,y)
% Example 2: 
% x=[-10:.1:10];y=exp(-(x).^2);ipf(x,y)
% Example 3:
% x=[0:.1:10];y=exp(-(x-5).^2)+.5*exp(-(x-3).^2)+.1*randn(size(x));ipf(x,y)
% Example 4:
% x=[0:.01:18];
% y=exp(-(x-4).^2)+exp(-(x-9).^2)+exp(-(x-12).^2)+exp(-(x-13.7).^2);
% ipf(x,y,11,10);
% Example 5
% x=[-.1:.005:1.2];y=humps(x);ipf(x,y,0.6,1.2)
% Example 6
% x=[-5:.02:5];y=100.*x+100.*exp(-(x).^2)+randn(size(x));ipf(x,y)
%
% Keyboard Controls:
% Pan signal left and right...Coarse pan: < and >
%                             Fine pan: left and right cursor arrow keys
%                             Nudge: [ ] (one data point left and right)
% Zoom in and out.............Coarse zoom: / and '
%                             Fine zoom: up and down cursor arrow keys
% Resets pan and zoom.........ESC
% Select entire signal........Crtl-A
% Select # of peaks...........Number keys 1-9, or press 0 key to enter manually
% Complete peak shape menu... - (minus or hyphen), then type number and Enter
% Select peak shape...........g Gaussian
%                             Shift-G Fixed-width Gaussian
%                             Shift-P  Fixed-position Gaussians
%                             h Equal-width Gaussian
%                             Shift-H bifurcated Gaussian (a,z keys adjust shape)
%                             l Lorentzian
%                             ; Equal-width Lorentzian
%                             Shift-L Fixed-width Lorentzian
%                             Shift-[  Fixed-position Lorentzians
%                             Shift-B  Breit-Wigner-Fano (a,z keys adjust Fano factor)
%                             o Lognormal distribution (See "S" for logistic function)
%                             p Pearson (use a,z keys to adjust shape)
%                             e exponentially-broadened Gaussian
%                             Shift-R  ExpGaussian (var. tau)
%                             Shift-E Exponential-broadened Lorentzians
%                             j exponential-broadened equal-width Gaussian
%                                 (a,z keys adjust broadening)
%                             Shift-K PearsonIV peak
%                             u exponential pUlse: y=exp(-tau1.*x).*(1-exp(-tau2.*x))
%                             Shift-U Alpha: y=(x-tau2)./tau1.*exp(1-(x-tau2)./tau1);
%                             s Up Sigmoid (logistic function): y=.5+.5*erf((x-tau1)/sqrt(2*tau2))                                                       
%                             Shift-D Down Sigmoid (logistic function):  y=.5-.5*erf((x-tau1)/sqrt(2*tau2))                                                      
%                             ~ Gauss/Lorentz blend (a/z keys adjust shape)
%                             Shift-V Voigt profile (a/z adjusts shape)
%                             Shift-T  Triangular
%  Select other peak shapes by number: press - key to display menu.
% Fit.........................f  perform single Fit from another start point.
% Select BaselineMode mode....t  selects one of 5 available baseline corrections
% Monopolar/bipolar mode......= + Flips between + peaks only and +/- peak mode
% Toggle log y mode OFF/ON....m  Plot linear or log Y axis on lower graph
% 2-point Baseline............b, then click left and right baseline
% Set manual baseline.........Backspace, then click baseline at multiple points
% Restore original baseline...\  to cancel previous background subtraction
% Click start positions.......c, click on peak position for each peak
% Type in start vector........C (Shift-C) Type or Paste start vector [p1 w1 p2 w2 ...]
% Enter value of 'extra'......Shift-x, type value, press Enter.
% Adjust 'extra' up/down......a,z: 5% change; upper case A,Z: 0.5% change.
% Print parameters & results..q
% Print fit results only......r
% Plot signal in figure 2.....y
% save model to Disk..........d  Save model to disk as SavedModel.mat.
% Refine fit..................x  Takes best of 10 trial fits (change in line 224)
% Print peakfit function......w  with all input arguments
% Compute bootstrap stats.....v  Estimates standard deViations of parameters.
% Test effect of Noise........n  Test effect of Noise by fitting subset of points
% Save Figure as png file.....Shift-S  Saves as Figure1.png, Figure2.png....
% Display current settings....Shift-? displays table of current values
% Prints list of commands.....k
% Switch to iPeak.............Shift-Ctrl-P transfer current signal to iPeak.m
% Switch to iSignal...........Shift-Ctrl-S transfer current signal to iSignal.m
% Fit polynomial to segment...Shift-o  Asks for polynomial order
% Enter minimum width.........Shift-W  
% Enter saturation maximum....Shift-M
%
% Copyright (c) 2015, Thomas C. O'Haver
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 
global X Y xx yy xo dx NumPeaks NumTrials Shape shapesvector AA PEAKHEIGHTS xxx FigNum
global start extra DELTA BaselineMode SavedSignal logplot FIXEDPARAMETERS BIPOLAR
global CLIPHEIGHT MINWIDTH
%
% format short g
format compact
warning off all
warning OFF BACKTRACE
warning OFF VERBOSE
clf
% process input arguments
switch nargin % Process arguments
    % 'nargin' is the number of arguments
    case 1  % One argument only
        % Might be ipf(DataMatrix) ot ipf(Y-vector)
        % If data is in the wrong transposition, fix it.
        datasize=size(arg1);
        if datasize(1)<datasize(2),arg1=arg1';end
        datasize=size(arg1);
        if datasize(2)==1 %  Must be ipf(Y-vector)
            X=1:length(arg1); % Create an independent variable vector
            Y=arg1;
        else
            % Must be ipf(DataMatrix)
            X=arg1(:,1); % Split matrix argument
            Y=arg1(:,2);
        end
        xo=length(Y)/2; % Initial Pan setting
        dx=length(Y)/4; % Initial Zoom setting
    case 2
        % Two arguments, might be separate x and y data vectors,
        % or one adata matrix and a peak density estimate.
        if isscalar(arg2) % if second argument is scalar
            % Must be ipf(DataMatrix,center)
            % If DataMatrix is in the wrong transposition, fix it.
            datasize=size(arg1);
            if datasize(1)<datasize(2),arg1=arg1';end
            X=arg1(:,1); % Split matrix argument
            Y=arg1(:,2);
            xo=val2ind(X,arg2);
        else % if second argument is not scalar
            % Must be ipf(x,y)
            xdatasize=size(arg1);
            if xdatasize(1)<xdatasize(2),arg1=arg1';end
            X=arg1;  % First argument is X
            xdatasize=size(arg2);
            if xdatasize(1)<xdatasize(2),arg2=arg2';end
            Y=arg2; % Second argument is Y
            xo=length(Y)/2; %  % Default initial zoom setting
        end  % if isscalar
        dx=length(Y)/4; %  % Default initial zoom setting
    case 3
        % Might be ipf(DataMatrix,center,window) or ipf(x,y,center)
        if isscalar(arg2) % if second argument is scalar
            % Must be ipf(DataMatrix,center,window)
            % If DataMatrix is in the wrong transposition, fix it.
            datasize=size(arg1);
            if datasize(1)<datasize(2),arg1=arg1';'Transpose matrix';end
            datasize=size(arg1);
            if datasize(2)==2 % ipf(DataMatrix,center,window)
                X=arg1(:,1); % Split matrix argument
                Y=arg1(:,2);
                xo=val2ind(X,arg2); % Second argument is center
                dx=val2ind(X,arg3); % Third argument is window
            else % ipf(y,center,window)
                X=1:length(arg1); % Create an independent variable vector
                Y=arg1;
                xo=val2ind(X,arg2); % Second argument is center
                dx=val2ind(X,arg3); % Third argument is window
            end
        else % if second argument is not isscalar
            % Must be ipf(x,y,center)
            xdatasize=size(arg1);
            if xdatasize(1)<xdatasize(2),arg1=arg1';end
            X=arg1;  % First argument is X
            xdatasize=size(arg2);
            if xdatasize(1)<xdatasize(2),arg2=arg2';end
            Y=arg2; % Second argument is Y
            xo=val2ind(X,arg3); % third argument is center
            dx=length(Y)/4; % Default initial zoom setting
        end  % if isscalar
    case 4   % Must be ipf(x,y,center,window)
        % 'case 4   % Must be ipf(x,y,center,window) = ipf(DataMatrix,center,window,NumPeaks'
        xdatasize=size(arg1);
        if xdatasize(1)<xdatasize(2),arg1=arg1';end
        X=arg1;  % First argument is X
        xdatasize=size(X);
        if xdatasize(1)<xdatasize(2),X=X';end
        Y=arg2; % Second argument is Y
        xo=val2ind(X,arg3); % Third argument is center
        dx=val2ind(X,arg4); % Fourth argument is window
end

% Adjust X and Y vector shape to 1 x n (rather than n x 1)
X=reshape(X,1,length(X));
Y=reshape(Y,1,length(Y));
% If necessary, flip the data vectors so that X increases
if X(1)>X(length(X))
    disp('X-axis flipped.')
    X=fliplr(X);
    Y=fliplr(Y);
end

% Set initial values of parameters
NumPeaks=1; % Initial Number of peaks in model
NumTrials=10; % Number of repeat fits when X key is pressed (CHANGE AS DESIRED)
Shape=1; % Initial Shape of the peaks (1=Gaussian, 2=Lorentzian, etc)
shapesvector=Shape; 
extra=length(X)/100.*ones(size(Shape));
if Shape==20,extra=1;end
FigNum=1;
DELTA=0; % Initial Random change in initial start guesses for each re-fit
PEAKHEIGHTS=zeros(NumPeaks,1);
xxx=zeros(1,200);
AA=zeros(NumPeaks,200);
BaselineMode=0; % Default to no baseline correction Press T to select mode.
logplot=0; % Default to linear mode. Press m to change to log.
SavedSignal=Y;
FIXEDPARAMETERS=0; % Used only for fixed position or width shapes.
BIPOLAR=0; % Default to monopolar (positive peaks only) mode.
CLIPHEIGHT=max(Y);
MINWIDTH=X(2)-X(1);

% Plot the signal and its fitted components and residuals
figure(1)
RedrawSignal(X,Y,xo,dx,NumPeaks);
% if start==[];start=length(Y)/2;end
% peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,plots,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT)
[xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);

% Attaches KeyPress test function to the figure.
set(gcf,'KeyPressFcn',@ReadKey)
uicontrol('Style','text')
% end of outer function
% ----------------------------Main keyboard loop--------------------------------
function ReadKey(obj,eventdata)
% Interprets key presses from the Figure window.
global X Y xx yy xo dx start FitResults NumPeaks NumTrials Shape ShapeString residual
global DELTA AA xxx PEAKHEIGHTS BaselineMode extra MeanFitError SavedSignal
global  FIXEDPARAMETERS logplot et FigNum BIPOLAR shapesvector MINWIDTH CLIPHEIGHT
% (et=elapsed time)
% When a key is pressed, interprets key and calls corresponding function.
% Note: If you don't like my key assignments, you can change the numbers
% in the case statements here to re-assign that function to any other key.
NumTrialsBoot=1;
peakshape=Shape;
plots=1;
key=get(gcf,'CurrentCharacter');
if isscalar(key)
    ly=length(Y);
    switch double(key)
        case 28
            xo=xo-dx/20;
            if xo<1,xo=1;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 29
            xo=xo+dx/20;
            if xo>ly,xo=ly;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 91
            % Nudge down 1 point when [ pressed.
            xo=xo-1;
            if xo<1,xo=1;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 93
            % Nudge up 1 point when ] pressed.
            xo=xo+1;
            if xo>ly,xo=ly;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 44
            % Pans down when > key pressed.
            xo=xo-dx;
            if xo<1,xo=1;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 46
            % Pans up when < key pressed.
            xo=xo+dx;
            if xo>ly,xo=ly;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 31
            dx=dx+dx/10;
            if dx>ly,dx=ly;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 30
            dx=dx-dx/10;
            if dx<2,dx=2;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 47
            % Zooms 2% out when / pressed.
            dx=dx+ly/50;
            if dx>ly,dx=ly;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 39
            % Zooms 2% in when ' pressed.
            dx=dx-ly/50;
            if dx<2,dx=2;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 1 % Ctrl-A selects entire signal
            xo=length(Y)/2; % Initial Pan setting           
            dx=length(Y); % Initial Zoom setting
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);            
        case 109
            % When 'M' is pressed, toggles on/off log plot mode
            if logplot==0
                logplot=1;
                SavedSignal=Y;
                Y=abs(Y);
            else
                logplot=0;
                Y=SavedSignal;
            end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 27 % When 'ESC' key is pressed, resets pan and zoom
            xo=length(Y)/2; % Initial Pan setting
            dx=length(Y)/4; % Initial Zoom setting
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 102 % "f" key  f key
            % When 'f' key is pressed, tweaks start values, computes and
            % plots fit.
            %             center=(max(xx)+min(xx))/2;
            %             window=max(xx)-min(xx);
            %             startnow=start;
            %             DELTA=(max(xx)-min(xx))/100;
            %             for k=1:2*NumPeaks
            %                 startnow(k)=start(k)+(rand-.5)*DELTA;
            %             end
            center=(max(xx)+min(xx))/2;
            NumTrials=1;
            window=max(xx)-min(xx);
            if Shape==16||Shape==17 % Fixed-position shapes
                fixedparameters=FIXEDPARAMETERS;
            else
                fixedparameters=FIXEDPARAMETERS;
            end
            subplot(2,1,2);title('Working....');drawnow
            [FitResults,MeanFitError]=peakfit([X',Y'],center,window,NumPeaks,shapesvector,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
        case 99
            % When 'c' key is pressed, user clicks graph to enter start positons,
            % then fit is computed and graph re-drawn.
            % Acquire first-guess peak positions from user mouse pointer
            figure(1);subplot(2,1,1);xlabel('Click on the estimated positions of each proposed component peak.')
            [clickX,clickY] = ginput(NumPeaks);
            % Create a "start" vector using these peak positions, with peak
            % widths
            n=max(xx)-min(xx);
            width=n/(5*NumPeaks);
            start=[];
            for k=1:NumPeaks
                start=[start clickX(k) width];
            end
            if Shape==11||12
                fixedstart=[];
                for pk=1:NumPeaks
                    fixedstart(pk)=start(2*pk-1);
                end
                peakfit([xx;yy],0,0,NumPeaks,shapesvector,extra,1,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            end
            subplot(2,1,2);title('Working....');drawnow
            [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,plots,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
        case 67 % Shift-C allows keyboard entry of start vector
             disp('The current start vector is displayed below, in the order')
             disp('[position1 width1 position2 width2 ...]; you can Copy and Paste')
             disp('into the input prompt, edit desired values, and press Enter.')
             disp(['[' num2str(start) ']' ])
             startinput=input('Type [start vector] or press Enter to keep unchanged: ');
            if isempty(startinput)
            else
                start=startinput;
            end
             [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
        case 81 % Shift-Q
            disp(['First guess vector=' num2str(start)])
        case 98
            % When 'b' key is pressed, user clicks graph before and after peaks
            % to enter background points, then fit is computed and graph re-drawn.
            figure(1);subplot(2,1,1);xlabel('Click on the baseline to the LEFT the peak(s).')
            [X1,Y1] = ginput(1);
            figure(1);subplot(2,1,1);xlabel('Now click on the baseline to the RIGHT the peak(s).')
            [X2,Y2] = ginput(1);
            n=length(xx);
            %  Create "start" for this number of peaks
            yy=yy-((Y2-Y1)/(X2-X1)*(xx-X1)+Y1);
            [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,plots,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
        case 8
            % When 'Backspace' key is pressed, user clicks the graph
            % along the presumed background points, then the program
            % subtracts the interploated background between the points.
            SavedSignal=Y;
            BaselinePoints=input('Number of baseline points to click): ');
            if isempty(BaselinePoints),BaselinePoints=8;end
            % Acquire background points from user mouse clicks
            subplot(2,1,2)
            title(['Click on ' num2str(BaselinePoints) ' points on the baseline between the peaks.'])
            bX=[];bY=[];
            for g=1:BaselinePoints
                [clickX,clickY] = ginput(1);
                bX(g)=clickX;
                bY(g)=clickY;
                xlabel(['Baseline point '  num2str(g) ' / ' num2str(BaselinePoints) ])
            end
            yy=Y;
            for k=1:length(bX)-1
                fp=val2ind(X,bX(k)); % First point in segment
                lp=val2ind(X,bX(k+1));  % Last point in segment
                % Subtract piecewise linear background from Y
                yy(fp:lp)=Y(fp:lp)-((bY(k+1)-bY(k))/(bX(k+1)-bX(k))*(X(fp:lp)-bX(k))+bY(k));
            end
            Y=yy;
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 92
            % When '\' key is pressed, restoreed original signal
            Y=SavedSignal;
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case {49,50,51,52,53,54,55,56,57} % Number of peaks
            % When a number key is pressed, sets the number of peaks to that number.
            n=key-48;          
            ShapeString='';
            if round(n)~=NumPeaks
                NumPeaks=round(n);
                FitResults=zeros(NumPeaks,6);
                ShapeString=SelectShapeString(Shape);
                subplot(2,1,2)
                if BIPOLAR
                     xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + - ' ShapeString  ] )
                else
                     xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + ' ShapeString  ] )
                end               
            end % if
            n=max(xx)-min(xx);
            % Create a start value for this number of peaks
            start=[];
            startpos=[n/(NumPeaks+1):n/(NumPeaks+1):n-(n/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker);
                start=[start markx n/(5*NumPeaks)];
            end
            PEAKHEIGHTS=zeros(NumPeaks,1);
            AA=zeros(NumPeaks,200);
            RedrawSignal(X,Y,xo,dx,NumPeaks);
            if BIPOLAR
                xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + - ' ShapeString  ] )
             else
                xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + ' ShapeString  ] )
            end
        case 48  % Zero key is pressed to type in any number of peaks.
            disp(['Current number of peaks: ' num2str(NumPeaks)])
            NumPeaksInput=input('Type number or press Enter to keep unchanged: ');
            if isempty(NumPeaksInput)
            else
                NumPeaks=NumPeaksInput;
            end
            ShapeString=SelectShapeString(Shape);
            % Create a start value for this number of peaks
            n=max(xx)-min(xx);
            start=[];
            startpos=[n/(NumPeaks+1):n/(NumPeaks+1):n-(n/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker);
                start=[start markx n/(5*NumPeaks)];
            end
            PEAKHEIGHTS=zeros(NumPeaks,1);
            AA=zeros(NumPeaks,200);
            RedrawSignal(X,Y,xo,dx,NumPeaks);
            if BIPOLAR
                xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + - ' ShapeString  ] )
            else
                xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + ' ShapeString  ] )
            end
        case {103,108,111,112,101,104,59,106,117,115,71,76,96,72,66,80,123,69,85,86,68,84,82,75}
            % Selects peak shape when the following keys are pressed.
            switch key
                case 103 % When 'g' key is pressed, peak shape is set to Gaussian.
                    n=1;
                case 108 % When 'l' key is pressed, peak shape is set to Lorentzian.
                    n=2;
                case 111 % When 'o' key is pressed, peak shape is set to Lognormal distribution.
                    n=3;
                case 112 % When 'p' key is pressed, peak shape is set to Pearson.
                    n=4;
                case 101 % When 'e' key is pressed, peak shape is set to exponentally-broadened gaussian.
                    n=5;
                case 104 % When 'h' key is pressed, peak shape is set to equal width gaussians.
                    n=6;
                case 59 % When ';' key is pressed, peak shape is set to equal width gaussians.
                    n=7;
                case 106 % When 'J' key is pressed, peak shape is set to exponentally-broadened equal width gaussians.
                    n=8;
                case 117 % When 'U' key is pressed, peak shape is set to exponential pulse.
                    n=9;
                case 115 % When 'S' key is pressed, peak shape is set to Up Sigmoid (logistic function).
                    n=10;
                case 68  % When 'Shift-D' key is pressed, peak shape is set to Down Sigmoid (logistic function).
                    n=23;
                case 71 % When 'Shift-G' key is pressed, peak shape is set to FWGaussian.
                    n=11;
                    inputwidth=input('Peak width: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 76 % When ';' key is pressed, peak shape is set to FWLorentzian.
                    n=12;
                    inputwidth=input('Peak width: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 96 % When '`' key is pressed, peak shape is set to Gauss/Lorentz blend
                    n=13;
                case 72 % When 'Shift-H' key is pressed, peak shape is set to bifurcated Gaussian
                    n=14;
                case 66 % When Shift-B key is pressed, peak shape is set to Breit-Wigner-Fano
                    n=15;
                case 80 % When 'Shift-P' key is pressed, peak shape is set to Fixed-position Gaussians
                    n=16;
                    inputpositions=input('Peak positions as a vector, e.g. [200 400 600]: ');
                    if isempty(inputpositions)
                    else
                        FIXEDPARAMETERS=inputpositions;
                        FIXEDPOSITIONS=inputpositions;
                    end
                case 123 % When 'Shift-[' key is pressed, peak shape is set to Fixed-position Lorentzians
                    n=17;
                    inputpositions=input('Peak positions as a vector, e.g. [200 400 600]: ');
                    if isempty(inputpositions)
                    else
                        FIXEDPARAMETERS=inputpositions;
                    end
                case 69 % When 'Shift-E' key is pressed, peak shape is set to ExpLorentzian
                    n=18;
                case 85 % When 'Shift-U' key is pressed, peak shape is set to alpha function
                    n=19;
                case 86 % When 'Shift-V' key is pressed, peak shape is set to Voigt profile
                    n=20;   
                case 84  % When 'Shift-T' key is pressed, peak shape is set to triangular
                    n=21;
                case 82 % When Shift-R is pressed, pressed, peak shape is set to ExpGaussian (variable tau)
                    n=31;
                case 75 % When Shift-K is pressed, pressed, peak shape is set to PearsonIV
                    n=49;
                otherwise
            end
            % switch
            if round(n)~=Shape
                Shape=round(n);
                shapesvector=Shape;
                ShapeString=SelectShapeString(Shape);
                figure(1);subplot(2,1,2)
                if BIPOLAR
                    xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + - ' ShapeString  ] )
                else
                    xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + ' ShapeString  ] )
                end % end BIPOLAR
            end % if round(n)~=Shape
        case 45 % if '-' key pressed
            disp(' ')
            disp('Select the peak shape of the model (type 1-49 and press Enter key):')
            disp('For a multi-shape model, type a vector of shape numbers,')
            disp('with brackets, e.g. [2 2 1 3]):')
            disp('Gaussians: y=exp(-((x-pos)./(0.6005615.*width)) .^2)')
            disp('  Gaussians with independent positions and widths : 1 (default)')
            disp('  Exponentional-broadened Gaussian (equal taus): 5 ')
            disp('  Exponentional-broadened equal-width Gaussian : 8')
            disp('  Fixed-width exponentionally-broadened Gaussian = 36')
            disp('  Exponentional-broadened Gaussian (independent taus): 31 ')
            disp('  Exponentional-broadened Gaussian2 (independent taus): 39 ')
            disp('  Gaussians with the same widths : 6')
            disp('  Gaussians with preset fixed widths : 11')
            disp('  Fixed-position Gaussians : 16 ')
            disp('  Flattened Gaussian : 42 ')
            disp('  Double Gaussian: 49')
            disp('  Asymmetrical Gaussians with unequal half-widths on both sides : 14')      
            disp('Lorentzians: y=ones(size(x))./(1+((x-pos)./(0.5.*width)).^2)')
            disp('  Lorentzians with independent positions and widths : 2')
            disp('  Exponentional-broadened Lorentzian : 18 ')            
            disp('  Equal-width Lorentzians : 7')
            disp('  Fixed-width Lorentzian : 12')
            disp('  Fixed-position Lorentzian : 17')
            disp('  Asymmetrical Lorentzians with unequal half-widths on both sides : 15')
            disp('Gaussian/Lorentzian blend (equal blends): 13')
            disp('  Fixed-width Gaussian/Lorentzian blend = 35')
            disp('  Gaussian/Lorentzian blend (independent blends): 33')
            disp('Voigt profile (fixed alphas): 20')
            disp('  Fixed-width Voigt profile (fixed alphas) : 34')
            disp('  Voigt profile (independent alphas): 30')  
            disp('Logistic: n=exp(-((x-pos)/(.477.*wid)).^2); y=(2.*n)./(1+n) : 3  ')
            disp('Pearson: y=ones(size(x))./(1+((x-pos)./((0.5.^(2/m)).*wid)).^2).^m : 4')
            disp('  Fixed-width Pearson = 37')
            disp('  Pearson with independent shape factors, m : 32')            
            disp('Exponential pUlse: y=exp(-tau1.*x).*(1-exp(-tau2.*x)): 9')
            disp('  equal-width exponential pulses: 48')
            disp('  Alpha function: y=(x-spoint)./pos.*exp(1-(x-spoint)./pos); : 19')           
            disp('Sigmoidal shapes')
            disp('  Up Sigmoid (logistic function): y=.5+.5*erf((x-tau1)/sqrt(2*tau2)) : 10')
            disp('  Down Sigmoid y=.5-.5*erf((x-tau1)/sqrt(2*tau2) ): 23')
            disp('  3-parameter Gompertz: 43')
            disp('  4-parameter logistic: 45')
            disp('Triangular: 21')
            disp('Sine wave: 40')
            disp('Rectangular pulse: 41')
            disp('Exponential decay -exp(-k*t): 44')
            disp('Blackbody radiation: 47')
            disp('Baseline shapes:')
            disp('  Linear slope: 26')
            disp('  Quadratic Baseline: 46'); 
            disp('PearsonIV : 49')
            disp(' ')
            Shapeinput=input('Peak shape number or [vector]: ');
            if isempty(Shapeinput)
            else
                Shape=Shapeinput;
            end
            if isscalar(Shape)
            else
                disp('peakshape is vector');
                shapesvector=Shape;
                peakshape=Shape;
                NumPeaks=length(shapesvector);
                Shape=22;
                n=max(xx)-min(xx);
                extra=n/100.*zeros(size(shapesvector));
                start=[];
                startpos=[n/(NumPeaks+1):n/(NumPeaks+1):n-(n/(NumPeaks+1))]+min(xx);
                for marker=1:NumPeaks
                    markx=startpos(marker);
                    start=[start markx n/(5*NumPeaks)];
                end
                start=start;
            end
            if Shape>49, Shape=49;end
            if Shape<1, Shape=1;end
            if isempty(Shape),Shape=1;end
            switch Shape
                case 1
                    ShapeString='Gaussian';
                case 2
                    ShapeString='Lorentzian';
                case 3
                    ShapeString='Lognormal dist.';
                case 4
                    ShapeString='Pearson';
                case 5
                    ShapeString='ExpGauss.';
                case 6
                    ShapeString='Equal-width Gauss.';
                case 7
                    ShapeString='Equal-width Lorentz.';
                case 8
                    ShapeString='Equal-width ExpGauss.';
                case 9
                    ShapeString='Exponental pulse';
                case 10
                    ShapeString='Up Sigmoid (logistic func.)';
                case 11
                    ShapeString='Fixed-width Gauss.';
                    inputwidth=input('Peak width vector [width1 width2...]: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 12
                    ShapeString='Fixed-width Lorentzian.';
                    inputwidth=input('Peak width vector [width1 width2...]: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 13
                    ShapeString='Gauss/Lorentz blend';
                case 14
                    ShapeString='bifurcated Gauss..';
                case 15
                    ShapeString='Breit-Wigner-Fano';
                case 16
                    ShapeString='Fixed-position Gauss.';
                    inputpositions=input('Peak positions as a vector, e.g. [200 400 600]: ');
                    if isempty(inputpositions)
                    else
                        FIXEDPARAMETERS=inputpositions;
                    end
                case 17
                    ShapeString='Fixed-position Lorentz.';
                    inputpositions=input('Peak positions as a vector, e.g. [200 400 600]: ');
                    if isempty(inputpositions)
                    else
                        FIXEDPARAMETERS=inputpositions;
                    end
                case 18
                    ShapeString='ExpLorentz.';
                case 19
                    ShapeString='Alpha function';
                case 20
                    ShapeString='Voigt profile';
                case 21
                    ShapeString='triangular';
                case 22
                    ShapeString=num2str(shapesvector);
                case 23
                    ShapeString='Down Sigmoid (logistic func.)';
                case 24
                    ShapeString='Negative Binomial Dist.';
                case 25
                    ShapeString='Lognormal Dist.';
                case 26
                    ShapeString='slope';
                case 27
                    ShapeString='First derivative';
                case 28
                    ShapeString='Polynomial';
                case 29
                    ShapeString='Segmented linear';
                case 30
                    ShapeString='Voigt (var. alphas)';
                case 31
                    ShapeString='ExpGaussian (var. tau)';
                case 32
                    ShapeString='Pearson (var. shape)';
                case 33
                    ShapeString='Var. Gauss/Lorentz';
                case 34
                    ShapeString='Fixed-width Voigt';
                    inputwidth=input('Peak width vector [width1 width2...]: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 35
                    ShapeString='Fixed-width G/L blend';
                    inputwidth=input('Peak width vector [width1 width2...]: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 36
                    ShapeString='Fixed-width ExpGauss.';
                    inputwidth=input('Peak width vector [width1 width2...]: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 37
                    ShapeString='Fixed-width Pearson';
                    inputwidth=input('Peak width vector [width1 width2...]: ');
                    if isempty(inputwidth)
                    else
                        FIXEDPARAMETERS=inputwidth;
                    end
                case 38
                    ShapeString='ExpLorentz. (var. tau)'; 
                case 39
                    ShapeString='ExpGaussian2 (var. tau)'; 
                case 40
                    ShapeString='Sine wave';
                case 41
                    ShapeString='Rectangular pulse';
                case 42
                    ShapeString='Flattened Gauss.';
                case 43
                    ShapeString='3-parameter Gompertz.';
                case 44
                    ShapeString='1-exp(-k*t)';
                case 45
                    ShapeString='4-parameter logistic';
                case 46
                    ShapeString='Quadratic Baseline';
                case 47
                    ShapeString='Blackbody';
                case 48
                    ShapeString='Equal-width exp. pulse';
                case 49
                    ShapeString='PearsonIV'; 
                otherwise
            end % switch
            disp([ ShapeString  ' shape selected'])
            peakshape=Shape; % <<<<<
            shapesvector=Shape;  % <<<<<
            figure(1)
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
            subplot(2,1,2)
            if BIPOLAR
                xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + - ' ShapeString  ] )
            else
                xlabel(['Number of Peaks= ' num2str(NumPeaks) '    Shape= + ' ShapeString  ] )
            end
            
        case 88 % Shift-X
            disp(['Current value of ''extra'' parameter: ' num2str(extra) ] )
             ExtraInput=input('Type value, [vector] or press Enter to keep unchanged: ');
            if isempty(ExtraInput)
            else
                extra=ExtraInput;
            end
            if Shape==4||5||13||14||15||18 % Only do a re-fit if shape uses Extra parameter.
                [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            else
                [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
            end
            
        case 97
            % When 'a' key is pressed, increases "extra" by 5%
            extra=extra+.05*extra;
            if extra==0, extra=.01;end
            if Shape==4||5||13||14||15||18 % Only do a re-fit if shape uses Extra parameter.
                [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            else
                [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
            end
        case 122
            % When 'z' key is pressed, decreases "extra" by 5%
            extra=extra-.05*extra;
            if extra==0, extra=.01;end
            if Shape==4||5||13||14||15||18 % Only do a re-fit if shape uses Extra parameter.
                [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            else
                [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
            end
            
        case 65
            % When 'A' (Shift-A) key is pressed, increases "extra" by 0.5%
            extra=extra+.005*extra;
            if extra==0, extra=.001;end
            if Shape==4||5||13||14||15||18 % Only do a re-fit if shape uses Extra parameter.
                [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            else
                [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
            end
            
        case 90
            % When 'Z' (Shift-Z) key is pressed, decreases "extra" by 0.5%
            extra=extra-.005*extra;
            if extra==0, extra=.001;end
            if Shape==4||5||13||14||15||18 % Only do a re-fit if shape uses Extra parameter.
                [FitResults,MeanFitError]=peakfit([xx;yy],0,0,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            else
                [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
            end  
            
        case 114
            % When 'r' key is pressed, prints out table of fit results
            disp(' ')
             if Shape==4||Shape==5||Shape==13||Shape==14||Shape==15||Shape==18 % Only if shape uses Extra parameter.
                disp(['Shape factor = ' num2str(extra(1)) ])
             end
            disp(['Shape= ' ShapeString  '    % Fitting Error= ' num2str(MeanFitError(1)) '%    R2= ' num2str(MeanFitError(2)) ] )
            sizeFitResults=size(FitResults);
            if Shape==9||Shape==10||Shape==19 % Pulse, alpha, and Sigmoid only
                disp('         Peak#     Tau1         Height       Tau2          Area');
            else
                if sizeFitResults(2)==6 % For unconstrained variable shapes
                    disp('         Peak#      Position       Height       Width         Area       Shape');
                else
                    if sizeFitResults(2)==7
                        disp('         Peak#      Position       Height       Width         Area         a1       a2');
                    else
                        disp('         Peak#      Position       Height       Width         Area');
                    end
                end
            end
            disp(FitResults)
            if BaselineMode==3
                disp([ 'Baseline= ' num2str(PEAKHEIGHTS(1)) ]);
            end
            
        case 100
            % 'd' (Disc) saves model data to local hard disc
            savefile = 'SavedModel.mat';
            DataSegment=[xx' yy'];
%             sizePEAKHEIGHTS=size(PEAKHEIGHTS)
%             sizeAA=size(AA)
%            size([ones(600,1) AA'])
%            BaselineMode=BaselineMode
            if BaselineMode==3,AA=[ones(600,1) AA']';end
            ModelMatrix=PEAKHEIGHTS'.*AA';
            ModelX=xxx;
            save(savefile,'DataSegment','ModelMatrix','ModelX')
            disp('Model data saved to hard disc as SavedModel.mat')
            % To place model in the workspace
            % load SavedModel
            % To plot saved DataSegment:
            %  plot(DataSegment(:,1),DataSegment(:,2))
            % To plot SavedModel:
            %  plot(ModelX,ModelMatrix)
   
        case 61 % When '=' key is pressed
            if BIPOLAR==0;BIPOLAR=1;else BIPOLAR=0;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);   
            subplot(2,1,1); if BIPOLAR==0;ylabel('+ mode');else ylabel('+ - mode');end
        
        case 78 % When Shift-N key pressed, negates signal
            Y=-Y;
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);          
        
        case 116
            % When 't' key is pressed, steps through BaselineMode modes 1 to 4
            BaselineMode=BaselineMode+1;
            if BaselineMode==6,BaselineMode=0;end
            [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks);
        case 89
            
        case 107
            % When 'k' key is pressed, prints out table of keyboard commands
            disp('KEYBOARD CONTROLS (Version 12):')
            disp(' Pan signal left and right...Coarse: < and >')
            disp('                             Fine: left and right cursor arrow keys')
            disp('                             Nudge: [ ] ')
            disp(' Zoom in and out.............Coarse zoom: / and "  ')
            disp('                             Fine zoom: up and down cursor arrow keys')
            disp(' Resets pan and zoom.........ESC')
            disp(' Select entire signal........Crtl-A')
            disp(' Select # of peaks...........Number keys 1-9, or press 0 key to enter manually')
            disp(' Select peak shape from menu - (minus or hyphen), type number or [vector] and Enter')
            disp(' Common peak shapes by key...g Gaussian')
            disp('                             h equal-width Gaussians')
            disp('                             Shift-G  fixed-width Gaussians')
            disp('                             Shift-P fixed-position Gaussians')
            disp('                             Shift-H  bifurcated Gaussians (equal shape, a/z adjusts)')
            disp('                             e Exponential-broadened Gaussian (equal tau, a/z adjusts)')
            disp('                             Shift-R  ExpGaussian (var. tau)')
            disp('                             j exponential-broadened equal-width Gaussians  (equal tau)')
            disp('                                 (a,z keys adjust broadening)')
            disp('                             Shift-K  PearsonIV (variable asymmetry)')
            disp('                             l Lorentzian')
            disp('                             ; equal-width Lorentzians')
            disp('                             Shift-[ fixed-position Lorentzians')
            disp('                             Shift-B Breit-Wigner-Fano (a,z keys adjust Fano factor)')
            disp('                             Shift-E Exponential-broadened Lorentzians (equal tau)')
            disp('                             Shift-L Fixed-width Lorentzians')
            disp('                             o Lognormal distribution')
            disp('                             p Pearson (equal shape, a/z adjusts)')
            disp('                             u exponential pUlse  y=exp(-tau1.*x).*(1-exp(-tau2.*x))')
            disp('                             Shift-U Alpha function: y=(x-tau2)./tau1.*exp(1-(x-tau2)./tau1)')
            disp('                             s Up Sigmoid (logistic function): y=.5+.5*erf((x-tau1)/sqrt(2*tau2))')
            disp('                             Shift-D Down Sigmoid y=.5-.5*erf((x-tau1)/sqrt(2*tau2))')
            disp('                             ~ Gauss/Lorentz blend  (equal shape, a/z adjusts)')
            disp('                             Shift-V Voigt profile (equal tau, a/z adjusts)')
            disp('                             Shift-T  Triangular')
            disp(' Fit.........................f Performs one fit of the specified model')
            disp(' Select BaselineMode mode........t  selects none, linear, quadratic, or flat baseline mode')
            disp(' Monopolar/bipolar mode......= +  Flips between + peaks only and +/- peak mode')
            disp(' Toggle log y mode OFF/ON....m  Plot linear or log Y axis on lower graph')
            disp(' 2-point Baseline............b, then click left and right baseline')
            disp(' Set manual baseline.........Backspace, then click baseline at multiple points')
            disp(' Restore original baseline...\  to cancel previous background subtraction')
            disp(' Click start positions.......c, click on peak position for each peak')
            disp(' Type in start vector........C (Shift-C) Type or Paste start vector [p1 w1 p2 w2 ...]')
            disp(' Enter value of ''extra''....Shift-x, type value or [vector], press Enter.')
            disp(' Adjust ''extra'' up/down....a,z: 5% change; upper case A,Z: 0.5% change.')
            disp(' Print parameters & results..q')
            disp(' Print fit results only......r')
            disp(' Compute bootstrap stats.....v  Estimates standard deViations of parameters.')
            disp(' Test effect of Noise........n  Test effect of Noise by fitting subset of points')
            disp(' Plot signal in figure 2.....y')
            disp(' save model to Disk..........d  Save model to disk as SavedModel.mat.')
            disp(' Refine fit..................x  Takes best of 10 trial fits (change in line 177)')
            disp(' Print peakfit function......w  Print equivalent peakfit function with all input arguments')
            disp(' Save Figure as png file.....Shift-S  Saves as Figure1.png, Figure2.png, etc.')
            disp(' Display current settings....Shift-? displays table of current values')
            disp(' Fit polynomial to segment...Shift-o  Asks for polynomial order')
            disp(' Enter minimun width.........Shift-W')
            disp(' Enter saturation maximum....Shift-M')
            disp(' Switch to iPeak.............Shift-Ctrl-P  transfer current signal to iPeak.m')
            disp(' Switch to iSignal...........Shift-Ctrl-S  transfer current signal to iSignal.m')
        case 120 % When 'x' key is pressed, calls peakfit to take best of 'NumTrials' trial fits
            subplot(2,1,2);title('Working....');drawnow
            NumTrials=10;
            center=(max(xx)+min(xx))/2;
            window=max(xx)-min(xx);
%            disp(['Calculating best of ' num2str(NumTrials) ' trial fits....' ])
             if Shape==16||Shape==17 % Fixed-position shapes
                    fixedparameters=FIXEDPARAMETERS;
                else
                     fixedparameters=FIXEDPARAMETERS;
             end 
            FirstGuess=[];
            sizeFitResults=size(FitResults); % <<<<<< testing
            for peaknumber=1:NumPeaks
                FirstGuess=[FirstGuess FitResults(peaknumber,2) FitResults(peaknumber,4)];
            end
            tic
            % FirstGuess=FirstGuess          
            [FitResults,MeanFitError]=peakfit([X',Y'],center,window,NumPeaks,shapesvector,extra,NumTrials,FirstGuess,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
            et=toc;
%             disp(['     Elapsed time = '  num2str(et) ' sec.   Percent Fitting Error ' num2str(MeanFitError)])
%             if Shape==9||Shape==10||Shape==19, % Pulse, alpha and Sigmoid only
%                 disp('         Peak#     Tau1         Height       Tau2          Area');
%             else
%                 if Shape==0, % For future use
%                     disp('         Peak#      Position       Height      Area');
%                 else
%                     disp('         Peak#   Position       Height       Width         Area');
%                 end
%             end
%             disp(FitResults)
%             figure(1)
            start=FirstGuess;
        case 119
            % When 'W' is pressed, prints out peakfit functions with arguments in command window
            center=(max(xx)+min(xx))/2;
            window=max(xx)-min(xx);
            FirstGuess=[];
            if size(FitResults)==[0,0]
                disp('Perform at least one fit before using this command')
            else
                for peaknumber=1:NumPeaks
                    FirstGuess=[FirstGuess FitResults(peaknumber,2) FitResults(peaknumber,4)];
                end
                disp(' ')
                disp('Copy and Paste these functions, replacing "datamatrix" with your data variable:')
                disp(['ipf(datamatrix,' num2str(center) ',' num2str(window) ')']);
                disp(['[FitResults,FitError]=peakfit(datamatrix,' num2str(center) ',' num2str(window) ',' num2str(NumPeaks) ',' num2str(Shape) ',' num2str(extra) ',' num2str(NumTrials) ', [' num2str(FirstGuess) '], ' num2str(BaselineMode) ', [' num2str(FIXEDPARAMETERS) '], 1 ,' num2str(BIPOLAR) ',' num2str(MINWIDTH) ',' num2str(DELTA) ',' num2str(CLIPHEIGHT) ')' ] );
            end
            
         case 113
            % When 'q' key is pressed, prints out fitting parameters
            ShapeString=SelectShapeString(Shape);
            disp('------------------------------------------------------------------')
            if Shape==22
                AllShapes=[];
                for NumShape=1:length(shapesvector)
                    AllShapes=[AllShapes  SelectShapeString(shapesvector(NumShape)) ', ' ];
                end
                disp( ['Peak shapes = ' AllShapes] )
                disp(['Extra vector = ' num2str(extra)])
            else
                disp(['Peak Shape= ' ShapeString])
            end
            switch Shape
                case 4
                    disp(['Shape Constant = ' num2str(extra)])
                case {5,8,18}
                    disp(['tau = ' num2str(extra)])
                case 13
                    disp(['Percent Gaussian = ' num2str(extra)])
                case 14
                    disp(['Asymmetry = ' num2str(extra)])
                case 15
                    disp(['Fano factor = ' num2str(extra)])
                case 20
                    disp(['Alpha = ' num2str(extra)])
            end
            if BIPOLAR
                disp('Bipolar mode')
            else
                disp('Positive peaks only')
            end
            if logplot
                 disp('Log mode')
            else
                 disp('Linear mode')
            end
            switch BaselineMode
                case 0
                    disp('No baseline correction')
                case 1
                    disp('Tilted baseline correction')
                case 2
                    disp('Quadratic baseline correction')
                case 3
                    disp('Flat baseline mode')
                case 4
                    disp('Linear mode(y) subtraction')
                case 5
                    disp('Flat mode(y) subtraction')
            end
            disp(['Number of Peaks= ' num2str(NumPeaks)])
            
            if Shape==11||Shape==12, disp(['Fixed Peak Width= ' num2str(FIXEDPARAMETERS)]), end
            disp(['Fitted x range = ' num2str(min(xx)) ' - ' num2str(max(xx)) ' (dx=' num2str(max(xx)-min(xx)) ')  (Center=' num2str((max(xx)+min(xx))/2) ')  ' ])
            apnt=1;
            for pnt=1:length(xx)
                if yy(pnt)<CLIPHEIGHT
                    axx(apnt)=xx(pnt);
                    ayy(apnt)=yy(pnt);
                    apnt=apnt+1;
                end
            end
            xx=axx;yy=ayy;
            disp([num2str(length(xx)) ' data points fit' ])
            disp(['Saturation height = ' num2str(CLIPHEIGHT) ])
            disp(['Minimum Width= ' num2str(MINWIDTH) ])
            disp(['% Fitting Error= ' num2str(MeanFitError(1)) '%    R2= ' num2str(MeanFitError(2)) ] )
            sizeFitResults=size(FitResults);
             if Shape==9||Shape==10||Shape==19 % Pulse, alpha, and Sigmoid only
                disp('         Peak#     Tau1         Height       Tau2          Area');
            else
                if sizeFitResults(2)==6 % For unconstrained variable shapes
                    disp('         Peak#      Position       Height       Width         Area       Shape');
                else
                    if sizeFitResults(2)==7
                        disp('         Peak#      Position       Height       Width         Area         tau1       tau2');
                    else
                        disp('         Peak#      Position       Height       Width         Area');
                    end
                end
            end
            disp(FitResults)
            errmat = zeros(height(FitResults),2);
            errmat(1,:) = [MeanFitError(2),MeanFitError(1)];
            writematrix([FitResults,errmat],'testresults.csv')
            if BaselineMode==3
                disp([ 'Baseline= ' num2str(PEAKHEIGHTS(1)) ]);
            end
            
        case 121    % When 'Y' key is pressed (Added on version 5)
            figure(2) % Plot the entire signal cleanly in Figure window 2
            plot(X,Y)
            axis([X(1) X(length(X)) min(residual) max(Y)]);
            hold on
            for m=1:NumPeaks
                % Add the individual component peaks in green lines
                if BaselineMode==3
                    plot(xxx,PEAKHEIGHTS(m+1)*AA(m,:),'g')
                else
                    plot(xxx,PEAKHEIGHTS(m)*AA(m,:),'g')
                end
            end
            % Show residual in red
            plot(xx,residual,'r')
            hold off
            title('Blue=Original Data; Green=Computed Fit; Red=Residual (Fit-Data)')
            % figure(1)
            
        case 118 % 'v' key computes bootstrap statistics (Added in version 8)
            subplot(2,1,2);title('Working....');drawnow
            NumTrialsBoot=input('Number of fit trials per bootstrap sample (0 to cancel): ');
            if isempty(NumTrialsBoot),NumTrialsBoot=1;end
            % EstTime=2.4+NumTrialsBoot.*(length(xx)./1436).*NumPeaks;
            % EstTime=round((0.71581.*NumTrialsBoot).*(0.00069642.*length(xx)).*(5.4659.*NumPeaks)+2.5);
            % lengthxx=length(xx)
            % disp(['Estimated time: ',num2str(EstTime) ' seconds']);
            if NumTrialsBoot
                disp('Computing bootstrap sampling statistics....May take several minutes.')
                tic;
                sizeFitResults=size(FitResults);
                if sizeFitResults(2)==6
                    BootstrapResultsMatrix=zeros(6,100,NumPeaks);
                else
                    BootstrapResultsMatrix=zeros(5,100,NumPeaks);
                end
                BootstrapErrorMatrix=zeros(2,100,NumPeaks);
                center=(max(xx)+min(xx))/2;
                window=max(xx)-min(xx);
                clear bx by
                cutoff=0.5;
                for trial=1:100
                    n=1;
                    bx=X';
                    by=Y';
                    while n<length(X)-1
                        if rand>cutoff
                            bx(n)=X(n+1);
                            by(n)=Y(n+1);
                        end
                        n=n+1;
                    end
                    [FitResults,BootFitError]=peakfit([bx,by],center,window,NumPeaks,Shape,extra,NumTrialsBoot,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
                    for peak=1:NumPeaks
                        BootstrapResultsMatrix(:,trial,peak)=FitResults(peak,:);
                        BootstrapErrorMatrix(:,trial,peak)=BootFitError;
                    end
                end
                for peak=1:NumPeaks
                    disp(' ')
                    if Shape==9||Shape==10||Shape==19 % Pulse, alpha and Sigmoid only
                        disp(['Peak #' num2str(peak) '    Tau1         Height       Tau2          Area']);
                    else
                        disp(['Peak #' num2str(peak) ])
                    end % if Shape==9||Shape==10....
                    BootstrapMean=mean(real(BootstrapResultsMatrix(:,:,peak)'));
                    BootstrapSTD=std(BootstrapResultsMatrix(:,:,peak)');
                    BootstrapIQR=iqr(BootstrapResultsMatrix(:,:,peak)');
                    PercentRSD=100.*BootstrapSTD./BootstrapMean;
                    PercentIQR=100.*BootstrapIQR./BootstrapMean;
                    if sizeFitResults(2)==6 % For unconstrained variable shapes
                        property(1)={'Position'}; property(2)={'Height'}; property(3)={'width'}; property(4)={'Area'};property(5)={'ShapeFactor'};
                        disp(table(property',BootstrapMean(2:sizeFitResults(2))',BootstrapSTD(2:sizeFitResults(2))',BootstrapIQR(2:sizeFitResults(2))',PercentRSD(2:sizeFitResults(2))',PercentIQR(2:sizeFitResults(2))','VariableNames',{'Parameter' 'Mean ' 'STD'  'STDIQR'  'PercentRSD'  'PercentRSDIQR'}))
                    else
                        property(1)={'Position'}; property(2)={'Height'}; property(3)={'width'}; property(4)={'Area'};
                        disp(table(property',BootstrapMean(2:sizeFitResults(2))',BootstrapSTD(2:sizeFitResults(2))',BootstrapIQR(2:sizeFitResults(2))',PercentRSD(2:sizeFitResults(2))',PercentIQR(2:sizeFitResults(2))','VariableNames',{'Parameter' 'Mean ' 'STD'  'STDIQR'  'PercentRSD'  'PercentRSDIQR'}))
                    end
                    % %  MaxError=max(real(BootstrapErrorMatrix(:,:,peak)'));
                    % %  MinError=min(real(BootstrapErrorMatrix(:,:,peak)'));
                    %    disp(['Mean:        ', num2str(BootstrapMean(2:sizeFitResults(2)))])
                    %    disp(['STD:         ', num2str(BootstrapSTD(2:sizeFitResults(2)))])
                    %    disp(['STD (IQR):   ', num2str(BootstrapIQR(2:sizeFitResults(2)))])
                    %    disp(['% RSD:       ', num2str(PercentRSD(2:sizeFitResults(2)))])
                    %    disp(['% RSD (IQR): ', num2str(PercentIQR(2:sizeFitResults(2))) '% ' ])
                    %  % mean(PercentIQR(2:5)./PercentRSD(2:5))
                    % Using the table function for better alignmednt
                    % disp(table(BootstrapMean(2:sizeFitResults(2))',BootstrapSTD(2:sizeFitResults(2))',BootstrapIQR(2:sizeFitResults(2))',PercentRSD(2:sizeFitResults(2))',PercentIQR(2:sizeFitResults(2))','VariableNames',{'Mean ' 'STD'  'STDIQR'  'PercentRSD'  'PercentRSDIQR'}))
                end % for peaks=1:NumPeaks,
                toc;
                disp('-------------------------------------------------------------------')
            end % if NumTrialsBoot,
            figure(1)
            title('ipf 13  Typical Bootstrap sample fit')
            
        case 110 % When 'n' key is pressed (Added on version 8)
%            disp('Fit to single bootstrap sample')
            tic;
            center=(max(xx)+min(xx))/2;
            window=max(xx)-min(xx);
            clear bx by
            cutoff=0.5;
            n=1;
            bx=X';
            by=Y';
            while n<length(X)-1
                if rand>cutoff
                    bx(n)=X(n+1);
                    by(n)=Y(n+1);
                end
                n=n+1;
            end
            StartVector=start;
            startnow=start;
            DELTA=(max(xx)-min(xx))/100;
            for k=1:2*NumPeaks
                startnow(k)=start(k)+(rand-.5)*DELTA;
            end
            start=startnow; 
            [FitResults,MeanFitError]=peakfit([bx,by],center,window,NumPeaks,shapesvector,extra,NumTrialsBoot,start,BaselineMode,FIXEDPARAMETERS,1,BIPOLAR,MINWIDTH,DELTA,CLIPHEIGHT);
%             disp(['Fitting Error= ' num2str(MeanFitError) '%'])
%             if Shape==9||Shape==10||Shape==19,
%                 disp('         Peak#     Tau1         Height       Tau2          Area');
%             else
%                 disp('         Peak#   Position       Height       Width         Area');
%             end
%             disp(FitResults)
            figure(1)
            title('ipf 13.3 Single Bootstrap sample fit')
            
        case 83
            saveas(gcf,['Figure' num2str(FigNum) '.png'])
            FigNum=FigNum+1;
            
        case 63 % Shift-? Displays current settings
            disp(' ')
            disp( 'Current Settings:')
            disp([ 'Fitted x range = ' num2str(min(xx)) ' - ' num2str(max(xx)) ' (dx=' num2str(max(xx)-min(xx)) ')  (Center=' num2str((max(xx)+min(xx))/2) ')  ' ])
            
            disp([ 'NumPeaks= ' num2str(NumPeaks) ])
            disp([ 'Shape= ' num2str(Shape) ': ' ShapeString  ])
            disp([ 'shapesvector = ' num2str(shapesvector) ])
            disp([ 'extra = ' num2str(extra) ])
            disp([ 'NumTrials = ' num2str(NumTrials) ])           
            disp([ 'start vector = [' num2str(start) ']' ])
            % disp([ 'newstart vector = [' num2str(newstart) ']' ])
            disp([ 'Baseline mode = ' num2str(BaselineMode) ])
            disp([ 'Fixed parameters = ' num2str(FIXEDPARAMETERS) ])  
            disp([ 'BIPOLAR = ' num2str(BIPOLAR) ])
            disp([ 'Minimum peak Width= ' num2str(MINWIDTH) ])
            disp([ 'DELTA = ' num2str(DELTA) ])            
            disp([ 'Saturation height = ' num2str(CLIPHEIGHT) ])

        case 19 % Shift-Ctrl-F transfers current signal to iSignal
            isignal(X,Y);
            
        case 16 % Shift-Ctrl-P transfers current signal to Interactive Peak Detector
            ipeak(X,Y);
            
        case 79 % Shift-o
            polyorder=input('Polynomial order (1=linear, 2=quadratic, etc): ');
            if isempty(polyorder),polyorder=0;end
            if polyorder>0
                figure(1);subplot(2,1,1); % Select upper window
                [coef, RSquared]=plotit(xx,yy,polyorder);
                residual=yy-polyval(coef,xx);
                subplot(2,1,2);plot(xx,residual,'r.')
                xlabel('Residuals')
                disp(' ')
                disp([ 'Selected x range: ' num2str(length(xx)) ' points from x = ' num2str(min(xx)) ' to ' num2str(max(xx)) ])
                disp([ 'Polynomial order: ' num2str(polyorder)])
                disp([ 'Polynomial coefficients (slope, intercept): ' num2str(coef)])
                disp([ 'Coefficient of determination (R2): ' num2str(RSquared)])
            end
            
        case 87 % Shift-W sets minimum peak width
            disp(['Current value of minimun width: ' num2str(MINWIDTH) ] )
            MinWidthInput=input('Type value or press Enter to keep unchanged: ');
            if isempty(MinWidthInput)
            else
                MINWIDTH=MinWidthInput;
            end   
            figure(1)
            
        case 77 % Shift-M sets Saturation height, ignores y values above this value
            disp(['Current value Saturation height: ' num2str(CLIPHEIGHT) ] )
            ClipInput=input('Type value or press Enter to keep unchanged: ');
            if isempty(ClipInput)
            else
                CLIPHEIGHT=ClipInput;
            end 
            figure(1)
        otherwise
            UnassignedKey=double(key)
            disp('Press k to print out list of keyboard commands')
            disp('Make sure the CAPS LOCK mode is not engaged.')
    end % switch
end % if
% -------------------------------- subfunctions -------------------------
function [xx,yy,start]=RedrawSignal(X,Y,xo,dx,NumPeaks)
% Plots the entire signal (X,Y) in the lower half of the plot window and an
% isolated segment (xx,yy) in the upper half, controlled by Pan and Zoom
% keys. Top half of the figure shows original signal
global BaselineMode AA xxx PEAKHEIGHTS logplot BIPOLAR MINWIDTH
minX=min(X);maxX=max(X);minY=min(Y);maxY=max(Y);
Startx=round(xo-(dx/2));
Endx=abs(round(xo+(dx/2)-1));
if Endx>length(Y),Endx=length(Y);end
if Startx<1,Startx=1;end
PlotRange=Startx:Endx;
if (Endx-Startx)<2, PlotRange=xo:xo+2;end
xx=X(PlotRange);
yy=Y(PlotRange);
X1=min(xx);
X2=max(xx);
Y1=min(Y);
Y2=max(Y);
% Remove baseline from data segment
bkgsize=round(length(xx)/10);
if bkgsize<2,bkgsize=2;end
lxx=length(xx);
if BaselineMode==1 % linear BaselineMode operation  
    XX1=xx(1:round(lxx/bkgsize));
    XX2=xx((lxx-round(lxx/bkgsize)):lxx);
    Y1=yy(1:(round(length(xx)/bkgsize)));
    Y2=yy((lxx-round(lxx/bkgsize)):lxx);
    bkgcoef=polyfit([XX1,XX2],[Y1,Y2],1);  % Fit straight line to sub-group of points
    bkg=polyval(bkgcoef,xx);
    yy=yy-bkg;
end % if
if BaselineMode==2 % Quadratic BaselineMode operation  
    XX1=xx(1:round(lxx/bkgsize));
    XX2=xx((lxx-round(lxx./bkgsize)):lxx);
    Y1=yy(1:round(length(xx)./bkgsize));
    Y2=yy((lxx-round(lxx/bkgsize)):lxx);
    bkgcoef=polyfit([XX1,XX2],[Y1,Y2],2);  % Fit parabola to sub-group of points
    bkg=polyval(bkgcoef,xx);
    yy=yy-bkg;
end % if BaselineMode
if BaselineMode==4 % linear y mode subtraction 
    XX1=xx(1);
    XX2=xx(1)+xx(lxx)/2;
    roundn=50.*max(yy);
    ryy = round(roundn.*yy)./roundn; 
    Y1=mode(ryy(round(1:lxx/2)));
    Y2=mode(ryy(round(lxx/2):lxx));
    bkgcoef=polyfit([XX1,XX2],[Y1,Y2],1);  % Fit straight line to sub-group of points
%     XX1=XX1
%     XX2=XX2
%     Y1=Y1
%     Y2=Y2
    bkg=polyval(bkgcoef,xx);
    yy=yy-bkg;
end % if
if BaselineMode==5 % flat y mode subtraction 
    roundn=50.*max(yy);
    ryy = round(roundn.*yy)./roundn; 
    yy=yy-mode(ryy);
end % if

hold off

subplot(2,1,1); % Select upper window
% semilogy(xx,yy,'b.');
if logplot
    semilogy(xx,yy,'b.');
else
    plot(xx,yy,'b.'); % Plot the original signal in blue in upper window
end
xlabel('Line up the estimated peak positions roughly with the vertical lines')
lyy=min(yy);
% lyy=min(yy);
uyy=max(yy)+(max(yy)-min(yy))/10;
switch BaselineMode
    case 0
        title('ipf 13.3  No baseline correction. Pan and Zoom to isolate peaks to be fit in upper window.')
        if lyy<uyy;axis([X(Startx) X(Endx) lyy uyy ]);end
    case 1
        title('ipf 13.3  Tilted baseline mode. Pan and Zoom to isolate peaks to be fit in upper window.')
        if lyy<uyy;axis([X(Startx) X(Endx) lyy uyy ]);end
    case 2
        title('ipf 13.3  Quadratic baseline mode. Pan and Zoom to isolate peaks to be fit in upper window.')
        if lyy<uyy;axis([X(Startx) X(Endx) lyy uyy ]);end
    case 3
        title('ipf 13.3  Flat baseline mode. Pan and Zoom to isolate peaks to be fit in upper window.')
        if lyy<uyy;axis([X(Startx) X(Endx) lyy uyy ]);end
    case 4
        title('ipf 13.3  Linear mode(y) subtraction. Pan and Zoom to isolate peaks to be fit in upper window.')
        if lyy<uyy;axis([X(Startx) X(Endx) lyy uyy ]);end
    case 5
        title('ipf 13.3  Flat mode(y) subtraction. Pan and Zoom to isolate peaks to be fit in upper window.')
        if lyy<uyy;axis([X(Startx) X(Endx) lyy uyy ]);end
end
hold on
% Mark starting peak positions with vertical dashed lines in upper window
% Determine locations for peak (vertical line) markers
n=X2-X1;
width=n/(5*NumPeaks);
start=[];
startpos=[n/(NumPeaks+1):n/(NumPeaks+1):n-(n/(NumPeaks+1))]+X1;
for marker=1:NumPeaks
    markx=startpos(marker);
    start=[start markx width];
    semilogy([markx markx],[lyy uyy],'m--')
end % for marker
hold off
%
% Bottom half of the figure shows full signal in either linear or log mode
% as set by the M key.
subplot(2,1,2);cla
if logplot
    semilogy(X,abs(Y))  % Graph the signal with linear Y axis
    ylabel('Log y mode')
    axis([X(1) X(length(X)) min(abs(Y)) max(Y)]); % Update plot
else
    plot(X,Y)  % Graph the signal with linear Y axis
    ylabel('Linear y mode')
    axis([X(1) X(length(X)) min(Y) max(Y)]); % Update plot
end
title('# peaks: 1-9   Shapes: use keys or press "-" for full menu.    f=Fit   t=BaselineMode   c=click start positions.')
hold on
for marker=1:NumPeaks
    markx=startpos(marker);
    plot([markx markx],[minY maxY],'m--')
end % for marker

% Mark the limits of the upper windows on the lower whole-signal plot
plot([X1 X1],[minY maxY],'g--')
plot([X2 X2],[minY maxY],'g--')
hold off
xlabel(['Press K to print out all keyboard commands'])
% start=start <<<<<
% ----------------------------------------------------------------------
function ShapeString=SelectShapeString(Shape)
global shapesvector
switch Shape
  case 1
        ShapeString='Gaussian';
    case 2
        ShapeString='Lorentzian';
    case 3
        ShapeString='Lognormal';
    case 4
        ShapeString='Pearson';
    case 5
        ShapeString='ExpGaussian';
    case 6
        ShapeString='Equal width Gauss.';
    case 7
        ShapeString='Equal width Lorentz.';
    case 8
        ShapeString='Exp. equal width Gauss.';
    case 9
        ShapeString='Exponential Pulse';
    case 10
        ShapeString='Up Sigmoid (logistic function)';
    case 23
        ShapeString='Down Sigmoid (logistic function)';  
    case 11
        ShapeString='Fixed-width Gaussian';
    case 12
        ShapeString='Fixed-width Lorentz.';
    case 13
        ShapeString='Gauss./Lorentz. blend';
    case 14
        ShapeString='BiGaussian';    
    case 15
        ShapeString='Breit-Wigner-Fano';   
    case 16
        ShapeString='Fixed-position Gauss.';
    case 17
        ShapeString='Fixed-position Lorentz.';
    case 18
        ShapeString='Exp. Lorentzian';
    case 19
        ShapeString='Alpha function';
    case 20
        ShapeString='Voigt (equal alphas)';
    case 21
        ShapeString='triangular';
    case 22
        ShapeString=num2str(shapesvector);
    case 24
        ShapeString='Negative Binomial Dist.';
    case 25
        ShapeString='Lognormal Dist.';
    case 26
        ShapeString='slope';
    case 27
        ShapeString='First derivative';
    case 28
        ShapeString='Polynomial';
    case 29
        ShapeString='Segmented linear';
    case 30
        ShapeString='Voigt (variable alphas)';
    case 31
        ShapeString='ExpGaussian (var. tau)';
    case 32
        ShapeString='Pearson (var. shape.)';
    case 33
        ShapeString='Variable Gauss./Lorentz.';
    case 34
        ShapeString='Fixed-width Voigt';
    case 35
        ShapeString='Fixed-width G/L blend';
    case 36
        ShapeString='Fixed-width ExpGauss.';
    case 37
        ShapeString='Fixed-width Pearson';
    case 38
        ShapeString='ExpLorentzian (var. tau)'; 
    case 39
        ShapeString='ExpGaussian2 (var. tau)';
    case 40
        ShapeString='Sine wave';
    case 41
        ShapeString='Rectangular pulse';
    case 42
        ShapeString='Flattened Gaussian';  
    case 43
        ShapeString='3-parameter Gompertz.';  
    case 44
        ShapeString='1-exp(-k*t)';  
    case 45
        ShapeString='4-parameter logistic'; 
    case 46
        ShapeString='Quadratic Baseline'; 
    case 47
        ShapeString='Blackbody'; 
    case 48
        ShapeString='Equal-width exp. pulse'; 
    case 49
        ShapeString='PearsonIV'; 
    otherwise
        ShapeString='';
end % switch Shape
% Latest peakfit version 9.62 ------------------------------------------------
function [FitResults,GOF,baseline,coeff,residual,xi,yi,BootResults]=peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,fixedparameters,plots,bipolar,minwidth,DELTA,clipheight)
% A command-line peak fitting program for time-series signals, written as a
% self-contained Matlab function in a single m-file. Uses a non-linear
% optimization algorithm to decompose a complex, overlapping-peak signal
% into its component parts. The objective is to determine whether your
% signal can be represented as the sum of fundamental underlying peaks
% shapes. Accepts signals of any length, including those with non-integer
% and non-uniform x-values. Fits any number of peaks of any of 45 curve
% shapes. This is a command line version, usable from a remote terminal. It
% is capable of making multiple trial fits with sightly different starting
% values and taking the one with the lowest mean fit error (example 6). It
% can estimate the standard deviation of peak parameters from a single
% signal using the bootstrap method (example 10).
%
% If you are unsure what input arguments to use (number of peaks, shape,
% etc.), try fitting your signal using the interactive peak fitter ipf.m
% (Matlab only), which is basically peakfit.m with an outer wrapper of user
% interface. It uses single keystrokes to pan and zoom, select number of
% peaks, peak shapes, baseline mode, number of trials, starting positions,
% bootstrap error estimates, etc. Then press W to print out the peakfit
% command line for that fit.
%
% Important: the data matrix "signal" must be a 2xn or nx2 matrix; the x
% and y vectors must be separate rows or columns and not concatenated into
% one long vector.
%
% Version 9.62: May 28, 2021, Added Pearson IV peak, shape #49, an asymmetric
% peak shape equivalent to an exponentially skewed Gaussian.
%
% For more details, see
% https://terpconnect.umd.edu/~toh/spectrum/CurveFittingC.html and
% https://terpconnect.umd.edu/~toh/spectrum/InteractivePeakFitter.htm
%
% Explanation of input parameters:
%
% peakfit(signal);       
% Performs an iterative least-squares fit of a single Gaussian peak to the
% data matrix "signal", which has x values in column 1 and Y values in
% column 2 (e.g. [x y]). 
%
% peakfit(signal,center,window);
% Fits a single Gaussian peak to a portion of the matrix "signal". The
% portion is centered on the x-value "center" and has width "window" (in x
% units).
% 
% peakfit(signal,center,window,NumPeaks..);
% "NumPeaks" = number of peaks in the model (default is 1 if not
% specified). No limit to maximum number of peaks in version 3.1
% 
% peakfit(signal,center,window,NumPeaks,peakshape); "peakshape" specifies
% the peak shape of the model: (1=Gaussian (default), 2=Lorentzian,
% 3=logistic distribution, 4=Pearson, 5=exponentionally broadened Gaussian;
% 6=equal-width Gaussians; 7=Equal-width Lorentzians; 8=exponentionally
% broadened equal-width Gaussian, 9=exponential pulse, 10=up-sigmoid
% (logistic function), 11=Fixed-width Gaussian, 12=Fixed- width Lorentzian;
% 13=Gaussian/Lorentzian blend; 14=Bifurcated Gaussian,
% 15=Breit-Wigner-Fano, 16=Fixed-position Gaussians; 17=Fixed-position 
% Lorentzians; 18=exponentionally broadened Lorentzian; 19=alpha function; 
% 20=Voigt profile; 21=triangular; 23=down-sigmoid; 25=lognormal; 26=slope;
% 27=Gaussian first derivative; 28=polynomial; 29=piecewise linear;
% 30=variable-alpha Voigt; 31=variable time constant ExpGaussian;
% 32=variable shape Pearson; 33=variable Gaussian/Lorentzian blend,
% 34=fixed-width Voigt; 35=fixed-width Gaussian/Lorentzian blend; 
% 36=fixed-width exponentionally-broadened Gaussian; 37=fixed-width 
% Pearson; 38=variable time constant ExpLorentzian; 39=variable time
% constant ExpGaussian2; 40=sine wave; 41=rectangle; 42=flattened Gaussian;
% 43:PearsonIV function (3 variables); 44=1-exp(-k*x); 45: Four-parameter
% logistic; 46=quadratic/parabola; 47=blackbody emission; 48=equal-width
% exponential pulses; 39: Pearson IV (variable asymmetrical peak).
%
% peakfit(signal,center,window,NumPeaks,peakshape,extra) 
% 'extra' specifies the value of 'extra', used only in the Voigt, Pearson,
% exponentionally broadened Gaussian, Gaussian/Lorentzian blend, and
% bifurcated Gaussian and Lorentzian shapes to fine-tune the peak shape.
% 
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials);
% Performs "NumTrials" trial fits and selects the best one (with lowest
% fitting error). NumTrials can be any positive integer (default is 1).
%
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start)
% Specifies the first guesses vector "firstguess" for the peak positions
% and widths. Must be expressed as a vector , in square brackets, e.g.
% start=[position1 width1 position2 width2 ...]
% 
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode) 
% 'BaselineMode' sets the baseline correction mode:
% BaselineMode=0 (default) does not subtract baseline from data segment; 
% BaselineMode=1 interpolates a linear baseline from the edges of the data 
%            segment and subtracts it from the signal (assumes that the 
%            peak returns to the baseline at the edges of the signal); 
% BaselineMode=2 is like mode 1 except that it computes a quadratic curved baseline; 
% BaselineMode=3 compensates for a flat baseline without reference to the 
%            signal itself (best if the peak does not return to the
%            baseline at the edges of the signal).
%
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,...
% BaselineMode,fixedparameters)
% 'fixedparameters' specifies fixed values for widths (shapes 10, 11) or
% positions (shapes 16, 17)
% 
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,...
% BaselineMode,fixedparameters,plots)
% 'plots' controls graphic plotting: 0=no plot; 1=plots draw as usual (default)
% 
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,...
% BaselineMode,fixedparameters,plots,bipolar)
% 'bipolar' = 0 constrain peaks heights to be positions; 'bipolar' = 1
% allows positive ands negative peak heights.
%
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,...
% BaselineMode,fixedparameters,plots,bipolar,minwidth)
% 'minwidth' sets the minmimum allowed peak width. The default if not
% specified is equal to the x-axis interval. Must be a vector of minimum
% widths, one value for each peak, if the multiple peak shape is chosen, 
% as in example 17 and 18.
%
% peakfit(signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,...
% BaselineMode,fixedparameters,plots,bipolar,minwidth)
%  'DELTA' (14th input argument) controls the restart variance when
%  NumTrials>1. Default value is 1.0. Larger values give more variance.
%  Version 5.8 and later only. 
% [FitResults,FitError]=peakfit(signal,center,window...) Returns the
% FitResults vector in the order peak number, peak position, peak height,
% peak width, and peak area), and the FitError (the percent RMS
% difference between the data and the model in the selected segment of that
% data) of the best fit.
%
% [FitResults,LowestError,BestStart,xi,yi,BootResults]=peakfit(signal,...)
% Prints out parameter error estimates for each peak (bootstrap method).
%
% Optional output parameters 
% 1. FitResults: a table of model peak parameters, one row for each peak,
%    listing Peak number, Peak position, Height, Width, and Peak area.
% 2. GOF: Goodness of Fit, a vector containing the rms fitting error of the
%    best trial fit and the R-squared (coefficient of determination).
% 3. Baseline, the polynomial coefficients of  the baseline in linear
%    and quadratic baseline modes (1 and 2) or the value of the constant
%    baseline in flat baseline mode.
% 3. coeff: Coefficients for the polynomial fit (shape 28 only; for other 
%    shapes, coeff=0)
% 5. residual: the difference between the data and the best fit.
% 6. xi: vector containing 600 interploated x-values for the model peaks. 
% 7. yi: matrix containing the y values of each model peak at each xi. 
%    Type plot(xi,yi(1,:)) to plot peak 1 or plot(xi,yi) to plot all peaks
% 8. BootResults: a table of bootstrap precision results for a each peak
%    and peak parameter.
%  
% Example 1a: Fits exp(-x)^2 with a single Gaussian peak model.
% >> x=[0:.1:10]';y=exp(-(x-5).^2);peakfit([x y])
%    Peak number  Peak position   Height     Width      Peak area
%         1            5            1        1.665       1.7725
%
% Example 1b: Fits histogram of 10000 random numbers with a single Gaussian
% >> [N,X]=hist(randn(size(1:10000)));peakfit([X;N])
%   Peak   position        Height       Width         Area
%     1    0.0043728       2899.8       2.3653       7293.2
%
% Example 1c: Fits small set of manually entered y data to a single Gaussian peak model.
% >> y=[0 1 2 4 6 7 6 4 2 1 0 ];x=1:length(y);
% >> peakfit([x;y],length(y)/2,length(y),0,0,0,0,0,0)
%
% Example 2:
% x=[0:.01:10];y=exp(-(x-5).^2)+randn(size(x));peakfit([x;y])
% Measurement of very noisy peak with signal-to-noise ratio = 1.
% ans =
%         1         5.0279       0.9272      1.7948      1.7716
%
% Example 3:
% >> x=[0:.1:10];y=exp(-(x-5).^2)+.5*exp(-(x-3).^2)+.1*randn(size(x));
% >> peakfit([x' y'],0,0,2)
% Fits a noisy two-peak signal with a double Gaussian model (NumPeaks=2).
% ans =
%         1       3.0001      0.49489        1.642      0.86504
%         2       4.9927       1.0016       1.6597       1.7696
%
% Example 4:
% >> x=1:10;y=ones(size(x))./(1+(x-5).^2);peakfit(y,0,0,1,2)
% Fit Lorentzian (peakshape=2) located at x=50, height=1, width=2.
% ans =
%        1           50      0.99974       1.9971       3.1079
%
% Example 5: 
% >> x=[0:.005:1];y=humps(x);peakfit([x' y'],.3,.7,1,4,3);
% Fits a portion of the humps function, 0.7 units wide and centered on 
% x=0.3, with a single (NumPeaks=1) Pearson function (peakshape=4) with
% extra=3 (controls shape of Pearson function).
%
% Example 6: 
% >> x=[0:.005:1];y=(humps(x)+humps(x-.13)).^3;smatrix=[x' y'];
% >> [FitResults,FitError]=peakfit(smatrix,.4,.7,2,1,0,10)
% Creates a data matrix 'smatrix', fits a portion to a two-peak Gaussian
% model, takes the best of 10 trials.  Returns FitResults and FitError.
% FitResults =
%          1      0.31056  2.0125e+006      0.11057  2.3689e+005
%          2      0.41529  2.2403e+006      0.12033  2.8696e+005
% FitError =
%         1.1899
%
% Example 7:
% >> peakfit([x' y'],.4,.7,2,1,0,10,[.3 .1 .5 .1]);
% As above, but specifies the first-guess position and width of the two
% peaks, in the order [position1 width1 position2 width2]
%
% Example 8: (Version 4 only)
% Demonstration of the four BaselineMode modes, for a single Gaussian on flat
%  baseline, with position=10, height=1, and width=1.66. BaselineMode mode
%  is specified by the 9th input argument (0,1,2,or 3).
% >> x=8:.05:12;y=1+exp(-(x-10).^2);
% >> [FitResults,FitError]=peakfit([x;y],0,0,1,1,0,1,0,0)
% BaselineMode=0 means to ignore the baseline (default mode if not specified)
% FitResults =
%         1           10       1.8561        3.612       5.7641
% FitError =
%         5.387
% >> [FitResults,FitError]=peakfit([x;y],0,0,1,1,0,1,0,1)
% BaselineMode=1 subtracts linear baseline from edge to edge.
% Does not work well because signal does not return to baseline at edges.
% FitResults =
%         1       9.9984      0.96153        1.559       1.5916
% FitError =
%        1.9801
% >> [FitResults,FitError]=peakfit([x;y],0,0,1,1,0,1,0,2)
% BaselineMode=1 subtracts quadratic baseline from edge to edge.
% Does not work well because signal does not return to baseline at edges.
% FitResults =
%         1       9.9996      0.81749       1.4384       1.2503
% FitError =
%        1.8204
% BaselineMode=3: Flat baseline mode, measures baseline by regression
% >> [FitResults,FitError,Baseline]=peakfit([x;y],0,0,1,1,0,1,0,3)
% FitResults =
%         1           10       1.0001       1.6653       1.7645
% Baseline =
%     0.0037056
% FitError =
%       0.99985
%
% Example 9:
% x=[0:.1:10];y=exp(-(x-5).^2)+.5*exp(-(x-3).^2)+.1*randn(size(x));
% [FitResults,FitError]=peakfit([x' y'],0,0,2,11,0,0,0,0,[1.666 1.666])
% Same as example 3, fit with fixed-width Gaussian (shape 11), width=1.666
% 
% Example 10: (Version 3 or later; Prints out parameter error estimates)
% x=0:.05:9;y=exp(-(x-5).^2)+.5*exp(-(x-3).^2)+.01*randn(1,length(x));
% [FitResults,GOF,baseline,coeff,residual,xi,yi,BootResults]=peakfit([x;y],0,0,2,6,0,1,0,0,0);
%
% Example 11: (Version 3.2 or later)
% x=[0:.005:1];;[FitResults,FitError]=peakfit([x' y'],0.54,0.93,2,13,15,10,0,0,0) 
%
% FitResults =
%         1      0.30078       190.41      0.19131       23.064
%         2      0.89788       39.552      0.33448       6.1999
% FitError = 
%       0.34502
% Fits both peaks of the Humps function with a Gaussian/Lorentzian blend
% (shape 13) that is 15% Gaussian (Extra=15).
% 
% Example 12:  (Version 3.2 or later)
% >> x=[0:.1:10];y=exp(-(x-4).^2)+.5*exp(-(x-5).^2)+.01*randn(size(x));
% >> [FitResults,FitError]=peakfit([x' y'],0,0,1,14,45,10,0,0,0) 
% FitResults =
%         1       4.2028       1.2315        4.077       2.6723
% FitError =
%       0.84461
% Fit a slightly asymmetrical peak with a bifurcated Gaussian (shape 14)
% 
% Example 13:  (Version 3.3 or later)
% >> x=[0:.1:10]';y=exp(-(x-5).^2);peakfit([x y],0,0,1,1,0,0,0,0,0,0)
% Example 1 without plotting (11th input argument = 0, default is 1)
% 
% Example 14:  (Version 3.9 or later)
% Exponentially broadened Lorentzian with position=9, height=1.
% x=[0:.1:20]; 
% L=lorentzian(x,9,1);
% L1=ExpBroaden(L',-10)+0.02.*randn(size(x))';
% [FitResults,FitError]=peakfit([x;L1'],0,0,1,18,10)
%
% Example 15: Fitting humps function with two Voigts (version 9.2)
% disp('   Peak #      Position     Height     Width     Area      Alpha')
% [FitResults,FitError]=peakfit(humps(0:.01:2),60,120,2,30,1.7,5,0)
% FitResults =
%        1      31.629      95.175      19.469      2404.5      2.1355
%        2      90.736      19.826      33.185      764.32      1.3188
% FitError =
%       0.76176      0.99907
%
% Example 16: (Version 4.3 or later) Set +/- mode to 1 (bipolar)
% x=[0:.1:10];y=exp(-(x-5).^2)-.5*exp(-(x-3).^2)+.1*randn(size(x));
% peakfit([x' y'],0,0,2,1,0,1,0,0,0,1,1)
% FitResults =
%         1       3.1636      -0.5433         1.62      -0.9369
%         2       4.9487      0.96859       1.8456       1.9029
% FitError =
%        8.2757
%
% Example 17: Version 5 or later. Fits humps function to a model consisting 
% of one Lorentzian (shape=2) and one Gaussian (shape=1). 
% x=[0:.005:1.2];y=humps(x);[FitResults,FitError]=peakfit([x' y'],0,0,2,[2 1],[0 0])
% FitResults =
%     1.0000    0.3018   97.3992    0.1886   25.1164
%     2.0000    0.8962   18.7892    0.3369    6.6241
% GOF =
%     1.0744    0.998
%
% Example 18: 5 peaks, 5 different shapes, all heights = 1, widths = 3.
% x=0:.1:60;
% y=modelpeaks2(x,[1 2 3 4 5],[1 1 1 1 1],[10 20 30 40 50],...
% [3 3 3 3 3],[0 0 0 2 -20])+.01*randn(size(x));
% peakfit([x' y'],0,0,5,[1 2 3 4 5],[0 0 0 2 -20])
%
% Example 19: Minimum width constraint (13th input argument)
% x=1:30;y=gaussian(x,15,8)+.05*randn(size(x));
% No constraint:
% peakfit([x;y],0,0,5,1,0,10,0,0,0,1,0,0);
% Widths constrained to values above 7:
% peakfit([x;y],0,0,5,1,0,10,0,0,0,1,0,7);
%
% Example 20: Noise test with peak height = RMS noise = 1.
% x=[-5:.02:5];y=exp(-(x).^2)+randn(size(x));P=peakfit([x;y],0,0,1,1,0,10,0,0,0,1,1);
%
% Example 21a: Gaussian peak on strong sloped straight-line baseline, 2-peak
% fit with variable-slope straight line ("second peak" is shape 26, peakfit version 6 or later).
% x=8:.05:12;y=x+exp(-(x-10).^2);
% [FitResults,FitError]=peakfit([x;y],0,0,2,[1 26],[1 1],1,0)
% FitResults =           
%         1           10            1       1.6651       1.7642
%         2        4.485      0.22297         0.05       40.045
% FitError =0.093
%
% Example 21b: As above, but with TWO signal peaks, peakshape=[1 1 26],
% helped by adding rough first guesses {'start') using the 'polyfit'
% function to generate first guesses for the sloping baseline:
%  x=7:.05:13;y=x/2+exp(-(x-9).^2)+exp(-(x-11).^2);
% start=[8 1 10 1 polyfit(x,y,1)];
% [FitResults,FitError]=peakfit([x;y],0,0,3,[1 1 26],[1 1 1],1,start)
%
% Example 22: Segmented linear fit (Shape 29, peakfit version 6 or later):
% x=[0.9:.005:1.7];y=humps(x);
% peakfit([x' y'],0,0,9,29,0,10,0,0,0,1,1)
%
% Example 23: Sixth degree polynomial fit (Shape 28, peakfit version 6 or later)
%   x=[0.3:.005:1.7];y=humps(x);y=y+cumsum(y);
%   peakfit([x' y'],0,0,1,28,6,10,0,0,0,1,1)
%
% Example 24: Effect of quantization of independent (x) and dependent (y) variables.
% x=.5+round([2:.02:7.5]);y=exp(-(x-5).^2)+randn(size(x))/10;peakfit([x;y])
% x=[2:.01:8];y=exp(-(x-5).^2)+.1.*randn(size(x));y=.1.*round(10.*y);peakfit([x;y])
%
% Example 25: Variable-alpha Voigt functions, shape 30. Alphas in 6th
% column. (Version 9.2  and above only).
% disp('Peak #          Position        Height       Width          Area  ')
% x=[0.05:.005:1.3];y=humps(x);[FitResults,FitError]=peakfit([x' y'],60,120,2,30,1,10)
% FitResults =
%             1      0.32444       95.456      0.21091       24.055       1.8289
%             2      0.91766       19.683      0.35456       7.3905       0.5063
% FitError =
%       0.72515      0.99917
%
% Example 26: Variable time constant exponentially-broadened Gaussian
% function, shape 31. (Version 7 and above only). FitResults has an added
% 6th column for the measured  time constant of each peak.
% [FitResults,FitError]=peakfit(DataMatrix3,1860,364,2,31,33,5,[1810 60 30 1910 60 30])
% FitResults =
%             1      0.47574       95.577     0.069393       24.447      0.16757
%             2      0.77201       19.022      0.31018       7.3148     0.070638
% GOF =
%       0.81455      0.99894
% Alternative formulation, peakshape 39 (version 8.4 and above) has the
% same shape but is parameterized differently (width is standard deviation
% rather than halfwidth, shape constant is reciprocal):
%  [FitResults,FitError]=peakfit(DataMatrix3,1860,370,2,39,.06,10)
%
% Example 27: Pearson variable shape, PeakShape=32,(Version 7 and above
% only). Requires modelpeaks2 function in path.
% x=1:.1:30;y=modelpeaks2(x,[4 4],[1 1],[10 20],[5 5],[1 10]);
% [FitResults,FitError]=peakfit([x;y],0,0,2,32,10,5)
%
% Example 28: Gaussian/Lorentzian blend variable shape, PeakShape=33
% (Version 7 and above only). Requires modelpeaks2 function in path.
% x=1:.1:30;y=modelpeaks2(x,[13 13],[1 1],[10 20],[3 3],[20 80]);
% [FitResults,FitError]=peakfit([x;y],0,0,2,33,0,5)
%
% Example 29:  Fixed-position Gaussian (shape 16), positions=[3 5]. 
% x=0:.1:10;y=exp(-(x-5).^2)+.5*exp(-(x-3).^2)+.1*randn(size(x));
% [FitResults,FitError]=peakfit([x' y'],0,0,2,16,0,0,0,0,[3 5])
%
% Example 30: Fixed-width Gaussian/Lorentzian blend (shape 35), 
% width=[3 3], compared to variable-width fit (shape 13). Fitting
% error is larger but nevertheless results are more accurate.
% x=0:.1:10;y=GL(x,4,3,50)+.5*GL(x,6,3,50)+.1*randn(size(x));
% [FitResults,FitError]=peakfit([x;y],0,0,2,13,50,1)
%          1       4.0632       1.0545       3.2182       3.9242
%          2       6.2736      0.41234       2.8114       1.3585
%  GOF =  6.4311      0.95211 
% [FitResults,FitError]=peakfit([x;y],0,0,2,35,50,1,0,0,[3 3])
% FitResults =
%          1       3.9527       1.0048            3       3.5138
%          2       6.1007       0.5008            3       1.7502
% 
%  GOF =  6.4783      0.95141
%
% Example 31: Variable time constant exponentially-broadened Lorentzian
% function, shape 38. (Version 7.7 and above only). FitResults has an added
% 6th column for the measured time constant.
% x=[1:100]';
% y=explorentzian(x',40,5,-10)+.01*randn(size(x));
% peakfit([x y],0,0,1,38,0,10)
%
% Example 32: 3-parameter logistic (Gompertz), shape 43. (Version 7.9 and
% above only). Parameters labeled Bo, Kh, and L. FitResults extended to 6
% columns. 
% t=0:.1:10; Bo=6;Kh=3;L=4;
% y=Bo*exp(-exp((Kh*exp(1)/Bo)*(L-t)+1))+.1.*randn(size(t));
% [FitResults,GOF]=peakfit([t;y],0,0,1,43)
%
% Example 33: Shape 46, 'quadslope' (version 8 and above). Two overlapping
% Gaussians (positions=9,11; heights=1; widths=1.666) on a curved baseline,
% using a 3-peak fit with peakshape=[1 1 46], default NumTrials and start.
% x=7:.05:13;
% y=x.^2/50+exp(-(x-9).^2)+exp(-(x-11).^2)+.01.*randn(size(x));
% [FitResults,FitError]=peakfit([x;y],0,0,3,[1 1 46],[1 1 1])
%
% Example 34: Comparison of alternative exponentially broadened Gaussians,
% shape 31 and 39. Both have the same shape but are parameterized
% differently. See the script GaussVsExpGauss.m, Figure windows 2 and 3.

% Example 35: Peakfit 9 and above. Use of peak shape 50 ("multilinear
% regression") when the peak positions and widths are known, and only the
% peak heights are unknown. The peak shapes, positions, and widths are
% specified in the 10th input argument "fixedparameters". See the
% demonstration scripts peakfit9demo.m and peakfit9demoL.m.
% 
% Example 36: Use of "start" in 4-Gaussian fit to the "humps" function
% x=[-.1:.005:1.2];y=humps(x);
% First attempt with default start values gives poor fit:
% [FitResults,GOF]=peakfit([x;y],0,0,4,1,0,10)
% Second attempt specifying approximate start values gives much better fit:
% [FitResults,GOF]=peakfit([x;y],0,0,4,1,0,10,[0.3 0.13 0.3 0.34 0.63 0.15 0.89 0.35])
%
% Download scripts and functions from 
% https://terpconnect.umd.edu/~toh/spectrum/functions.html

% Copyright (c) 2019, Thomas C. O'Haver
 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", 2WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
% 
global AA xxx PEAKHEIGHTS FIXEDPARAMETERS delta BIPOLAR CLIPHEIGHT
% format short g
format compact
warning off all
NumArgOut=nargout;
datasize=size(signal);
if datasize(1)<datasize(2),signal=signal';end
datasize=size(signal);
if datasize(2)==1 %  'signal' is a vector; Must be peakfit(Y-vector)
    X=1:length(signal); % Create an independent variable vector
    Y=signal;
else
    % 'signal' is a matrix. Must be peakfit(DataMatrix)
    X=signal(:,1); % Split matrix argument 
    Y=signal(:,2);
end
X=reshape(X,1,length(X)); % Adjust X and Y vector shape to 1 x n (rather than n x 1)
Y=reshape(Y,1,length(Y));
% If necessary, flip the data vectors so that X increases
if X(1)>X(length(X))
    disp('X-axis flipped.')
    X=fliplr(X);
    Y=fliplr(Y);
end

% Isolate desired segment from data set for curve fitting
if nargin==1 || nargin==2,center=(max(X)-min(X))/2;window=max(X)-min(X);end
% Y=Y-min(Y);
xoffset=0;
n1=val2ind(X,center-window/2);
n2=val2ind(X,center+window/2);
if window==0,n1=1;n2=length(X);end
xx=X(n1:n2)-xoffset;
yy=Y(n1:n2);
ShapeString='Gaussian';
coeff=0;
CLIPHEIGHT=max(Y);
LOGPLOT=0;
% Define values of any missing arguments
% (signal,center,window,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,plots,bipolar,minwidth,DELTA)
switch nargin
    case 1
        NumPeaks=1;
        peakshape=1;
        extra=1;
        NumTrials=1;
        xx=X;yy=Y;
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=xx(2)-xx(1);
        delta=1;
        CLIPHEIGHT=max(Y);
    case 2
        NumPeaks=1;
        peakshape=1;
        extra=1;
        NumTrials=1;
        xx=signal;yy=center;
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=xx(2)-xx(1);
        delta=1;
        CLIPHEIGHT=max(Y);
    case 3
        NumPeaks=1;
        peakshape=1;
        extra=1;
        NumTrials=1;
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=xx(2)-xx(1);
        delta=1;
        CLIPHEIGHT=max(Y);
    case 4 % Numpeaks specified in arguments
        peakshape=1;
        extra=1;
        NumTrials=1;
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=xx(2)-xx(1);
        delta=1;
        CLIPHEIGHT=max(Y);
    case 5 % Numpeaks, peakshape specified in arguments
        extra=ones(1,NumPeaks);
        NumTrials=1;
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
        CLIPHEIGHT=max(Y);
    case 6
        NumTrials=1;
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
    case 7
        start=calcstart(xx,NumPeaks,xoffset);
        BaselineMode=0;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
        CLIPHEIGHT=max(Y);
    case 8
        BaselineMode=0;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
        CLIPHEIGHT=max(Y);
    case 9
        % initialstart=start % testing
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=0;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
    case 10
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=fixedparameters;
        plots=1;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
    case 11
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=fixedparameters;
        BIPOLAR=0;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
        CLIPHEIGHT=max(Y);
    case 12
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=fixedparameters;
        BIPOLAR=bipolar;
        MINWIDTH=zeros(size(peakshape))+(xx(2)-xx(1));
        delta=1;
        CLIPHEIGHT=max(Y);
    case 13
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=fixedparameters;
        BIPOLAR=bipolar;
        MINWIDTH=minwidth;
        delta=1;
    case 14
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=fixedparameters;
        BIPOLAR=bipolar;
        MINWIDTH=minwidth;
        delta=DELTA;
        CLIPHEIGHT=max(Y);
    case 15
        BaselineMode=BaselineMode;
        FIXEDPARAMETERS=fixedparameters;
        BIPOLAR=bipolar;
        MINWIDTH=minwidth;
        delta=DELTA;
        CLIPHEIGHT=clipheight;
    otherwise
end % switch nargin
% Saturation Code, skips points greater than set maximum
if CLIPHEIGHT<max(Y)
    apnt=1;
    for pnt=1:length(xx) 
        if yy(pnt)<CLIPHEIGHT
            axx(apnt)=xx(pnt);
            ayy(apnt)=yy(pnt);
            apnt=apnt+1;
        end
    end
    xx=axx;yy=ayy;
end
% Default values for placeholder zeros1
if NumTrials==0;NumTrials=1;end
shapesvector=peakshape;
if isscalar(peakshape) 
else
    % disp('peakshape is vector');
    shapesvector=peakshape;
    NumPeaks=length(peakshape);
    peakshape=22;
end
if peakshape==0;peakshape=1;end
if NumPeaks==0;NumPeaks=1;end
if start==0;start=calcstart(xx,NumPeaks,xoffset);end
% firststart=start; % <<<<<<<<<<<
if FIXEDPARAMETERS==0, FIXEDPARAMETERS=length(xx)/10;end
if peakshape==16;FIXEDPOSITIONS=fixedparameters;end
if peakshape==17;FIXEDPOSITIONS=fixedparameters;end
if BaselineMode>3,BaselineMode=3;disp('AUTPOZERO must be between 0 and 3');end
if BaselineMode<0,BaselineMode=0;disp('AUTPOZERO must be between 0 and 3');end
Heights=zeros(1,NumPeaks);
FitResults=zeros(NumPeaks,6);

% % Remove linear baseline from data segment if BaselineMode==1
baseline=0;
bkgcoef=0;
bkgsize=round(length(xx)/10);
if bkgsize<2,bkgsize=2;end
lxx=length(xx);
if BaselineMode==1 % linear BaselineMode operation  
    XX1=xx(1:round(lxx/bkgsize));
    XX2=xx((lxx-round(lxx/bkgsize)):lxx);
    Y1=yy(1:(round(length(xx)/bkgsize)));
    Y2=yy((lxx-round(lxx/bkgsize)):lxx);
    bkgcoef=polyfit([XX1,XX2],[Y1,Y2],1);  % Fit straight line to sub-group of points
    bkg=polyval(bkgcoef,xx);
    yy=yy-bkg;
end % if
if BaselineMode==2 % Quadratic BaselineMode operation  
    XX1=xx(1:round(lxx/bkgsize));
    XX2=xx((lxx-round(lxx/bkgsize)):lxx);
    Y1=yy(1:round(length(xx)/bkgsize));
    Y2=yy((lxx-round(lxx/bkgsize)):lxx);
    bkgcoef=polyfit([XX1,XX2],[Y1,Y2],2);  % Fit parabola to sub-group of points
    bkg=polyval(bkgcoef,xx);
    yy=yy-bkg;
end % if BaselineMode

PEAKHEIGHTS=zeros(1,NumPeaks);
n=length(xx);
newstart=start;
% Assign ShapStrings
switch peakshape(1)
    case 1
        ShapeString='Gaussian';
    case 2
        ShapeString='Lorentzian';
    case 3
        ShapeString='Logistic';
    case 4
        ShapeString='Pearson';
    case 5
        ShapeString='ExpGaussian';
    case 6
        ShapeString='Equal width Gaussians';
    case 7
        ShapeString='Equal width Lorentzians';
    case 8
        ShapeString='Exp. equal width Gaussians';
    case 9
        ShapeString='Exponential Pulse';
    case 10
        ShapeString='Up Sigmoid (logistic function)';
    case 23
        ShapeString='Down Sigmoid (logistic function)';  
    case 11
        ShapeString='Fixed-width Gaussian';
    case 12
        ShapeString='Fixed-width Lorentzian';
    case 13
        ShapeString='Gaussian/Lorentzian blend';
    case 14
        ShapeString='BiGaussian';    
    case 15
        ShapeString='Breit-Wigner-Fano';   
    case 16
        ShapeString='Fixed-position Gaussians';
    case 17
        ShapeString='Fixed-position Lorentzians';
    case 18
        ShapeString='Exp. Lorentzian';
    case 19
        ShapeString='Alpha function';
    case 20
        ShapeString='Voigt (equal alphas)';
    case 21
        ShapeString='triangular';
    case 22
        ShapeString=num2str(shapesvector);
    case 24
        ShapeString='Negative Binomial Distribution';
    case 25
        ShapeString='Lognormal Distribution';
    case 26
        ShapeString='slope';
    case 27
        ShapeString='First derivative';
    case 28
        ShapeString='Polynomial';
    case 29
        ShapeString='Segmented linear';
    case 30
        ShapeString='Voigt (variable alphas)';
    case 31
        ShapeString='ExpGaussian (variable tau)';
    case 32
        ShapeString='Pearson (var. shape)';
    case 33
        ShapeString='Variable Gaussian/Lorentzian';
    case 34
        ShapeString='Fixed-width Voigt';
    case 35
        ShapeString='Fixed-width G/L blend';
    case 36
        ShapeString='Fixed-width ExpGaussian';
    case 37
        ShapeString='Fixed-width Pearson';
    case 38
        ShapeString='ExpLorentzian ((variable tau)'; 
    case 39
        ShapeString='ExpGaussian2 (variable lambda)';  
    case 40
        ShapeString='Sine wave';
    case 41
        ShapeString='Rectangular pulse';
    case 42
        ShapeString='Flattened Gaussian';  
    case 43
        ShapeString='Gompertz';  
    case 44
        ShapeString='1-exp(-k*t)';  
    case 45
        ShapeString='4-parameter logistic'; 
    case 46
        ShapeString='Quadratic Baseline'; 
    case 47
        ShapeString='Blackbody'; 
    case 48
        ShapeString='Equal-width exp. pulse'; 
    case 49
        ShapeString='Pearson IV'; 
    case  50
        ShapeString='Multilinear regression';
    otherwise
end % switch peakshape
  
% Perform peak fitting for selected peak shape using fminsearch function
options = optimset('TolX',.0000001,'Display','off','MaxFunEvals',1000 );
LowestError=1000; % or any big number greater than largest error expected
FitParameters=zeros(1,NumPeaks.*3); 
BestStart=zeros(1,NumPeaks.*2); 
height=zeros(1,NumPeaks); 
bestmodel=zeros(size(yy));
TrialParameters=zeros(1,NumPeaks.*3);
for k=1:NumTrials
    % StartMatrix(k,:)=newstart;
    % disp(['Trial number ' num2str(k) ] ) % optionally prints the current trial number as progress indicator
    switch peakshape(1)
        case 1
            TrialParameters=fminsearch(@(lambda)(fitgaussian(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 2
            TrialParameters=fminsearch(@(lambda)(fitlorentzian(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 3
            TrialParameters=fminsearch(@(lambda)(fitlogistic(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 4
            TrialParameters=fminsearch(@(lambda)(fitpearson(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 5
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[zeros(size(yy)) yy zeros(size(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexpgaussian(lambda,zxx,zyy,-extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 6
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitewgaussian(lambda,xx,yy)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 7
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitewlorentzian(lambda,xx,yy)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 8
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitexpewgaussian(lambda,xx,yy,-extra)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 9
            TrialParameters=fminsearch(@(lambda)(fitexppulse(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 10
            TrialParameters=fminsearch(@(lambda)(fitupsigmoid(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 23
            TrialParameters=fminsearch(@(lambda)(fitdownsigmoid(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 11
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            % fixedstart=fixedstart
            TrialParameters=fminsearch(@(lambda)(FitFWGaussian(lambda,xx,yy)),fixedstart,options);
        case 12
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(FitFWLorentzian(lambda,xx,yy)),fixedstart,options);
        case 13
            TrialParameters=fminsearch(@(lambda)(fitGL(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 14
            TrialParameters=fminsearch(@(lambda)(fitBiGaussian(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 15
            TrialParameters=fminsearch(@(lambda)(fitBWF(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 16
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=(max(xx)-min(xx))./(NumPeaks+1);
                fixedstart(pc)=fixedstart(pc)+.1*(rand-.5).*fixedstart(pc);
            end
            TrialParameters=fminsearch(@(lambda)(FitFPGaussian(lambda,xx,yy)),fixedstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(Peak)<MINWIDTH
                    TrialParameters(Peak)=MINWIDTH;
                end
            end
        case 17
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=(max(xx)-min(xx))./(NumPeaks+1);
                fixedstart(pc)=fixedstart(pc)+.1*(rand-.5).*fixedstart(pc);
            end
            TrialParameters=fminsearch(@(lambda)(FitFPLorentzian(lambda,xx,yy)),fixedstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(Peak)<MINWIDTH
                    TrialParameters(Peak)=MINWIDTH;
                end
            end
        case 18
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[ones(size(yy)).*yy(1) yy zeros(size(yy)).*yy(length(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexplorentzian(lambda,zxx,zyy,-extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 19
            TrialParameters=fminsearch(@(lambda)(fitalphafunction(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 20
            TrialParameters=fminsearch(@(lambda)(fitvoigt(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 21
            TrialParameters=fminsearch(@(lambda)(fittriangular(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 22
            TrialParameters=fminsearch(@(lambda)(fitmultiple(lambda,xx,yy,NumPeaks,shapesvector,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH(Peak)
                    TrialParameters(2*Peak)=MINWIDTH(Peak);
                end
            end
        case 24
            TrialParameters=fminsearch(@(lambda)(fitnbinpdf(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 25
            TrialParameters=fminsearch(@(lambda)(fitlognpdf(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 26
            TrialParameters=fminsearch(@(lambda)(fitlinslope(lambda,xx,yy)),polyfit(xx,yy,1),options);
             coeff=TrialParameters;
        case 27
            TrialParameters=fminsearch(@(lambda)(fitd1gauss(lambda,xx,yy)),newstart,options);
        case 28
            coeff=fitpolynomial(xx,yy,extra);
            TrialParameters=coeff;
        case 29
            cnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cnewstart(pc)=newstart(2.*pc-1)+(delta*(rand-.5)/50);
            end
            TrialParameters=fminsearch(@(lambda)(fitsegmented(lambda,xx,yy)),cnewstart,options);
        case 30 % Voigt variable alpha
            % newstart=newstart % testing
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
%             case30newstart=newstart % uncomment for testing
%             sizestartcase30=size(start) % uncomment for testing
            TrialParameters=fminsearch(@(lambda)(fitvoigtv(lambda,xx,yy)),start);
         case 31 % Variable time constant expgaussian
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
            % case31newstart=newstart % uncomment for testing
            % sizestartcase31=size(start) % uncomment for testing
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[ones(size(yy)).*yy(1) yy zeros(size(yy)).*yy(length(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexpgaussianv(lambda,zxx,zyy)),newstart);
        case 32 % Variable shape Peason
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
%             case32newstart=newstart % uncomment for testing
%             sizestartcase32=size(start) % uncomment for testing
            TrialParameters=fminsearch(@(lambda)(fitpearsonv(lambda,xx,yy)),newstart);
        case 33 % Variable GL blend
             nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
            % newstart=newstart % uncomment for testing
            TrialParameters=fminsearch(@(lambda)(fitGLv(lambda,xx,yy)),newstart);
        case 34
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end  
            % fixedstart=fixedstart % uncomment for testing
            TrialParameters=fminsearch(@(lambda)(fitFWVoigt(lambda,xx,yy,extra)),fixedstart,options);
        case 35
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end            
            TrialParameters=fminsearch(@(lambda)(fitFWGL(lambda,xx,yy,extra)),fixedstart,options);
        case 36
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(fitFWExpGaussian(lambda,xx,yy,-extra)),fixedstart,options);
        case 37
            fixedstart=[];

            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end            
            TrialParameters=fminsearch(@(lambda)(fitFWPearson(lambda,xx,yy,extra)),fixedstart,options);
        case 38
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
            % newstart=newstart
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[ones(size(yy)).*yy(1) yy zeros(size(yy)).*yy(length(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexplorentzianv(lambda,zxx,zyy)),newstart);
        case 39 % ExpGaussian2 (variable lambda)
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+2)*(1+randn/20);
            end
%            case39newstart=newstart % <<<<< uncomment for testing
            % sizestartcase39=size(start) % <<<<< uncomment for testing
%             zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
%             zyy=[ones(size(yy)).*yy(1) yy zeros(size(yy)).*yy(length(yy)) ];
            TrialParameters=fminsearch(@(lambda)(FitExpGaussian2(lambda,xx,yy)),newstart);
        case 40
             TrialParameters=fminsearch(@(lambda)(fitsine(lambda,xx,yy)),newstart,options); 
        case 41
            TrialParameters=fminsearch(@(lambda)(fitrectangle(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 42
            TrialParameters=fminsearch(@(lambda)(fitngaussian(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 43
             nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
            TrialParameters=fminsearch(@(lambda)(fitGompertz(lambda,xx,yy)),newstart);

        case 44
            TrialParameters=fminsearch(@(lambda)(fitOneMinusExp(lambda,xx,yy)),newstart,options);
         case 45
             nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/5 extra];
            end % for marker
             newstart=start;
            for parameter=1:3:3*NumPeaks
                newstart(parameter)=newstart(parameter)*(1+randn/100);
                newstart(parameter+1)=newstart(parameter+1)*(1+randn/20);
                newstart(parameter+2)=newstart(parameter+1)*(1+randn/20);
            end
            % newstart=newstart % uncomment for testing
            TrialParameters=fminsearch(@(lambda)(fitFourPL(lambda,xx,yy)),newstart);
        case 46
            TrialParameters=fminsearch(@(lambda)(fitquadslope(lambda,xx,yy)),newstart,options);
        case 47
            bbstart=3000;
            TrialParameters=fminsearch(@(lambda)(fitblackbody(lambda,xx,yy)),bbstart,options);
        case 48
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitewexpulse(lambda,xx,yy)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 49
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/6 1 1];
            end % for marker
             newstart=start;
            for element=1:length(start)
                newstart(element)=newstart(element)*(1+randn/100);
            end
            % newstart1251=newstart
            TrialParameters=fminsearch(@(lambda)(fitPearsonIV(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(3*Peak)>100
                    TrialParameters(3*Peak)=100;
                end
            end
        case 50
            for m=1:NumPeaks
                mm(m,:)=modelpeaks(xx,1,FIXEDPARAMETERS(m,1),1,FIXEDPARAMETERS(m,2),FIXEDPARAMETERS(m,3));
            end
            PEAKHEIGHTS=(yy/mm)'; % Compute peak heights by multilinear regression
        otherwise
    end % switch peakshape

    % Check variables
    % sizeNewstart=size(newstart) % uncomment for testing
  
% Construct model from Trial parameters
A=zeros(NumPeaks,n);
for m=1:NumPeaks
    switch peakshape(1)
        case 1
            A(m,:)=gaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 2
            A(m,:)=lorentzian(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 3
            A(m,:)=logistic(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 4
            A(m,:)=pearson(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
        case 5
            A(m,:)=expgaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m),-extra)';
        case 6
            A(m,:)=gaussian(xx,TrialParameters(m),TrialParameters(NumPeaks+1));
        case 7
            A(m,:)=lorentzian(xx,TrialParameters(m),TrialParameters(NumPeaks+1));
        case 8
            A(m,:)=expgaussian(xx,TrialParameters(m),TrialParameters(NumPeaks+1),-extra)';
        case 9
            A(m,:)=exppulse(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 10
            A(m,:)=upsigmoid(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 11
            A(m,:)=gaussian(xx,TrialParameters(m),FIXEDPARAMETERS(m));
        case 12
            A(m,:)=lorentzian(xx,TrialParameters(m),FIXEDPARAMETERS(m));
        case 13
            A(m,:)=GL(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
        case 14
            A(m,:)=BiGaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
        case 15
            A(m,:)=BWF(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);        
        case 16
            A(m,:)=gaussian(xx,FIXEDPARAMETERS(m),TrialParameters(m));
        case 17
            A(m,:)=lorentzian(xx,FIXEDPARAMETERS(m),TrialParameters(m));
        case 18
            A(m,:)=explorentzian(xx,TrialParameters(2*m-1),TrialParameters(2*m),-extra)';
        case 19
            A(m,:)=alphafunction(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 20
            A(m,:)=voigt(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);        
        case 21
            A(m,:)=triangular(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 22
            A(m,:)=peakfunction(shapesvector(m),xx,TrialParameters(2*m-1),TrialParameters(2*m),extra(m));        
        case 23
            A(m,:)=downsigmoid(xx,TrialParameters(2*m-1),TrialParameters(2*m));        
        case 24
            A(m,:)=nbinpdf(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 25
            A(m,:)=lognormal(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 26
            A(m,:)=linslope(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 27
            A(m,:)=d1gauss(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 28
            A(m,:)=polynomial(xx,coeff);
        case 29
            A(m,:)=segmented(xx,yy,PEAKHEIGHTS);
        case 30
            A(m,:)=voigt(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
        case 31
            A(m,:)=expgaussian(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),-TrialParameters(3*m));        
        case 32
            A(m,:)=pearson(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
        case 33
            A(m,:)=GL(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));
        case 34
             width(m)=abs(FIXEDPARAMETERS(m));
%                 gD(m)=width(m);
%                 gL(m)=extra.*gD(m);
%                 width(m) = 2.*(0.5346*gL(m) + sqrt(0.2166*gL(m).^2 + gD(m).^2))
            A(m,:)=voigt(xx,TrialParameters(m), width(m),extra);
        case 35
            A(m,:)=GL(xx,TrialParameters(m),FIXEDPARAMETERS(m),extra);    
        case 36
            A(m,:)=expgaussian(xx,TrialParameters(m),FIXEDPARAMETERS(m),-extra);    
        case 37
            A(m,:)=pearson(xx,TrialParameters(m),FIXEDPARAMETERS(m),extra);    
        case 38
            A(m,:)=explorentzian(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),-TrialParameters(3*m));        
        case 39
            A(m,:)=ExpGaussian2(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
        case 40
            A(m,:)=sine(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 41
            A(m,:)=rectangle(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 42
            A(m,:)=ngaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
        case 43
            A(m,:)=Gompertz(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
        case 44
            A(m,:)=OneMinusExp(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 45
            A(m,:)=FourPL(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
        case 46
            A(m,:)=quadslope(xx,TrialParameters(2*m-1),TrialParameters(2*m));
        case 47
            A(m,:)=blackbody(xx,TrialParameters(m));
        case 48
            A(m,:)=exppulse(xx,TrialParameters(m),TrialParameters(NumPeaks+1));
        case 49
            A(m,:)=PearsonIV(xx,TrialParameters(4*m-3),TrialParameters(4*m-2),TrialParameters(4*m-1),TrialParameters(4*m));
        case 50
            A(m,:)=modelpeaks(xx,1,FIXEDPARAMETERS(m,1),1,FIXEDPARAMETERS(m,2),FIXEDPARAMETERS(m,3));
    end % switch
    xxrange=max(xx)-min(xx);
    for parameter=1:2:2*NumPeaks
        newstart(parameter)=newstart(parameter)+(xxrange.*(delta*randn)./(NumPeaks+1));
        newstart(parameter+1)=newstart(parameter+1)*(1+delta*(rand-.5)/100);
    end
end % for NumPeaks
% newstart=newstart; % <<<<<<<<<< % error check
% Multiplies each row by the corresponding amplitude and adds them up
if peakshape(1)==29 % Segmented linear
    model=segmented(xx,yy,PEAKHEIGHTS);
    TrialParameters=PEAKHEIGHTS;
    Heights=ones(size(PEAKHEIGHTS));
else
    if BaselineMode==3
        baseline=PEAKHEIGHTS(1);
        sizePEAKHEIGHTS=size(PEAKHEIGHTS);
        Heights=PEAKHEIGHTS(2:1+NumPeaks);
        model=Heights'*A+baseline;
    else
% sizePeakHeights=size(PEAKHEIGHTS) %  % uncomment for testing
%  SizeA=size(A)  % uncomment for testing
% PEAKHEIGHTS=PEAKHEIGHTS      
        model=PEAKHEIGHTS'*A;
        Heights=PEAKHEIGHTS;
        baseline=0;
    end
end
if peakshape(1)==28 % polynomial;
    model=polynomial(xx,coeff);
    TrialParameters=PEAKHEIGHTS;
    Heights=ones(size(PEAKHEIGHTS));
end
% Compare trial model to data segment and compute the fit error
    MeanFitError=100*norm(yy-model)./(sqrt(n)*max(yy));
  % Take only the single fit that has the lowest MeanFitError
  if MeanFitError<LowestError
      if min(Heights)>=-BIPOLAR*10^100  % Consider only fits with positive peak heights
        LowestError=MeanFitError;  % Assign LowestError to the lowest MeanFitError
        FitParameters=TrialParameters;  % Assign FitParameters to the fit with the lowest MeanFitError
        BestStart=newstart; % Assign BestStart to the start with the lowest MeanFitError
        height=Heights; % Assign height to the PEAKHEIGHTS with the lowest MeanFitError
        bestmodel=model; % Assign bestmodel to the model with the lowest MeanFitError
      end % if min(PEAKHEIGHTS)>0
  end % if MeanFitError<LowestError
%  ErrorVector(k)=MeanFitError; %  % uncomment for testing
end % for k (NumTrials)
    Rsquared=1-(norm(yy-bestmodel)./norm(yy-mean(yy)));
    SStot=sum((yy-mean(yy)).^2);
    SSres=sum((yy-bestmodel).^2);
    Rsquared=1-(SSres./SStot);
    GOF=[LowestError Rsquared];
% Uncomment following 4 lines to monitor trail fit starts and errors.
% StartMatrix=StartMatrix;
% ErrorVector=ErrorVector;
% matrix=[StartMatrix ErrorVector']
% std(StartMatrix)
% Construct model from best-fit parameters
AA=zeros(NumPeaks,600);
xxx=linspace(min(xx),max(xx),600);
% xxx=linspace(min(xx)-length(xx),max(xx)+length(xx),200);
for m=1:NumPeaks
   switch peakshape(1)
    case 1
        AA(m,:)=gaussian(xxx,FitParameters(2*m-1),FitParameters(2*m));
%                height=PEAKHEIGHTS
%        FitParameters=FitParameters
    case 2
        AA(m,:)=lorentzian(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 3
        AA(m,:)=logistic(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 4
        AA(m,:)=pearson(xxx,FitParameters(2*m-1),FitParameters(2*m),extra);
    case 5
        AA(m,:)=expgaussian(xxx,FitParameters(2*m-1),FitParameters(2*m),-extra*length(xxx)./length(xx))';
    case 6
        AA(m,:)=gaussian(xxx,FitParameters(m),FitParameters(NumPeaks+1));
    case 7
        AA(m,:)=lorentzian(xxx,FitParameters(m),FitParameters(NumPeaks+1));
    case 8
        AA(m,:)=expgaussian(xxx,FitParameters(m),FitParameters(NumPeaks+1),-extra*length(xxx)./length(xx))';
    case 9
        AA(m,:)=exppulse(xxx,FitParameters(2*m-1),FitParameters(2*m));  
    case 10
        AA(m,:)=upsigmoid(xxx,FitParameters(2*m-1),FitParameters(2*m));   
    case 11
        AA(m,:)=gaussian(xxx,FitParameters(m),FIXEDPARAMETERS(m));
    case 12
        AA(m,:)=lorentzian(xxx,FitParameters(m),FIXEDPARAMETERS(m));
    case 13
        AA(m,:)=GL(xxx,FitParameters(2*m-1),FitParameters(2*m),extra);
    case 14
        AA(m,:)=BiGaussian(xxx,FitParameters(2*m-1),FitParameters(2*m),extra);       
    case 15
        AA(m,:)=BWF(xxx,FitParameters(2*m-1),FitParameters(2*m),extra);       
    case 16
        AA(m,:)=gaussian(xxx,FIXEDPARAMETERS(m),FitParameters(m));
    case 17
        AA(m,:)=lorentzian(xxx,FIXEDPARAMETERS(m),FitParameters(m));
    case 18
        AA(m,:)=explorentzian(xxx,FitParameters(2*m-1),FitParameters(2*m),-extra*length(xxx)./length(xx))';
    case 19
        AA(m,:)=alphafunction(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 20
        AA(m,:)=voigt(xxx,FitParameters(2*m-1),FitParameters(2*m),extra);       
    case 21
        AA(m,:)=triangular(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 22
        AA(m,:)=peakfunction(shapesvector(m),xxx,FitParameters(2*m-1),FitParameters(2*m),extra(m));        
    case 23
        AA(m,:)=downsigmoid(xxx,FitParameters(2*m-1),FitParameters(2*m));  
    case 24
        AA(m,:)=nbinpdf(xxx,FitParameters(2*m-1),FitParameters(2*m));    
    case 25
        AA(m,:)=lognormal(xxx,FitParameters(2*m-1),FitParameters(2*m));    
    case 26
        AA(m,:)=linslope(xxx,FitParameters(2*m-1),FitParameters(2*m));   
    case 27
        AA(m,:)=d1gauss(xxx,FitParameters(2*m-1),FitParameters(2*m));  
    case 28
        AA(m,:)=polynomial(xxx,coeff);
    case 29
    case 30
        AA(m,:)=voigt(xxx,FitParameters(3*m-2),FitParameters(3*m-1),FitParameters(3*m));        
    case 31
        AA(m,:)=expgaussian(xxx,FitParameters(3*m-2),FitParameters(3*m-1),-FitParameters(3*m)*length(xxx)./length(xx));        
    case 32
        AA(m,:)=pearson(xxx,FitParameters(3*m-2),FitParameters(3*m-1),FitParameters(3*m));        
    case 33
        AA(m,:)=GL(xxx,FitParameters(3*m-2),FitParameters(3*m-1),FitParameters(3*m)); 
    case 34
                  width(m)=abs(FIXEDPARAMETERS(m));
%                 gD(m)=width(m);
%                 gL(m)=extra.*gD(m);
%                 width(m) = 2.*(0.5346*gL(m) + sqrt(0.2166*gL(m).^2 +
%                 gD(m).^2));
        AA(m,:)=voigt(xxx,FitParameters(m),width(m),extra);
    case 35
        AA(m,:)=GL(xxx,FitParameters(m),FIXEDPARAMETERS(m),extra);
    case 36
        AA(m,:)=expgaussian(xxx,FitParameters(m),FIXEDPARAMETERS(m),-extra*length(xxx)./length(xx))';    
    case 37
        AA(m,:)=pearson(xxx,FitParameters(m),FIXEDPARAMETERS(m),extra);
    case 38
        AA(m,:)=explorentzian(xxx,FitParameters(3*m-2),FitParameters(3*m-1),-FitParameters(3*m)*length(xxx)./length(xx));        
    case 40
        AA(m,:)=sine(xx,FitParameters(2*m-1),FitParameters(2*m));
    case 39
        AA(m,:)=ExpGaussian2(xxx,FitParameters(3*m-2),FitParameters(3*m-1),FitParameters(3*m));        
    case 41
        AA(m,:)=rectangle(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 42
        AA(m,:)=ngaussian(xxx,FitParameters(2*m-1),FitParameters(2*m),extra);
    case 43
        AA(m,:)=Gompertz(xxx,FitParameters(3*m-2),FitParameters(3*m-1),FitParameters(3*m));  
    case 44
        AA(m,:)=OneMinusExp(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 45
        AA(m,:)=FourPL(xxx,FitParameters(3*m-2),FitParameters(3*m-1),FitParameters(3*m));    
    case 46
        AA(m,:)=quadslope(xxx,FitParameters(2*m-1),FitParameters(2*m));
    case 47
        AA(m,:)=blackbody(xxx,FitParameters(m));
    case 48
        AA(m,:)=exppulse(xxx,FitParameters(m),FitParameters(NumPeaks+1));
    case 49
        AA(m,:)=PearsonIV(xxx,FitParameters(4*m-3),FitParameters(4*m-2),FitParameters(4*m-1),FitParameters(4*m));
    case 50  
        AA(m,:)=modelpeaks(xxx,1,FIXEDPARAMETERS(m,1),1,FIXEDPARAMETERS(m,2),FIXEDPARAMETERS(m,3));
%        height=PEAKHEIGHTS
%        FitParameters=FitParameters
       otherwise
  end % switch
end % for NumPeaks

% Multiplies each row by the corresponding amplitude and adds them up
if peakshape(1)==29 % Segmented linear
    mmodel=segmented(xx,yy,PEAKHEIGHTS);
    baseline=0;
else
    heightsize=size(height');
    AAsize=size(AA);
    if heightsize(2)==AAsize(1)
        mmodel=height'*AA+baseline;
    else
        mmodel=height*AA+baseline;
    end
end
% Top half of the figure shows original signal and the fitted model.
if plots
    subplot(2,1,1);plot(xx+xoffset,yy,'b.'); % Plot the original signal in blue dots
    hold on
end
if peakshape(1)==28 % Polynomial
     yi=polynomial(xxx,coeff);
else
    for m=1:NumPeaks
        if plots, plot(xxx+xoffset,height(m)*AA(m,:)+baseline,'g'),end  % Plot the individual component peaks in green lines
        area(m)=trapz(xxx+xoffset,height(m)*AA(m,:)); % Compute the area of each component peak using trapezoidal method
        yi(m,:)=height(m)*AA(m,:); % Place y values of individual model peaks into matrix yi
    end
end
xi=xxx+xoffset; % Place the x-values of the individual model peaks into xi
residual=yy-bestmodel;

if plots
    % Mark starting peak positions with vertical dashed magenta lines
    if peakshape(1)==16||peakshape(1)==17
    else
        if peakshape(1)==29 % Segmented linear
%            subplot(2,1,1);plot([PEAKHEIGHTS' PEAKHEIGHTS'],[0 max(yy)],'m--')
        else
            for marker=1:NumPeaks
                markx=BestStart((2*marker)-1);
%                subplot(2,1,1);plot([markx+xoffset markx+xoffset],[0 max(yy)],'m--')
            end % for
        end
    end % if peakshape

    % Plot the total model (sum of component peaks) in red lines
    if peakshape(1)==29 % Segmented linear
        mmodel=segmented(xx,yy,PEAKHEIGHTS);
       plot(xx+xoffset,mmodel,'r');  
    else
       plot(xxx+xoffset,mmodel,'r');  
    end
    hold off;
    lyy=min(yy);
    uyy=max(yy)+(max(yy)-min(yy))/10;
    if BIPOLAR
        axis([min(xx) max(xx) lyy uyy]);
        ylabel('+ - mode')
    else
        axis([min(xx) max(xx) 0 uyy]);
        ylabel('+ mode')
    end
    switch BaselineMode
        case 0
            title(['peakfit.m Version 9.61   No baseline correction'])
        case 1
            title(['peakfit.m Version 9.61   Linear baseline subtraction'])
        case 2
            title(['peakfit.m Version 9.61   Quadratic subtraction baseline'])
        case 3
            title(['peakfit.m Version 9.61   Flat baseline correction'])
    end
 
    switch peakshape(1)
        case {4,34,37,42}
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH) '      Shape Constant = ' num2str(extra)  '     Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000) ] )
        case {20}
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH) '      Alpha = ' num2str(extra)  '     Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000) ] )
        case {30}
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH) '      Alpha = ' num2str(extra)  '     Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000) ] )
        case {5,8,18,36}
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH) '      Time Constant = ' num2str(extra)   '     Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000)  ] )
        case 13
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH) '      % Gaussian = ' num2str(extra)   '     Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000)  ] )
        case {14,15,22,35}
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH) '      extra = ' num2str(extra)  '     Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000) ] )
        case 28
            xlabel(['Shape = ' ShapeString '      Order = ' num2str(extra)  '     Error = ' num2str(round(1000*LowestError)/1000) '%  R2 = ' num2str(round(1000*LowestError)/1000) ] )
        case 43
            xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '        Error = ' num2str(round(1000*LowestError)/1000) '%   R2 = ' num2str(round(100000*Rsquared)/100000) ] )
         otherwise
            if peakshape(1)==29 % Segmented linear
                xlabel(['Breakpoints = ' num2str(NumPeaks) '     Shape = ' ShapeString  '     Error = ' num2str(round(1000*LowestError)/1000) '%  R2 = ' num2str(round(100000*Rsquared)/100000) ] )
            else
                xlabel(['Peaks = ' num2str(NumPeaks) '     Shape = ' ShapeString '     Min. Width = ' num2str(MINWIDTH)  '     Error = ' num2str(round(1000*LowestError)/1000) '%  R2 = ' num2str(round(100000*Rsquared)/100000) ] )
            end % if peakshape(1)==29
    end % switch peakshape(1)

    % Bottom half of the figure shows the residuals and displays RMS error
    % between original signal and model
    % residual=yy-bestmodel;
    subplot(2,1,2);plot(xx+xoffset,residual,'m.')
    axis([min(xx)+xoffset max(xx)+xoffset min(residual) max(residual)]);
    xlabel('Residual Plot')
    if NumTrials>1
       title(['Best of ' num2str(NumTrials) ' fits'])
    else
       title(['Single fit'])
    end
end % if plots

% Put results into a matrix FitResults, one row for each peak, showing peak index number,
% position, amplitude, and width.
% disp('1664 Put results into a matrix FitResults,')
FitResults=zeros(NumPeaks,6);
% FitParameters1665=FitParameters
switch peakshape(1)
    case {6,7,8,48} % equal-width peak models only
        for m=1:NumPeaks
            if m==1
                FitResults=[[round(m) FitParameters(m)+xoffset height(m) abs(FitParameters(NumPeaks+1)) area(m)]];
            else
                FitResults=[FitResults ; [round(m) FitParameters(m)+xoffset height(m) abs(FitParameters(NumPeaks+1)) area(m)]];
            end
        end
    case {11,12,34,35,36,37} % Fixed-width shapes only
        for m=1:NumPeaks
            width(m)=abs(FitParameters(m));
            if peakshape==34
                gD(m)=width(m);
                gL(m)=extra.*gD(m);
                width(m) = (0.5346*gL(m) + sqrt(0.2166*gL(m).^2 + gD(m).^2));
            end
            if m==1
                FitResults=[[round(m) FitParameters(m)+xoffset height(m) FIXEDPARAMETERS(m) area(m)]];
            else
                FitResults=[FitResults ; [round(m) FitParameters(m)+xoffset height(m) FIXEDPARAMETERS(m) area(m)]];
            end
        end
    case {16,17} % Fixed-position shapes only
        for m=1:NumPeaks
            if m==1
                FitResults=[round(m) FIXEDPARAMETERS(m) height(m) FitParameters(m) area(m)];
            else
                FitResults=[FitResults ; [round(m) FIXEDPARAMETERS(m) height(m) FitParameters(m) area(m)]];
            end
        end
    case 28   % Simple polynomial fit
        FitResults=PEAKHEIGHTS;
    case 29 % Segmented linear fit
        FitResults=PEAKHEIGHTS;
    case {30,31,32,33,38,39,43} % Special case of shapes with 3 iterated variables
        for m=1:NumPeaks
            width(m)=abs(FitParameters(3*m-1));
            if peakshape==30
                gD(m)=width(m);
                gL(m)=FitParameters(3*m).*gD(m);
                width(m) = (0.5346*gL(m) + sqrt(0.2166*gL(m).^2 + gD(m).^2));
            end
           if m==1
                FitResults=[round(m) FitParameters(3*m-2) height(m) width(m) area(m) FitParameters(3*m)];
            else
                FitResults=[FitResults ; [round(m) FitParameters(3*m-2) height(m) width(m) area(m) FitParameters(3*m)]];
           end
        end
    case 49
        for m=1:NumPeaks
            width(m)=abs(FitParameters(4*m-2));
            if m==1
                FitResults=[round(m) FitParameters(4*m-3) height(m) width(m) area(m) FitParameters(4*m)];
            else
                FitResults=[FitResults ; [round(m) FitParameters(4*m-3) height(m) width(m) area(m) FitParameters(4*m)]];
            end
        end
    case 47 % Shapes with 1 iterated variable
         
    otherwise % Normal shapes with 2 iterated variables
        for m=1:NumPeaks
            width(m)=abs(FitParameters(2*m));
            if peakshape==20
                gD=width(m);
                gL=extra.*gD;
                width(m) = (0.535*gL + sqrt(0.2166*gL.^2 + gD.^2));
               
            end
            if m==1
                FitResults=[round(m) FitParameters(2*m-1)+xoffset height(m) width(m) area(m)];
            else
                FitResults=[FitResults ; [round(m) FitParameters(2*m-1)+xoffset height(m) width(m) area(m)]];
            end % if m==1
            
        end % for m=1:NumPeaks
end % switch peakshape(1)

%FitParameters1736=FitParameters
%FitResults1737=FitResults

% Rearrange fit results for PearsonIV to Bo, Kh, and L
if peakshape(1)==43
    for m=1:NumPeaks
        FitResults(m,2)=FitResults(m,2).*FitResults(m,3);
        FitResults(m,4)=FitResults(m,3).*FitResults(m,4);
        FitResults(m,3)=1;
    end
end

% Rearrange fit results CLS (shape 50)
if peakshape(1)==50
    for m=1:NumPeaks
        FitResults(m,2)=FIXEDPARAMETERS(m,2);
        FitResults(m,3)=PEAKHEIGHTS(m);
        FitResults(m,4)=FIXEDPARAMETERS(m,3);
    end
end

%Sort FitResults
FitResults=sortrows(FitResults,2);

% Display Fit Results on lower graph (lower panel)
if plots
    % Display Fit Results on lower  graph
    subplot(2,1,2);
    startx=min(xx)+(max(xx)-min(xx))./20;
    dxx=(max(xx)-min(xx))./10;
    dyy=((max(residual)-min(residual))./10);
    starty=max(residual)-dyy;
    FigureSize=get(gcf,'Position');
    switch peakshape(1)
        case {9,19,10,23,40}  % Pulse and sigmoid shapes only
            text(startx,starty+dyy/2,['Peak #          tau1           Height           tau2             Area'] );
        case 28 % Polynomial
            text(startx,starty+dyy/2,['Polynomial coefficients'] );
        case 29 % Segmented linear
             text(startx,starty+dyy/2,['x-axis breakpoints'] );
        case 20
            text(startx,starty+dyy/2,['Peak #          Position        Height           Width           Area'] );                       
        case {30,34} % Voigt (variable shape)
             text(startx,starty+dyy/2,['Peak #          Position        Height          Width             Area         alpha'] );                       
        case {31,32,33,38} % Special case of shapes with 3 iterated variables
            text(startx,starty+dyy/2,['Peak #          Position        Height          Width               Area        Shape factor'] );            
        case 39 % ExpGaussian2 (variable lambda)
             text(startx,starty+dyy/2,['Peak #          Position        Height         Sigma              Area          lambda'] );                       
        case 43 % 3 parameter Gompertz
            text(startx,starty+dyy/2,['Peak #           a1             Height            a2                Area                 a3'] );            
        case 49
            text(startx,starty+dyy/2,['Peak #         Position        Height          a1              Area             a2      '] );            
            NumColumns=7;
        otherwise
            text(startx,starty+dyy/2,['Peak #          Position         Height         Width             Area   '] );
    end
    % Display FitResults using sprintf
    %plots=plots
    %NumPeaks=NumPeaks
    %peakshape=peakshape
    if peakshape(1)==28||peakshape(1)==29 % Polynomial or segmented linear
        for number=1:length(FitResults)
            column=1;
            itemstring=sprintf('%0.4g',FitResults(number));
            xposition=startx+(1.7.*dxx.*(column-1).*(600./FigureSize(3)));
            yposition=starty-number.*dyy.*(400./FigureSize(4));
            text(xposition,yposition,['                ' itemstring]);
        end
    else
        for peaknumber=1:NumPeaks
%             size(FitResults)
            for column=1:5
%                 peaknumber=peaknumber
%                 column=column
                itemstring=sprintf('%0.4g',FitResults(peaknumber,column));
                % if column==1;disp(itemstring);disp('line 1785');end
                xposition=startx+(1.7.*dxx.*(column-1).*(600./FigureSize(3)));
                yposition=starty-peaknumber.*dyy.*(400./FigureSize(4));
                text(xposition,yposition,itemstring);
            end
        end
        xposition=startx;
        yposition=starty-(peaknumber+1).*dyy.*(400./FigureSize(4));
        if BaselineMode==3
            text(xposition,yposition,[ 'Baseline= ' num2str(baseline) ]);
        end % if BaselineMode
    end % if peakshape(1)
    if peakshape(1)==30 || peakshape(1)==31 || peakshape(1)==32 || peakshape(1)==33 || peakshape(1)==38 || peakshape(1)==39 || peakshape(1)==43 || peakshape(1)==49
        for peaknumber=1:NumPeaks
            column=6;
            itemstring=sprintf('%0.4g',FitParameters(3*peaknumber));
            xposition=startx+(1.7.*dxx.*(column-1).*(600./FigureSize(3)));
            yposition=starty-peaknumber.*dyy.*(400./FigureSize(4));
            text(xposition,yposition,itemstring);
        end
    end
      if peakshape(1)==49 
         for peaknumber=1:NumPeaks
            for column=1:6
                itemstring=sprintf('%0.4g',FitResults(peaknumber,column));
           %     if column==1;itemstring=shapestring;end
                xposition=startx+(1.7.*dxx.*(column-1).*(600./FigureSize(3)));
                yposition=starty-peaknumber.*dyy.*(400./FigureSize(4));
                text(xposition,yposition,itemstring);
            end
         end
       end
end % if plots

if NumArgOut==8
    if plots,disp('Computing bootstrap sampling statistics.....'),end
    BootstrapResultsMatrix=zeros(6,100,NumPeaks);
    BootstrapErrorMatrix=zeros(1,100,NumPeaks);
    clear bx by
    tic;
    for trial=1:100
        n=1;
        bx=xx;
        by=yy;
        while n<length(xx)-1
            if rand>.5
                bx(n)=xx(n+1);
                by(n)=yy(n+1);
            end
            n=n+1;
        end
        bx=bx+xoffset;
        [FitResults,BootFitError]=fitpeaks(bx,by,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,FIXEDPARAMETERS,shapesvector);
        for peak=1:NumPeaks
            switch peakshape(1)
                case {30,31,32,33,38,43}
                    BootstrapResultsMatrix(1:6,trial,peak)=FitResults(peak,1:6);
                otherwise
                    BootstrapResultsMatrix(1:5,trial,peak)=FitResults(peak,1:5);
            end
            BootstrapErrorMatrix(:,trial,peak)=BootFitError;
        end
    end
    if plots,toc;end
    for peak=1:NumPeaks
        if plots
            disp(' ')
            % Label columns for bootstrap results
            switch peakshape(1)
                case {9,19,10,23,40}  % Pulse and sigmoid shapes only
                    disp(['Peak #',num2str(peak) '      tau1     Height        tau2           Area'] );
                case {30,31,32,33,38} % Special case of shapes with 3 iterated variables
                    disp(['Peak #',num2str(peak) '      Position      Height        Width             Area       Shape factor'] );
                case 39
                    text(startx,starty+dyy/2,['Peak #       Position    Height        Sigma             Area          lambda'] );    
                case 43 % 3 parameter Gompertz
                    disp(['Peak #',num2str(peak) '      a1         Height        a2                       a3'] );
                otherwise
                    disp(['Peak #',num2str(peak) '      Position     Height        Width             Area'] );
            end
            
        end % if plots
        BootstrapMean=mean(real(BootstrapResultsMatrix(:,:,peak)'));
        BootstrapSTD=std(BootstrapResultsMatrix(:,:,peak)');
        BootstrapIQR=iqr(BootstrapResultsMatrix(:,:,peak)');
        PercentRSD=100.*BootstrapSTD./BootstrapMean;
        PercentIQR=100.*BootstrapIQR./BootstrapMean;
        BootstrapMean=BootstrapMean(2:6);
        BootstrapSTD=BootstrapSTD(2:6);
        BootstrapIQR=BootstrapIQR(2:6)./1.34896;
        PercentRSD=PercentRSD(2:6);
        PercentIQR=PercentIQR(2:6)./1.34896;
        format short g
        if plots
            disp(['Mean:        ', num2str(BootstrapMean)])
            disp(['STD:         ', num2str(BootstrapSTD)])
            disp(['RSD (IQR):   ', num2str(BootstrapIQR)])
            disp(['% RSD:       ', num2str(PercentRSD) ' %' ])
            disp(['% RSD (IQR): ', num2str(PercentIQR) ' %' ])
        end % if plots
        BootResults(peak,:)=[BootstrapMean BootstrapSTD PercentRSD BootstrapIQR PercentIQR];
    end % peak=1:NumPeaks,
end % if NumArgOut==8,
if BaselineMode==3
else
    baseline=bkgcoef;
end
% ----------------------------------------------------------------------
function [FitResults,LowestError]=fitpeaks(xx,yy,NumPeaks,peakshape,extra,NumTrials,start,BaselineMode,fixedparameters,shapesvector)
% Based on peakfit Version 9.61
start=start%<<<<<<<<<<<<<<<<<<<<<<<<<
global PEAKHEIGHTS FIXEDPARAMETERS BIPOLAR MINWIDTH coeff
format short g
format compact
warning off all
FIXEDPARAMETERS=fixedparameters;
xoffset=0;
if start==0;start=calcstart(xx,NumPeaks,xoffset);end
PEAKHEIGHTS=zeros(1,NumPeaks);
n=length(xx);
newstart=start;
coeff=0;
LOGPLOT=0;

% Perform peak fitting for selected peak shape using fminsearch function
disp('Perform peak fitting for selected peak shape')
options = optimset('TolX',.000001,'Display','off','MaxFunEvals',1000 );
LowestError=1000; % or any big number greater than largest error expected
FitParameters=zeros(1,NumPeaks.*2); 
BestStart=zeros(1,NumPeaks.*2); 
height=zeros(1,NumPeaks); 
bestmodel=zeros(size(yy));
for k=1:NumTrials
    % StartVector=newstart
    switch peakshape(1)
        case 1
            TrialParameters=fminsearch(@(lambda)(fitgaussian(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 2
            TrialParameters=fminsearch(@(lambda)(fitlorentzian(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 3
            TrialParameters=fminsearch(@(lambda)(fitlogistic(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 4
            TrialParameters=fminsearch(@(lambda)(fitpearson(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 5
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[zeros(size(yy)) yy zeros(size(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexpgaussian(lambda,zxx,zyy,-extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 6
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitewgaussian(lambda,xx,yy)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 7
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitewlorentzian(lambda,xx,yy)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 8
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitexpewgaussian(lambda,xx,yy,-extra)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 9
            TrialParameters=fminsearch(@(lambda)(fitexppulse(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 10
            TrialParameters=fminsearch(@(lambda)(fitupsigmoid(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 11
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(FitFWGaussian(lambda,xx,yy)),fixedstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 12
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(FitFWLorentzian(lambda,xx,yy)),fixedstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 13
            TrialParameters=fminsearch(@(lambda)(fitGL(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 14
            TrialParameters=fminsearch(@(lambda)(fitBiGaussian(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 15
            TrialParameters=fminsearch(@(lambda)(fitBWF(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 16
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(FitFPGaussian(lambda,xx,yy)),fixedstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(Peak)<MINWIDTH
                    TrialParameters(Peak)=MINWIDTH;
                end
            end
        case 17
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(FitFPLorentzian(lambda,xx,yy)),fixedstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(Peak)<MINWIDTH
                    TrialParameters(Peak)=MINWIDTH;
                end
            end
        case 18
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[zeros(size(yy)) yy zeros(size(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexplorentzian(lambda,zxx,zyy,-extra)),newstart,options);
        case 19
            TrialParameters=fminsearch(@(lambda)(alphafunction(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 20
            TrialParameters=fminsearch(@(lambda)(fitvoigt(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 21
            TrialParameters=fminsearch(@(lambda)(fittriangular(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 22
            TrialParameters=fminsearch(@(lambda)(fitmultiple(lambda,xx,yy,NumPeaks,shapesvector,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 23
            TrialParameters=fminsearch(@(lambda)(fitdownsigmoid(lambda,xx,yy)),newstart,optionst);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 24
            TrialParameters=fminsearch(@(lambda)(fitnbinpdf(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 25
            TrialParameters=fminsearch(@(lambda)(fitlognpdf(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 26
            TrialParameters=fminsearch(@(lambda)(fitlinslope(lambda,xx,yy)),polyfit(xx,yy,1),options);
        coeff=TrialParameters;
        case 27
            TrialParameters=fminsearch(@(lambda)(fitd1gauss(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 28
            TrialParameters=fitpolynomial(xx,yy,extra);
        case 29
            TrialParameters=fminsearch(@(lambda)(fitsegmented(lambda,xx,yy)),newstart,options);
        case 30
            TrialParameters=fminsearch(@(lambda)(fitvoigtv(lambda,xx,yy)),newstart);
        case 31
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[zeros(size(yy)) yy zeros(size(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexpgaussianv(lambda,zxx,zyy)),newstart);
        case 32
            TrialParameters=fminsearch(@(lambda)(fitpearsonv(lambda,xx,yy)),newstart);
        case 33
            TrialParameters=fminsearch(@(lambda)(fitGLv(lambda,xx,yy)),newstart);
        case 34
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(fitFWVoigt(lambda,xx,yy,extra)),fixedstart,options);
        case 35
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(fitFWGL(lambda,xx,yy,extra)),fixedstart,options);
        case 36
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(fitFWExpGaussian(lambda,xx,yy,extra)),fixedstart,options);
        case 37
            fixedstart=[];
            for pc=1:NumPeaks
                fixedstart(pc)=min(xx)+pc.*(max(xx)-min(xx))./(NumPeaks+1);
            end
            TrialParameters=fminsearch(@(lambda)(fitFWPearson(lambda,xx,yy,extra)),fixedstart,options);
        case 38
            zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
            zyy=[zeros(size(yy)) yy zeros(size(yy)) ];
            TrialParameters=fminsearch(@(lambda)(fitexplorentzianv(lambda,zxx,zyy)),newstart);         
        case 39
%             zxx=[zeros(size(xx)) xx zeros(size(xx)) ];
%             zyy=[zeros(size(yy)) yy zeros(size(yy)) ];
            TrialParameters=fminsearch(@(lambda)(FitExpGaussian2(lambda,xx,yy)),newstart);         
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
  
        case 40
             TrialParameters=fminsearch(@(lambda)(fitsine(lambda,xx,yy)),newstart,options);
        case 41
            TrialParameters=fminsearch(@(lambda)(fitrectangle(lambda,xx,yy)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 42
            TrialParameters=fminsearch(@(lambda)(fitngaussian(lambda,xx,yy,extra)),newstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(2*Peak)<MINWIDTH
                    TrialParameters(2*Peak)=MINWIDTH;
                end
            end
        case 43
            TrialParameters=fminsearch(@(lambda)(fitGompertz(lambda,xx,yy)),newstart);
        case 44
            TrialParameters=fminsearch(@(lambda)(fitOneMinusExp(lambda,xx,yy)),newstart);           
        case 45
            TrialParameters=fminsearch(@(lambda)(fitFourPL(lambda,xx,yy)),newstart);  
        case 46
            TrialParameters=fminsearch(@(lambda)(fitquadslope(lambda,xx,yy)),newstart,options);
        case 47
            bbstart=3000;
            TrialParameters=fminsearch(@(lambda)(fitblackbody(lambda,xx,yy)),bbstart,options);
        case 48
            cwnewstart(1)=newstart(1);
            for pc=2:NumPeaks
                cwnewstart(pc)=newstart(2.*pc-1);
            end
            cwnewstart(NumPeaks+1)=(max(xx)-min(xx))/5;
            TrialParameters=fminsearch(@(lambda)(fitewexpulse(lambda,xx,yy)),cwnewstart,options);
            for Peak=1:NumPeaks
                if TrialParameters(NumPeaks+1)<MINWIDTH
                    TrialParameters(NumPeaks+1)=MINWIDTH;
                end
            end
        case 49
            nn=max(xx)-min(xx);
            start=[];
            startpos=[nn/(NumPeaks+1):nn/(NumPeaks+1):nn-(nn/(NumPeaks+1))]+min(xx);
            for marker=1:NumPeaks
                markx=startpos(marker)+ xoffset;
                start=[start markx nn/6 1 1];
            end % for marker
             newstart=start;
            for element=1:length(start)
                newstart(element)=newstart(element)*(1+randn/100);
            end
            % newstart1233=newstart
            TrialParameters=fminsearch(@(lambda)(fitPearsonIV(lambda,xx,yy)),newstart,options);
        otherwise
    end % switch peakshape
    
for peaks=1:NumPeaks
     peakindex=2*peaks-1;
     newstart(peakindex)=start(peakindex)-xoffset;
end

    % Construct model from Trial parameters
    disp('Construct model from Trial parameters')
    A=zeros(NumPeaks,n);
    for m=1:NumPeaks
        switch peakshape(1)
            case 1
                A(m,:)=gaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 2
                A(m,:)=lorentzian(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 3
                A(m,:)=logistic(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 4
                A(m,:)=pearson(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
            case 5
                A(m,:)=expgaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m),-extra)';
            case 6
                A(m,:)=gaussian(xx,TrialParameters(m),TrialParameters(NumPeaks+1));
            case 7
                A(m,:)=lorentzian(xx,TrialParameters(m),TrialParameters(NumPeaks+1));
            case 8
                A(m,:)=expgaussian(xx,TrialParameters(m),TrialParameters(NumPeaks+1),-extra)';
            case 9
                A(m,:)=exppulse(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 10
                A(m,:)=upsigmoid(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 11
                A(m,:)=gaussian(xx,TrialParameters(m),FIXEDPARAMETERS(m));
            case 12
                A(m,:)=lorentzian(xx,TrialParameters(m),FIXEDPARAMETERS(m));
            case 13
                A(m,:)=GL(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
            case 14
                A(m,:)=BiGaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
            case 15
                A(m,:)=BWF(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
            case 16
                A(m,:)=gaussian(xx,FIXEDPARAMETERS(m),TrialParameters(m));
            case 17
                A(m,:)=lorentzian(xx,FIXEDPARAMETERS(m),TrialParameters(m));
            case 18
                A(m,:)=explorentzian(xx,TrialParameters(2*m-1),TrialParameters(2*m),-extra)';
            case 19
                A(m,:)=alphafunction(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 20
                A(m,:)=voigt(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
            case 21
                A(m,:)=triangular(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 22
                A(m,:)=peakfunction(shapesvector(m),xx,TrialParameters(2*m-1),TrialParameters(2*m),extra(m));
            case 23
                A(m,:)=downsigmoid(xx,TrialParameters(2*m-1),TrialParameters(2*m));      
            case 24
                A(m,:)=nbinpdf(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 25
                A(m,:)=lognormal(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 26
                A(m,:)=linslope(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 27
                A(m,:)=d1gauss(xx,TrialParameters(2*m-1),TrialParameters(2*m));       
            case 28
                A(m,:)=polynomial(xx,TrialParameters(2*m-1),TrialParameters(2*m));       
            case 29
                A(m,:)=segmented(xx,yy,PEAKHEIGHTS);
            case 30
                A(m,:)=voigt(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
            case 31
                A(m,:)=expgaussian(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
            case 32
                A(m,:)=pearson(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
            case 33
                A(m,:)=GL(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));
            case 34
                width(m)=abs(FIXEDPARAMETERS(m));
%                 gD(m)=width(m);
%                 gL(m)=extra.*gD(m);
%                 width(m) = 2.*(0.5346*gL(m) + sqrt(0.2166*gL(m).^2 + gD(m).^2))
                A(m,:)=voigt(xx,TrialParameters(m), width(m),extra);
            case 35
                A(m,:)=GL(xx,TrialParameters(m),FIXEDPARAMETERS(m),extra);
            case 36
                A(m,:)=expgaussian(xx,TrialParameters(m),FIXEDPARAMETERS(m),extra);
            case 37
                A(m,:)=pearson(xx,TrialParameters(m),FIXEDPARAMETERS(m),extra);
            case 38
                A(m,:)=explorentzian(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));                    
            case 39
                A(m,:)=ExpGaussian2(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));                               
            case 40
                A(m,:)=sine(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 41
                A(m,:)=rectangle(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 42
                A(m,:)=ngaussian(xx,TrialParameters(2*m-1),TrialParameters(2*m),extra);
            case 43
                A(m,:)=Gompertz(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));
            case 44
                A(m,:)=OneMinusExp(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 45
                A(m,:)=FourPL(xx,TrialParameters(3*m-2),TrialParameters(3*m-1),TrialParameters(3*m));        
            case 46
                A(m,:)=quadslope(xx,TrialParameters(2*m-1),TrialParameters(2*m));
            case 47
                A(m,:)=blackbody(xx,TrialParameters(m));
            case 48
                A(m,:)=exppulse(xx,TrialParameters(m),TrialParameters(NumPeaks+1));
            case 49
                A(m,:)=PearsonIV(xx,TrialParameters(4*m-3),TrialParameters(4*m-2),TrialParameters(4*m-1),TrialParameters(4*m));
        end % switch
    end % for
    
    % Multiplies each row by the corresponding amplitude and adds them up
    if peakshape(1)==29 % Segmented linear
        model=segmented(xx,yy,PEAKHEIGHTS);
        TrialParameters=coeff;
        Heights=ones(size(coeff));
    else
        if BaselineMode==3
            baseline=PEAKHEIGHTS(1);
            Heights=PEAKHEIGHTS(2:1+NumPeaks);
            model=Heights'*A+baseline;
        else
            model=PEAKHEIGHTS'*A;
            Heights=PEAKHEIGHTS;
            baseline=0;
        end
    end
    
    % Compare trial model to data segment and compute the fit error
    MeanFitError=100*norm(yy-model)./(sqrt(n)*max(yy));
    % Take only the single fit that has the lowest MeanFitError
    if MeanFitError<LowestError
        if min(Heights)>=-BIPOLAR*10^100  % Consider only fits with positive peak heights
            LowestError=MeanFitError;  % Assign LowestError to the lowest MeanFitError
            FitParameters=TrialParameters;  % Assign FitParameters to the fit with the lowest MeanFitError
            height=Heights; % Assign height to the PEAKHEIGHTS with the lowest MeanFitError
        end % if min(PEAKHEIGHTS)>0
    end % if MeanFitError<LowestError
end % for k (NumTrials)
    Rsquared=1-(norm(yy-bestmodel)./norm(yy-mean(yy)));
    SStot=sum((yy-mean(yy)).^2);
    SSres=sum((yy-bestmodel).^2);
    Rsquared=1-(SSres./SStot);
    GOF=[LowestError Rsquared];
for m=1:NumPeaks
    area(m)=trapz(xx+xoffset,height(m)*A(m,:)); % Compute the area of each component peak using trapezoidal method
end

% Put results into a matrix FitResults, one row for each peak, showing peak index number,
% position, amplitude, and width.
disp('2419 Put results into a matrix FitResults')
FitResults=zeros(NumPeaks,6);
switch peakshape(1)
    case {6,7,8} % equal-width peak models only
        for m=1:NumPeaks
            if m==1
                FitResults=[[round(m) FitParameters(m)+xoffset height(m) abs(FitParameters(NumPeaks+1)) area(m)]];
            else
                FitResults=[FitResults ; [round(m) FitParameters(m)+xoffset height(m) abs(FitParameters(NumPeaks+1)) area(m)]];
            end
        end
    case {11,12,35,36,37} % Fixed-width shapes only
        for m=1:NumPeaks
            if m==1
                FitResults=[[round(m) FitParameters(m)+xoffset height(m) FIXEDPARAMETERS(m) area(m)]];
            else
                FitResults=[FitResults ; [round(m) FitParameters(m)+xoffset height(m) FIXEDPARAMETERS(m) area(m)]];
            end
        end

    case {16,17} % Fixed-position shapes only
        for m=1:NumPeaks
            if m==1
                FitResults=[round(m) FIXEDPARAMETERS(m) height(m) FitParameters(m) area(m)];
            else
                FitResults=[FitResults ; [round(m) FIXEDPARAMETERS(m) height(m) FitParameters(m) area(m)]];
            end
        end
    case 28   % Simple polynomial fit
        FitResults=PEAKHEIGHTS;
    case 29 % Segmented linear fit
        FitResults=PEAKHEIGHTS;
    case {30,31,32,33,38,39,43} % Special case of shapes with 3 iterated variables
        for m=1:NumPeaks
            width(m)=abs(FitParameters(3*m-1));
%             if peakshape==30, % shape 30 =  Variable alpha Voigt
%                 gD(m)=width(m);
%                 gL(m)=FitParameters(3*m).*gD(m);
%                 width(m) = 2.*(0.5346*gL(m) + sqrt(0.2166*gL(m).^2 + gD(m).^2));
%           end
            if m==1
                FitResults=[round(m) FitParameters(3*m-2) height(m) width(m) area(m) FitParameters(3*m)];
            else
                FitResults=[FitResults ; [round(m) FitParameters(3*m-2) height(m) width(m) area(m) FitParameters(3*m)]];
            end
        end
    case 49
        disp('case 49')
        for m=1:NumPeaks
            if m==1
                FitResults=[round(m)  FitParameters(4*m-3) FitParameters(4*m-2) height(m) abs(FitParameters(4*m-1)) area(m) FitParameters(4*m)];
            else
                FitResults=[FitResults ; [round(m) FitParameters(4*m-3) FitParameters(4*m-2) height(m) abs(FitParameters(4*m-1)) area(m) FitParameters(4*m)]];
            end
        end
    otherwise % Normal shapes with 2 iterated variables
        for m=1:NumPeaks
            width(m)=abs(FitParameters(2*m));
            if peakshape==20  % shape 20 =  Equal alpha Voigt
                gD=width(m);
                gL=extra.*gD;
                width(m) = (0.535*gL + sqrt(0.2166*gL.^2 + gD.^2));
            end
            if m==1
                FitResults=[round(m) FitParameters(2*m-1)+xoffset height(m) width(m) area(m)];
            else
                FitResults=[FitResults ; [round(m) FitParameters(2*m-1)+xoffset height(m) width(m) area(m)]];
            end % if m==1
        end % for m=1:NumPeaks
end % switch peakshape(1)
if peakshape==34 % Fixed-width Voigt
        DW=2*(0.5346*a*1.2772 + sqrt(0.2166*a*1.2772.^2 + 1.2772.^2))
end
% FIXEDPARAMETERS=FIXEDPARAMETERS
% fixedperameters=fixedperameters
FitParameters2494=FitParameters
FitResults2495=FitResults
% ----------------------------------------------------------------------
function start=calcstart(xx,NumPeaks,xoffset)
  n=max(xx)-min(xx);
  start=[];
  startpos=[n/(NumPeaks+1):n/(NumPeaks+1):n-(n/(NumPeaks+1))]+min(xx);
  for marker=1:NumPeaks
      markx=startpos(marker)+ xoffset;
      start=[start markx n/ (3.*NumPeaks)];
  end % for marker
% ----------------------------------------------------------------------
function [index,closestval]=val2ind(x,val)
% Returns the index and the value of the element of vector x that is closest to val
% If more than one element is equally close, returns vectors of indicies and values
% Tom O'Haver (toh@umd.edu) October 2006
% Examples: If x=[1 2 4 3 5 9 6 4 5 3 1], then val2ind(x,6)=7 and val2ind(x,5.1)=[5 9]
% [indices values]=val2ind(x,3.3) returns indices = [4 10] and values = [3 3]
dif=abs(x-val);
index=find((dif-min(dif))==0);
closestval=x(index);
% ----------------------------------------------------------------------
function err = fitgaussian(lambda,t,y)
% Fitting function for multiple Gaussian peaks.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
numpeaks=round(length(lambda)/2);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
%    if lambda(2*j)<MINWIDTH,lambda(2*j)=MINWIDTH;end
    A(:,j) = gaussian(t,lambda(2*j-1),lambda(2*j))';
end 
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitngaussian(lambda,t,y,shapeconstant)
%   Fitting functions for multiple flattened Gaussian peaks.
% T. C. O'Haver (toh@umd.edu),   Version 1.3, October 23, 2006.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = ngaussian(t,lambda(2*j-1),lambda(2*j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitewgaussian(lambda,t,y)
% Fitting function for multiple Gaussian peaks with equal peak widths.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
numpeaks=round(length(lambda)-1);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = gaussian(t,lambda(j),lambda(numpeaks+1))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = FitFWGaussian(lambda,t,y)
%	Fitting function for multiple fixed width Gaussians
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = gaussian(t,lambda(j),FIXEDPARAMETERS(j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = FitFPGaussian(lambda,t,y)
%	Fitting function for multiple fixed-position Gaussians
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = gaussian(t,FIXEDPARAMETERS(j), lambda(j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = FitFPLorentzian(lambda,t,y)
%	Fitting function for multiple fixed-position Lorentzians
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = lorentzian(t,FIXEDPARAMETERS(j), lambda(j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
err = norm(z-y');
% ----------------------------------------------------------------------
function err = FitFWLorentzian(lambda,t,y)
%	Fitting function for multiple fixed width Lorentzians
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = lorentzian(t,lambda(j),FIXEDPARAMETERS(j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitewlorentzian(lambda,t,y)
% Fitting function for multiple  Lorentzian band signal with equal peak widths.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
numpeaks=round(length(lambda)-1);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = lorentzian(t,lambda(j),lambda(numpeaks+1))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = gaussian(x,pos,wid)
%  gaussian(X,pos,wid) = gaussian peak centered on pos, half-width=wid
%  X may be scalar, vector, or matrix, pos and wid both scalar
% Examples: gaussian([0 1 2],1,2) gives result [0.5000    1.0000    0.5000]
% plot(gaussian([1:100],50,20)) displays gaussian band centered at 50 with width 20.
g = exp(-((x-pos)./(0.60056120439323.*wid)).^2);
% ----------------------------------------------------------------------
function g = ngaussian(x,pos,wid,n)
%  ngaussian(x,pos,wid) = flattened Gaussian centered on x=pos, half-width=wid
%  x may be scalar, vector, or matrix, pos and wid both scalar
% Shape is Gaussian when n=1. Becomes more rectangular as n increases.
%  T. C. O'Haver, 1988, revised 2014
% Example: ngaussian([1 2 3],1,2,1) gives result [1.0000    0.5000    0.0625]
if n>0
    g = 1-(10.^-(n.*gaussian(x,pos,wid)));
    g=g./max(g);
else
    g = gaussian(x,pos,wid);
end
% ----------------------------------------------------------------------
function err = fitlorentzian(lambda,t,y)
%	Fitting function for multiple lorentzians, lambda(1)=position, lambda(2)=width
%	Fitgauss assumes a lorentzian function 
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = lorentzian(t,lambda(2*j-1),lambda(2*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% [lambda PEAKHEIGHTS err]
% ----------------------------------------------------------------------
function g = lorentzian(x,position,width)
% lorentzian(x,position,width) Lorentzian function.
% where x may be scalar, vector, or matrix
% position and width scalar
% T. C. O'Haver, 1988
% Example: lorentzian([1 2 3],2,2) gives result [0.5 1 0.5]
g=ones(size(x))./(1+((x-position)./(0.5.*width)).^2);
% ----------------------------------------------------------------------
function err = fitlogistic(lambda,t,y)
%	Fitting function for multiple logistic peaks, lambda(1)=position, lambda(2)=width
%	between the data and the values computed by the current
%	function of lambda.  Fitlogistic assumes a logistic function 
%  T. C. O'Haver, May 2006
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = logistic(t,lambda(2*j-1),lambda(2*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = logistic(x,pos,wid)
% logistic function.  pos=position; wid=half-width (both scalar)
% logistic(x,pos,wid), where x may be scalar, vector, or matrix
% pos=position; wid=half-width (both scalar)
% T. C. O'Haver, 1991 
n = exp(-((x-pos)/(.477.*wid)) .^2);
g = (2.*n)./(1+n);
% ----------------------------------------------------------------------
function err = fittriangular(lambda,t,y)
%	Fitting function for multiple triangular, lambda(1)=position, lambda(2)=width
%	between the data and the values computed by the current
%	function of lambda.  Fittriangular assumes a triangular function 
%  T. C. O'Haver, May 2006
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = triangular(t,lambda(2*j-1),lambda(2*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = triangular(x,pos,wid)
%Triangle function.  pos=position; wid=half-width (both scalar)
%trianglar(x,pos,wid), where x may be scalar or vector,
%pos=position; wid=half-width (both scalar)
% T. C. O'Haver, 1991
% Example
% x=[0:.1:10];plot(x,trianglar(x,5.5,2.3),'.')
g=1-(1./wid) .*abs(x-pos);
for i=1:length(x)
if g(i)<0,g(i)=0;end
end
% ----------------------------------------------------------------------
function err = fitrectangle(lambda,t,y)
%	Fitting function for multiple rectangle, lambda(1)=position, lambda(2)=width
%	between the data and the values computed by the current
%	function of lambda.  Fitrectangle assumes a rectangle function 
%  T. C. O'Haver, May 2016
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = rectangle(t,lambda(2*j-1),lambda(2*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = rectangle(x,pos,wid)
%rectangle function.  pos=position; wid=half-width (both scalar)
%rectangle(x,pos,wid), where x may be scalar or vector,
%pos=position; wid=half-width (both scalar)
% T. C. O'Haver, 2016
% Example
% x=[0:.1:10];plot(x,rectangle(x,5.5,2.3),'.')
g=zeros(size(x));
hw=wid./2;
for i=1:length(x)
if x(i)<pos-hw,g(i)=0;end
if x(i)>pos-hw,g(i)=1;end
if x(i)>pos+hw,g(i)=0;end
end
% ----------------------------------------------------------------------
function err = fitpearson(lambda,t,y,shapeconstant)
%   Fitting functions for multiple Pearson 7 bands.
% T. C. O'Haver (toh@umd.edu),   Version 1.3, October 23, 2006.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = pearson(t,lambda(2*j-1),lambda(2*j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitpearsonv(lambda,t,y)
% Fitting functions for multiple pearson functions with independently variable
% percent Gaussian
% T. C. O'Haver (toh@umd.edu), 2015.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3
    A(:,j) = pearson(t,lambda(3*j-2),lambda(3*j-1),lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitFWPearson(lambda,t,y,shapeconstant)
%	Fitting function for multiple fixed width Pearson7
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = pearson(t,lambda(j),FIXEDPARAMETERS(j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = pearson(x,pos,wid,m)
% Pearson VII function. 
% g = pearson(x,pos,wid,m) where x may be scalar, vector, or matrix
% pos=position; wid=half-width (both scalar)
% m=some number
%  T. C. O'Haver, 1990  
g=ones(size(x))./(1+((x-pos)./((0.5.^(2/m)).*wid)).^2).^m;
% ----------------------------------------------------------------------
function err = fitexpgaussian(lambda,t,y,timeconstant)
%   Fitting functions for multiple exponentially-convoluted Gaussian bands signal.
%  T. C. O'Haver, October 23, 2006.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = expgaussian(t,lambda(2*j-1),lambda(2*j),timeconstant);
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = FitExpGaussian2(lambda,t,y)
%   Fitting functions for multiple exponentially-modified Gaussian bands signal.
%  T. C. O'Haver, May 21, 2017.
% Same shape as expgaussian except parameterized differently
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3
    A(:,j) = ExpGaussian2(t,lambda(3*j-2),lambda(3*j-1),lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% lambda
% plot(t,y,t,z);drawnow
% ----------------------------------------------------------------------
function err = fitexplorentzian(lambda,t,y,timeconstant)
%   Fitting functions for multiple exponentially-broadened lorentzian band signal.
%  T. C. O'Haver, 2013.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = explorentzian(t,lambda(2*j-1),lambda(2*j),timeconstant);
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitexplorentzianv(lambda,t,y)
% Fitting functions for multiple exponentially-broadened Gaussians with
% independently variable time constants
% T. C. O'Haver (toh@umd.edu), 2015.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3,
    A(:,j) = explorentzian(t,lambda(3*j-2),lambda(3*j-1),-lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitexpewgaussian(lambda,t,y,timeconstant)
% Fitting function for multiple exponentially-broadened Gaussian bands with equal peak widths.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
numpeaks=round(length(lambda)-1);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks,
    A(:,j) = expgaussian(t,lambda(j),lambda(numpeaks+1),timeconstant);
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitexpgaussianv(lambda,t,y)
% Fitting functions for multiple exponentially-broadened Gaussians with
% independently variable time constants
% T. C. O'Haver (toh@umd.edu), 2015.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3,
    A(:,j) = expgaussian(t,lambda(3*j-2),lambda(3*j-1),-lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitFWExpGaussian(lambda,t,y,shapeconstant)
%	Fitting function for multiple fixed width exponentially-broadened gaussian
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks,
    A(:,j) = expgaussian(t,lambda(j),FIXEDPARAMETERS(j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = expgaussian(x,pos,wid,timeconstant)
%  Exponentially-convoluted gaussian(x,pos,wid) = gaussian peak centered on pos, half-width=wid
%  x may be scalar, vector, or matrix, pos and wid both scalar
%  T. C. O'Haver, 2006
g = exp(-((x-pos)./(0.60056120439323.*wid)) .^2);
g = ExpBroaden(g',timeconstant);
% ----------------------------------------------------------------------
function emg=ExpGaussian2(t,mu,s,lambda)
%   Fitting functions for multiple exponentially-modified Gaussian bands signal.
%  T. C. O'Haver, May 21, 2017.
% Same shape as expgaussian except parameterized differently
%if tau~=0,
%    lambda=1/tau;
% disp([mu,s,lambda]) % <<<<<<<<<<<<<<<<<<<<
    EMG=s.*lambda.*sqrt(pi/2).*exp(0.5.*(s.*lambda).^2-lambda.*(t-mu)).*erfc((1/sqrt(2)).*(s.*lambda-((t-mu)./s)));
    emg=EMG./max(EMG);
%end
% ----------------------------------------------------------------------
function g = explorentzian(x,pos,wid,timeconstant)
%  Exponentially-broadened lorentzian(x,pos,wid) = lorentzian peak centered on pos, half-width=wid
%  x may be scalar, vector, or matrix, pos and wid both scalar
%  T. C. O'Haver, 2013
g = ones(size(x))./(1+((x-pos)./(0.5.*wid)).^2);
g = ExpBroaden(g',timeconstant);
% ----------------------------------------------------------------------
function yb = ExpBroaden(y,t)
% ExpBroaden(y,t) zero pads y and convolutes result by an exponential decay
% of time constant t by multiplying Fourier transforms and inverse
% transforming the result.
hly=round(length(y)./2);
ey=[y(1).*ones(1,hly)';y;y(length(y)).*ones(1,hly)'];
fy=fft(ey);
a=exp(-(1:length(fy))./t);
fa=fft(a);
fy1=fy.*fa';
ybz=real(ifft(fy1))./sum(a);
yb=ybz(hly+2:length(ybz)-hly+1);
% ----------------------------------------------------------------------
function err = fitexppulse(tau,x,y)
% Iterative fit of the sum of exponential pulses
% of the form Height.*exp(-tau1.*x).*(1-exp(-tau2.*x)))
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2,
    A(:,j) = exppulse(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitewexpulse(lambda,t,y)
% Fitting function for multiple Gaussian peaks with equal peak widths.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
numpeaks=round(length(lambda)-1);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks,
    A(:,j) = exppulse(t,lambda(j),lambda(numpeaks+1))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = exppulse(x,t1,t2)
% Exponential pulse of the form 
% g = (x-spoint)./pos.*exp(1-(x-spoint)./pos);
e=(x-t1)./t2;
p = 4*exp(-e).*(1-exp(-e));
p=p .* (p>0);
g = p';
% ----------------------------------------------------------------------
function err = fitalphafunction(tau,x,y)
% Iterative fit of the sum of alpha funciton
% of the form Height.*exp(-tau1.*x).*(1-exp(-tau2.*x)))
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2,
    A(:,j) = alphafunction(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = alphafunction(x,pos,spoint)
% alpha function.  pos=position; wid=half-width (both scalar)
% alphafunction(x,pos,wid), where x may be scalar, vector, or matrix
% pos=position; wid=half-width (both scalar)
% Taekyung Kwon, July 2013  
g = (x-spoint)./pos.*exp(1-(x-spoint)./pos);
for m=1:length(x);if g(m)<0;g(m)=0;end;end
% ----------------------------------------------------------------------
function err = fitdownsigmoid(tau,x,y)
% Fitting function for iterative fit to the sum of multiple
% downward moving sigmiods 
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2,
    A(:,j) = downsigmoid(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitupsigmoid(tau,x,y)
% Fitting function for iterative fit to the sum of multiple
% upwards moving sigmiods
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2,
    A(:,j) = upsigmoid(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g=downsigmoid(x,t1,t2)
 % down step sigmoid
g=.5-.5*erf(real((x-t1)/sqrt(2*t2)));
% ----------------------------------------------------------------------
function g=upsigmoid(x,t1,t2)
% up step sigmoid
g=1/2 + 1/2* erf(real((x-t1)/sqrt(2*t2))); 
% ----------------------------------------------------------------------
function err = fitGL(lambda,t,y,shapeconstant)
%   Fitting functions for multiple Gaussian/Lorentzian blend peaks
% T. C. O'Haver (toh@umd.edu), 2012.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2,
    A(:,j) = GL(t,lambda(2*j-1),lambda(2*j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitFWGL(lambda,t,y,shapeconstant)
%	Fitting function for a multiple fixed width Gaussian/Lorentzian blend
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
A = zeros(length(t),numpeaks);
for j = 1:numpeaks,
    A(:,j) = GL(t,lambda(j),FIXEDPARAMETERS(j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitGLv(lambda,t,y)
% Fitting functions for multiple Gaussian/Lorentzian blend functions with
% independently variable percent Gaussian
% T. C. O'Haver (toh@umd.edu), 2015.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3,
    A(:,j) = GL(t,lambda(3*j-2),lambda(3*j-1),lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = GL(x,pos,wid,m)
% Gaussian/Lorentzian blend. m = percent Gaussian character
% pos=position; wid=half-width
% m = percent Gaussian character.
%  T. C. O'Haver, 2012
% sizex=size(x)
% sizepos=size(pos)
% sizewid=size(wid)
% sizem=size(m)
g=2.*((m/100).*gaussian(x,pos,wid)+(1-(m(1)/100)).*lorentzian(x,pos,wid))/2;
% ----------------------------------------------------------------------
function err = fitvoigt(lambda,t,y,shapeconstant)
% Fitting functions for multiple Voigt profile function. Returns 6 columns in the order
% disp('Peak #          Position        Height        Width          Area')
% T. C. O'Haver (toh@umd.edu), 2013.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = voigt(t,lambda(2*j-1),lambda(2*j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitFWVoigt(lambda,t,y,shapeconstant)
%	Fitting function for multiple fixed width Voigt. Returns 6 columns in the order
% disp('Peak #          Position        Height        Width          Area')
global PEAKHEIGHTS BaselineMode FIXEDPARAMETERS BIPOLAR LOGPLOT
numpeaks=round(length(lambda));
% numpeaksfitFWVoigt=numpeaks
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = voigt(t,lambda(j),FIXEDPARAMETERS(j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitvoigtv(lambda,t,y)
% Fitting functions for multiple Voigt profile function with independently variable
% gaussian and lorentzian widths. Returns 6 columns in the order
% disp('Peak #          Position        Height        Width          Area')
% T. C. O'Haver (toh@umd.edu), 2015.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3
    A(:,j) = voigt(t,lambda(3*j-2),lambda(3*j-1),lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function v=voigt(x,pos,Gausswidth,voigtalpha)
% Unit height Voigt profile function. x is the independent variable
% (energy, wavelength, etc), Gausswidth is the Gaussian(Doppler) width,
% and voigtalpha is ratio of the Gausswidth to the LorentzWidth (pressure
% width). Version 3, August, 2019
LorentzWidth=Gausswidth.*voigtalpha;
if LorentzWidth<0, LorentzWidth=-LorentzWidth;end
if Gausswidth<0, Gausswidth=-Gausswidth;end
dx=x(2)-x(1); % x increment
ex=[x-max(x)-dx x x+max(x)]; % Extended x
gau=gaussian(ex,0,Gausswidth);
lor=lorentzian(ex,pos,LorentzWidth);
VoigtConv=ifft(fft(gau).*fft(lor))./sum(lor);
g=VoigtConv./max(VoigtConv);
oex=ex-max(x);
outrange=val2ind(oex,0):val2ind(oex,max(x))-dx;
% minoutrange=min(outrange)
% maxoutrange=max(outrange)
v=g(outrange+1);
% ----------------------------------------------------------------------
function err = fitBiGaussian(lambda,t,y,shapeconstant)
%   Fitting functions for multiple BiGaussian.
% T. C. O'Haver (toh@umd.edu),  2012.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = BiGaussian(t,lambda(2*j-1),lambda(2*j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = BiGaussian(x,pos,wid,m)
% BiGaussian (different width on leading edge and trailing edge).
% pos=position; wid=width 
% m = ratio of widths of right-hand to left-hand halves.
% If m=1, it becomes identical to a Gaussian.
% Verison 2, T. C. O'Haver, 2012
% Example: Plots Gaussian and BiGaussian with m=3, both with halfwidth=20.
% x=[1:100];
% g=gaussian(x,50,20);
% bg=bigaussian(x,50,20,3);
% plot(x,g,x,bg)
%
lx=length(x);
hx=val2ind(x,pos);
hwid=2.*wid;
g(1:hx)=gaussian(x(1:hx),pos,hwid/(m+1));
g(hx+1:lx)=gaussian(x(hx+1:lx),pos,m.*hwid/(m+1));
% ----------------------------------------------------------------------
function err = fitBWF(lambda,t,y,shapeconstant)
%   Fitting function for multiple Breit-Wigner-Fano.
% T. C. O'Haver (toh@umd.edu),  2014.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = BWF(t,lambda(2*j-1),lambda(2*j),shapeconstant)';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = BWF(x,pos,wid,m)
% BWF (Breit-Wigner-Fano) http://en.wikipedia.org/wiki/Fano_resonance
% pos=position; wid=width; m=Fano factor
%  T. C. O'Haver, 2014
y=((m*wid/2+x-pos).^2)./(((wid/2).^2)+(x-pos).^2);
% y=((1+(x-pos./(m.*wid))).^2)./(1+((x-pos)./wid).^2);
g=y./max(y);
% ----------------------------------------------------------------------
function err = fitnbinpdf(tau,x,y)
% Fitting function for iterative fit to the sum of multiple
% Negative Binomial Distributions
% (http://www.mathworks.com/help/stats/negative-binomial-distribution.html)
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2
    A(:,j) = nbinpdf(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitlognpdf(tau,x,y)
% Fitting function for iterative fit to the sum of multiple
% Lognormal Distributions
% (http://www.mathworks.com/help/stats/lognormal-distribution.html)
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2
    A(:,j) = lognormal(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g = lognormal(x,pos,wid)
% lognormal function.  pos=position; wid=half-width (both scalar)
% lognormal(x,pos,wid), where x may be scalar, vector, or matrix
% pos=position; wid=half-width (both scalar)
% T. C. O'Haver, 1991  
g = exp(-(log(x/pos)/(0.01.*wid)) .^2);
% ----------------------------------------------------------------------
function err = fitsine(tau,x,y)
% Fitting function for iterative fit to the sum of multiple
% sine waves (alpha test, NRFPT)
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2
    A(:,j) = sine(x,tau(2*j-1),tau(2*j));
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function g=sine(t,f,phase) 
% Sine wave (alpha test)
g=sin(2*pi*f*(t+phase));
% ----------------------------------------------------------------------
function err = fitd1gauss(lambda,t,y)
%   Fitting functions for multiple first derivative of a Gaussian
%  T. C. O'Haver, 2014
global PEAKHEIGHTS BaselineMode BIPOLAR
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = d1gauss(t,lambda(2*j-1),lambda(2*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
err = norm(z-y');
% ----------------------------------------------------------------------
function y=d1gauss(x,p,w)
% First derivative of Gaussian (alpha test)
y=-(5.54518.*(x-p).*exp(-(2.77259.*(p-x).^2)./w^2))./w.^2;
y=y./max(y);
% ----------------------------------------------------------------------
function coeff = fitpolynomial(t,y,order)
coeff=polyfit(t,y,order);
% order=order
% coeff=coeff
% ----------------------------------------------------------------------
function y=polynomial(t,coeff)
y=polyval(coeff,t);
% ----------------------------------------------------------------------
function err = fitsegmented(lambda,t,y)
%   Fitting functions for articulated segmented linear
%  T. C. O'Haver, 2014
global LOGPLOT
breakpoints=[t(1) lambda max(t)];
z = segmented(t,y,breakpoints);
% lengthz=length(z);
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y);
end
% ----------------------------------------------------------------------
function yi=segmented(x,y,segs)
global PEAKHEIGHTS
clear yy
for n=1:length(segs)
  yind=val2ind(x,segs(n));
  yy(n)=y(yind(1));
end
yi=interp1(segs,yy,x);
PEAKHEIGHTS=segs;
% ----------------------------------------------------------------------
function err = fitlinslope(tau,x,y)
% Fitting function for iterative fit to linear function
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(x),round(length(tau)/2));
for j = 1:length(tau)/2
    z = (x.*tau(2*j-1)+tau(2*j))';
    A(:,j) = z./max(z);
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function y=linslope(x,slope,intercept)
y=x.*slope+intercept;
% y=y./max(y);
% ----------------------------------------------------------------------
function err = fitquadslope(lambda,x,y)
% Fitting function for iterative fit to linear function
global PEAKHEIGHTS LOGPLOT
A = zeros(length(x),round(length(lambda)/2));
for j = 1:length(lambda)/2
     A(:,j)=quadslope(x,lambda(1),lambda(2));
end
PEAKHEIGHTS=A\y';
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function y=quadslope(x,boa,coa) % normalized quadratic
 y=(x.^2+(boa).*x+coa);
y=y./max(y);
% ----------------------------------------------------------------------
function err = fitPearsonIV(lambda,t,y)
% Fitting functions for multiple PearsonIV function
% T. C. O'Haver (toh@umd.edu), 2016.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/4));
for j = 1:length(lambda)/4
    A(:,j) = PearsonIV(t,lambda(4*j-3),lambda(4*j-2),lambda(4*j-1),lambda(4*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
% sizeA=size(A)
% sizedenom=size(y')
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
% PEAKHEIGHTS=1;
% SizeA=size(A)
% sizePEAKHEIGHTS=size(PEAKHEIGHTS)
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function y = PearsonIV(x,a1,a2,a3,a4)
% Unit-height Pearson IV probability distrubtion function as described by
% the list of functions from PeakFit(TM) software documentation on page 261.
% Suggested by Chris George. Code by T. C. O'Haver, 2021
% Example:
% x=1:.1:10;y=PearsonIV(x,6,3,4,2);plot(x,y)
%
num=(x-((a2.*a4)./(2.*a3))-a1);
y=(((1+num.^2./a2.^2).^-a3) .* exp(-a4.*(atan(num./a2)+atan(a4./(2.*a3))))) ./ (1+((a4.^2)./(4.*a3.^2))).^-a3;
y=y./max(y);
% ----------------------------------------------------------------------
function y=Gompertz(t,Bo,Kh,L)
% A Gompertz curve or Gompertz function, named after Benjamin Gompertz, is
% a sigmoid function. It is a type of mathematical model for a time series,
% where growth is slowest at the start and end of a time period. The
% right-hand or future value asymptote of the function is approached much
% more gradually by the curve than the left-hand or lower valued asymptote,
% in contrast to the simple logistic function in which both asymptotes are
% approached by the curve symmetrically. It is a special case of the
% generalized logistic function.
% 
% Example:
% x=1:.1:10;y=gompertz(x,6,3,4);plot(x,y)
%
y=Bo*exp(-exp((Kh*exp(1)/Bo)*(L-t) +1));
% ----------------------------------------------------------------------
function err = fitFourPL(lambda,t,y)
% Fitting functions for  four parameters logistic
% T. C. O'Haver (toh@umd.edu), 2016.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT
A = zeros(length(t),round(length(lambda)/3));
for j = 1:length(lambda)/3
    A(:,j) = FourPL(t,lambda(3*j-2),lambda(3*j-1),lambda(3*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
PEAKHEIGHTS=1;
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function y=FourPL(x,miny,slope,ip)
% Normalized four parameters logistic   
% https://psg.hitachi-solutions.com/masterplex/blog/the-4-parameter-logisti
% c-4pl-nonlinear-regression-model
% miny = minimum asymptote. In an ELISA assay where you have a standard
% curve, this can be thought of as the response value at 0 standard
% concentration. slope = Hill slope. The Hill Slope or slope factor refers
% to the steepness of the curve. It could either be positive or negative.
% As the absolute value of the Hill slope increases, so does the steepness
% of the curve. ip = inflection point: The inflection point is defined as the
% point on the curve where the curvature changes direction or signs. This
% can be better explained if you can imagine the concavity of a sigmoidal
% curve. The inflection point is where the curve changes from being concave
% upwards to concave downwards. maxy = maximum asymptote. In an ELISA assay
% where you have a standard curve, this can be thought of as the response
% value for infinite standard concentration.
% Example:
% x=0:20;
% miny=0;slope=5;ip=10;d=0;maxy=10;
% y=FourPL(x,miny,slope,ip,maxy);plot(x,y)
%
y = 1+(miny-1)./(1+(x./ip).^slope);
% ----------------------------------------------------------------------
function err = fitOneMinusExp(lambda,t,y)
%   Fitting functions for multiple first derivative of a Gaussian
%  T. C. O'Haver, 2014
global PEAKHEIGHTS BaselineMode BIPOLAR
A = zeros(length(t),round(length(lambda)/2));
for j = 1:length(lambda)/2
    A(:,j) = OneMinusExp(t,lambda(2*j-1),lambda(2*j))';
end
if BaselineMode==3,A=[ones(size(y))' A];end
if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
z = A*PEAKHEIGHTS;
err = norm(z-y');
% ----------------------------------------------------------------------
function g = OneMinusExp(x,pos,wid)
% OneMinusExp(x,pos,wid) = 1-exp(-wid.*(x-pos));
% Example:  x=0:10;y=1-exp(-(.5.*x));plot(x,y)
g = 1-exp(-wid.*(x-pos));
% ----------------------------------------------------------------------
function err = fitblackbody(lambda,wavelength,y)
%  Fitting function for a blackbody spectrum.
%  T. C. O'Haver, May 2008
global PEAKHEIGHTS BaselineMode BIPOLAR
% sizelambda=size(lambda)
radiance = blackbody(wavelength,lambda(1));
% if BaselineMode==3,A=[ones(size(y))' A];end
% if BIPOLAR,PEAKHEIGHTS=A\y';else PEAKHEIGHTS=abs(A\y');end
% sizePEAKHEIGHTS=size(PEAKHEIGHTS)
% sizey=size(y)
PEAKHEIGHTS = radiance/y;
z = radiance*PEAKHEIGHTS;
err = norm(z-y);
% ----------------------------------------------------------------------
function radiance=blackbody(wavelength,temperature)
radiance = 1.19111E+16*wavelength.^(-5)./(exp(14380000./(wavelength*temperature))-1);
% ----------------------------------------------------------------------

% ----------------------------------------------------------------------
function err = fitFHgaussian(lambda,t,y)
% Fitting function for a fixed-height Gaussian band signal.
global PEAKHEIGHTS BaselineMode LOGPLOT FIXEDPARAMETERS
numpeaks=round(length(lambda)/2);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = gaussian(t,lambda(2*j-1),lambda(2*j))';
end 
if BaselineMode==3,A=[ones(size(y))' A];end
PEAKHEIGHTS=FIXEDPARAMETERS';
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function err = fitFHLorentzian(lambda,t,y)
% Fitting function for a fixed-height Gaussian band signal.
global PEAKHEIGHTS BaselineMode LOGPLOT FIXEDPARAMETERS
numpeaks=round(length(lambda)/2);
A = zeros(length(t),numpeaks);
for j = 1:numpeaks
    A(:,j) = gaussian(t,lambda(2*j-1),lambda(2*j))';
end 
if BaselineMode==3,A=[ones(size(y))' A];end
PEAKHEIGHTS=FIXEDPARAMETERS';
z = A*PEAKHEIGHTS;
if LOGPLOT
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function b=iqr(a)
% b = IQR(a) returns the interquartile range divided by 1.34896, of the
% values in a. If a is a vector, b is the difference between the 75th and
% 25th percentiles of a, divided by 1.34896. If b is a matrix, b is a row
% vector containing the interquartile range of each column of a, divided by
% 1.34896. The factor 1.34896 makes this quantity equal on average to the
% standard deviation (SD) of normal distributions, and thue the IRQ is a
% better estimate of the standard deviation without ouliers.
%  T. C. O'Haver, 2017
mina=min(a);
sizea=size(a);
NumCols=sizea(2);
for n=1:NumCols,b(:,n)=a(:,n)-mina(n);end
Sorteda=sort(b);
lx=length(Sorteda);
SecondQuartile=round(lx/4);
FourthQuartile=3*round(lx/4);
b=abs(Sorteda(FourthQuartile,:)-Sorteda(SecondQuartile,:));
b=b./1.34896;
% ----------------------------------------------------------------------
function err = fitmultiple(lambda,xx,y,numpeaks,shapesvector,extra)
% Fitting function for a multiple-shape band signal.
% The sequence of peak shapes are defined by the vector "shape".
% The vector "extra" determines the shape of variable-shape peaks.
global PEAKHEIGHTS BaselineMode BIPOLAR LOGPLOT coeff FIXEDPARAMETERS
% FIXEDPARAMETERS=FIXEDPARAMETERS; % testing
% PEAKHEIGHTS=PEAKHEIGHTS % testing
% lambda=lambda
% numpeaks=round(length(lambda)/2)
% sizeshapesvector=size(shapesvector)
A=zeros(numpeaks,length(xx));
for j = 1:numpeaks,
    if shapesvector(j)==28,
        coeff=polyfit(xx,y,extra(j));
        A(j,:) = polyval(coeff,xx);
    else
        % sizeA=size(A)
        switch shapesvector(j)
            case 1
                A(j,:)=gaussian(xx,lambda(2*j-1),lambda(2*j));
            case 2
                A(j,:)=lorentzian(xx,lambda(2*j-1),lambda(2*j));
            case 3
                A(j,:)=logistic(xx,lambda(2*j-1),lambda(2*j));
            case 4
                A(j,:)=pearson(xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 5
                A(j,:)=expgaussian(xx,lambda(2*j-1),lambda(2*j),-extra(j))';
            case 6
                A(j,:)=gaussian(xx,lambda(j),lambda(NumPeaks+1));
            case 7
                A(j,:)=lorentzian(xx,lambda(j),lambda(NumPeaks+1));
            case 8
                A(j,:)=expgaussian(xx,lambda(j),lambda(NumPeaks+1),-extra(j))';
            case 9
                A(j,:)=exppulse(xx,lambda(2*j-1),lambda(2*j));
            case 10
                A(j,:)=upsigmoid(xx,lambda(2*j-1),lambda(2*j));
            case 11
                A(j,:)=gaussian(xx,lambda(j),FIXEDPARAMETERS(j));
            case 12
                A(j,:)=lorentzian(xx,lambda(j),FIXEDPARAMETERS(j));
            case 13
                A(j,:)=GL(xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 14
                A(j,:)=BiGaussian(xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 15
                A(j,:)=BWF(xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 16
                A(j,:)=gaussian(xx,FIXEDPARAMETERS(j),lambda(j));
            case 17
                A(j,:)=lorentzian(xx,FIXEDPARAMETERS(j),lambda(j));
            case 18
                A(j,:)=explorentzian(xx,lambda(2*j-1),lambda(2*j),-extra(j))';
            case 19
                A(j,:)=alphafunction(xx,lambda(2*j-1),lambda(2*j));
            case 20
                A(j,:)=voigt(xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 21
                A(j,:)=triangular(xx,lambda(2*j-1),lambda(2*j));
            case 22
                A(j,:)=peakfunction(shapesvector(j),xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 23
                A(j,:)=downsigmoid(xx,lambda(2*j-1),lambda(2*j));      
            case 24
                A(j,:)=nbinpdf(xx,lambda(2*j-1),lambda(2*j));
            case 25
                A(j,:)=lognormal(xx,lambda(2*j-1),lambda(2*j));
            case 26
                A(j,:)=linslope(xx,lambda(2*j-1),lambda(2*j));
            case 27
                A(j,:)=d1gauss(xx,lambda(2*j-1),lambda(2*j));       
            case 28
                A(j,:)=polynomial(xx,lambda(2*j-1),lambda(2*j));       
            case 29
                A(j,:)=segmented(xx,yy,PEAKHEIGHTS);
            case 30
                A(j,:)=voigt(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));        
            case 31
                A(j,:)=expgaussian(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));        
            case 32
                A(j,:)=pearson(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));        
            case 33
                A(j,:)=GL(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));
            case 34
                width(j)=abs(FIXEDPARAMETERS(j));
                 % [j lambda(j) width(j) extra(j)]
%                 gD(j)=width(j);
%                 gL(j)=extra.*gD(j);
%                 width(j) = 2.*(0.5346*gL(j) + sqrt(0.2166*gL(j).^2 +
%                 gD(j).^2))
                A(j,:)=voigt(xx,lambda(j),width(j),extra(j));
                % figure(5);plot(A(j,:));figure(1)
            case 35
                A(j,:)=GL(xx,lambda(j),FIXEDPARAMETERS(j),extra(j));
            case 36
                A(j,:)=expgaussian(xx,lambda(j),FIXEDPARAMETERS(j),extra(j));
            case 37
                A(j,:)=pearson(xx,lambda(j),FIXEDPARAMETERS(j),extra(j));
            case 38
                A(j,:)=explorentzian(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));                    
            case 39
                A(j,:)=ExpGaussian2(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));                               
            case 40
                A(j,:)=sine(xx,lambda(2*j-1),lambda(2*j));
            case 41
                A(j,:)=rectangle(xx,lambda(2*j-1),lambda(2*j));
            case 42
                A(j,:)=ngaussian(xx,lambda(2*j-1),lambda(2*j),extra(j));
            case 43
                A(j,:)=Gompertz(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));
            case 44
                A(j,:)=OneMinusExp(xx,lambda(2*j-1),lambda(2*j));
            case 45
                A(j,:)=FourPL(xx,lambda(3*j-2),lambda(3*j-1),lambda(3*j));        
            case 46
                A(j,:)=quadslope(xx,lambda(2*j-1),lambda(2*j));
            case 47
                A(j,:)=blackbody(xx,lambda(j));
            case 48
                A(j,:)=exppulse(xx,lambda(j),lambda(NumPeaks+1));
        end % switch
    end % if shapesvector
end % for j=1:numpeaks,
if BaselineMode==3,A=[ones(size(y))' A];end
% sizeA=size(A)
% max(A')
% sizeyp=size(y')
if BIPOLAR,PEAKHEIGHTS=A'\y';else PEAKHEIGHTS=abs(A'\y');end
% PEAKHEIGHTS=PEAKHEIGHTS
z = A'*PEAKHEIGHTS;
if LOGPLOT,
    err = norm(log10(z)-log10(y)');
else
    err = norm(z-y');
end
% ----------------------------------------------------------------------
function p=peakfunction(shape,x,pos,wid,extra,coeff)
global FIXEDPARAMETERS
% function that generates any of 20 peak types specified by number. 'shape'
% specifies the shape type of each peak in the signal: "peakshape" = 1-20.
% 1=Gaussian 2=Lorentzian, 3=logistic, 4=Pearson, 5=exponentionally
% broadened Gaussian; 9=exponential pulse, 10=up sigmoid,
% 13=Gaussian/Lorentzian blend; 14=BiGaussian, 15=Breit-Wigner-Fano (BWF) ,
% 18=exponentionally broadened Lorentzian; 19=alpha function; 20=Voigt
% profile; 21=triangular; 23=down sigmoid; 25=lognormal. "extra" is required
% for variable-shape peaks only.
switch shape
    case 1
        p=gaussian(x,pos,wid);
    case 2
        p=lorentzian(x,pos,wid);
    case 3
        p=logistic(x,pos,wid);
    case 4
        p=pearson(x,pos,wid,extra);
    case 5
        p=expgaussian(x,pos,wid,extra);
    case 6
        p=gaussian(x,pos,wid);
    case 7
        p=lorentzian(x,pos,wid);
    case 8
        p=expgaussian(x,pos,wid,extra)';
    case 9
        p=exppulse(x,pos,wid);
    case 10
        p=upsigmoid(x,pos,wid);
    case 11
        p=gaussian(x,pos,wid);
    case 12
        p=lorentzian(x,pos,wid);
    case 13
        p=GL(x,pos,wid,extra);
    case 14
        p=BiGaussian(x,pos,wid,extra);
    case 15
        p=BWF(x,pos,wid,extra);
    case 16
        p=gaussian(x,pos,wid);
    case 17
        p=lorentzian(x,pos,wid);
    case 18
        p=explorentzian(x,pos,wid,extra)';
    case 19
        p=alphafunction(x,pos,wid);
    case 20
        p=voigt(x,pos,wid,extra);
    case 21
        p=triangular(x,pos,wid);
    case 23
        p=downsigmoid(x,pos,wid);
    case 25
        p=lognormal(x,pos,wid);
    case 26
        p=linslope(x,pos,wid);
    case 27
        p=d1gauss(x,pos,wid);
    case 28
        p=polynomial(x,coeff);
    case 30
        p=voigt(x,pos,pos,wid,extra);
    case 31
        p=expgaussian(x,pos,wid,-extra);
    case 32
        p=pearson(x,pos,wid,extra);
    case 33
        p=GL(x,pos,wid,extra);
    case 34
        % width(extra)=abs(FIXEDPARAMETERS(extra));
        p=voigt(x,pos,wid,extra);
    case 35
        p=GL(x,pos,wid,extra);
    case 36
        p=expgaussian(x,pos,wid,-extra);
    case 37
        p=pearson(x,pos,wid,extra);
    case 38
        p=explorentzian(x,pos,wid,-extra);
    case 39
        p=ExpGaussian2(x,pos,wid,extra);
    case 40
        p=sine(x,pos,wid);
    case 41
        p=rectangle(x,pos,wid);
    case 42
        p=ngaussian(x,pos,wid,extra);
    case 43
        p=Gompertz(x,pos,wid,extra);
    case 44
        p=OneMinusExp(x,pos,wid);
    case 45
        p=FourPL(x,pos,wid,extra);
    case 46
        p=quadslope(x,pos,wid);
    case 47
        p=blackbody(x,pos);
    case 48
        p=exppulse(x,pos,wid);
    otherwise
end % switch
%-----------------------------------------
function model=modelpeaks(xx,NumPeaks,peakshape,Heights,Positions,Widths,extra,FIXEDWIDTH)
% model=modelpeaks(xx,NumPeaks,peakshape,Heights,Positions,Widths,extra,FIXEDWIDTH)
% Specifies the peak shape of the model: "peakshape" = 1-15. (1=Gaussian
% (default), 2=Lorentzian, 3=logistic, 4=Pearson, 5=exponentionally
% broadened Gaussian; 6=equal-width Gaussians; 7=Equal-width Lorentzians;
% 8=exponentionally broadened equal-width Gaussian, 9=exponential pulse,
% 10=sigmoid, 11=Fixed-width Gaussian, 12=Fixed-width Lorentzian;
% 13=Gaussian/Lorentzian blend; 14=BiGaussian, 15=BiLorentzian
% Extra is needed only for shapes 4, 5, 8, 13, 14, and 15.
% FIXEDWIDTH is needed only for shapes 11 ands 12.
% Version 2, Jan. 2018, peakshape can be a vector of different shape numbers
%
% Example 1: Gaussian peaks
%  x=[1:1000];
%  model=modelpeaks(x,3,1,[1 2 3],[200 500 700],[50 50 50],0,0);
%  plot(model)
%
% Example 2: Exponentionally broadened Gaussian peaks, time constant = 70
%  model=modelpeaks(x,3,5,[1 2 3],[200 500 700],[50 50 50],70,0);
%  plot(model)
%
A=zeros(NumPeaks,length(xx));
for m=1:NumPeaks
   switch peakshape
    case 1
        A(m,:)=gaussian(xx,Positions(m),Widths(m));
    case 2
        A(m,:)=lorentzian(xx,Positions(m),Widths(m));
    case 3
        A(m,:)=logistic(xx,Positions(m),Widths(m));
    case 4
        A(m,:)=pearson(xx,Positions(m),Widths(m),extra);
    case 5
        A(m,:)=expgaussian(xx,Positions(m),Widths(m),-extra)';
    case 6
        A(m,:)=gaussian(xx,Positions(m),Widths(m));
    case 7
        A(m,:)=lorentzian(xx,Positions(m),Widths(m));  
    case 8
        A(m,:)=expgaussian(xx,Positions(m),Widths(m),-extra)';    
    case 9
        A(m,:)=exppulse(xx,Positions(m),Widths(m));  
    case 10
        A(m,:)=sigmoid(xx,Positions(m),Widths(m)); 
    case 11
        A(m,:)=gaussian(xx,Positions(m),FIXEDWIDTH);
    case 12
        A(m,:)=lorentzian(xx,Positions(m),FIXEDWIDTH); 
    case 13
        A(m,:)=GL(xx,Positions(m),Widths(m),extra);
    case 14
        A(m,:)=BiGaussian(xx,Positions(m),Widths(m),extra);       
    case 15
        A(m,:)=BiLorentzian(xx,Positions(m),Widths(m),extra);       
   end % switch
end % for
% Multiplies each row by the corresponding amplitude and adds them up
model=Heights*A;
