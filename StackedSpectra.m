%% Load the file

% TO DO: check that you're calling in only the files you want to plot. Use
%an asterisk to inidate parts of the file name you don't want to specify.

selFiles = dir('C:\Users\Mineral Physics\Desktop\SMP11 FTIR\new smp1 fft\fft*a.dat') ;

nFiles = numel(selFiles) ;

yValue = [] ;

for i = 1:nFiles
    fileName = selFiles(i).name ;
    
    tmpData = readmatrix(fileName) ;
    
    tmpData(end,:) = [] ;
    
    if i==1 
        xValue = tmpData(:,1) ;
    end
    
    yValue(:,i) = tmpData(:,2) ;
end   

%% make plots

% TO DO: Indicate in the two lines below the range of X values to plot
% for Raman centered at 547, a good range is 400 to 650
% for Raman centered at 557 or 560, a good range is 950 to 1100
% for Raman centered at 650, a good range is 3300 to 3600
% for full FTIR spectra, a good range is 500 to 4500
%for water region of FTIR only, try 2600 to 4000
minXvalue = 950 ;
maxXvalue = 1100 ;

idx = find(xValue>=minXvalue & xValue<=maxXvalue) ;
newXvalue = xValue(idx,:) ;
newYvalue = yValue(idx,:) ;

% find the minimum to get the baseline
minValue = min(newYvalue) ;

% find the maximum to scale
maxValue = max(newYvalue-minValue) ;
scaledY = (newYvalue-minValue)./maxValue ;

% create the offset
% TO DO:  After running once, tweak the increment value below
increment = 0.5 ;
offset = 0:increment:(nFiles-1)*increment ;

% define the colorplot
cm = colormap(cool(nFiles)) ;
colororder(cm)

% make the plot
plot(newXvalue,scaledY+offset)