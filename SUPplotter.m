%% Welcome to SUP peakplotter
% This script was written by Mate Garai C'24 in 03/2024
% This script is the beginner friendly version of SUPplotter. For a faster
% version use SUPplotter_adv.m. This script plots Raman and FTIR peak 
% position data as a function of pressure. 

% The only thing you need to run this script is a summarized excel sheet 
% containing the data points to be plotted in a very particular formatting 
% please see MelanteriteSUM.xlsx for reference:

% Make sure every sample has a Pressure column titled in the format:
% SAMPLENAME_P
% Example: SMP3_P
% This column should contain all the pressure steps for the specified 
% sample
% Make sure each peak gets their own column (if the peak splits, create a 
% new column). The column title should be:
% SAMPLENAME_MOLECULE_VIBRATIONMODE_PEAKNUMBER
% Example: SMP3_SO_v1_1
% Decompression data should be stored in different columns with the column 
% for the pressure having a title:
% SAMPLENAMED_P (D for decompression)
% Example: SMP3D_P
% Make sure each decompression peak gets their own column (if the peak 
% splits, create a new column). The column title should be:
% SAMPLENAMED_MOLECULE_VIBRATIONMODE_PEAKNUMBER
% Example: SMP3D_SO_v1_1
% Have the excel file on your computer so you can select it when you run 
% the script
% If you are ready to plot and have the approprioate pre-processing down 
% just hit start and follow the prompts
% The script should automatically determine which peaks are in common for 
% the selected samples. If there are no vibrational modes in common it will
% tell you so and not plot anything. If you only select one sample, it plot
% all the vibrational modes for that one sample.

% Pre-processing of the data is done by "SUPsorterfun" function
% which makes sure that the data read by this script is in comma separated
% .txt files in the form: [Pressure1,Peak1; Pressure2, peak2;...]
% Example:
%
% 0,3466.5
% 0.16,3462.3
% 0.49,3467.6
% 0.73,3465.7
% 0.94,3463.9
% 1.1,3463.3
% 1.31,3461.5
% ........

% If you are ready to plot and have the approprioate pre-processing down
% just hit start and follow the prompt
% YOU ARE READY TO ROLL!

% Here are some aesthetic details you may change:
col = "cool"; % colormap of the plots (default MatLab colormaps)
fontS = 14; % legend font size
fontSax = 13; % axis font size
boxed = true; % boxes your plot
msize = 50; % Marker size
xaxisT = "P (GPa)"; % x axis title
yaxisT = ""; % y axis title
aspratio = [1,1,1]; %plot aspect ratio

%custom colormap (leave empty if you don't need it)
c = [];



%% Ask user which folder they want to work from
disp("Welcome to SUP plotter! If at any point you wish to exit type 'exit'")
disp("Choose an Excel file containing samples: ",'s');
[file,pathname] = uigetfile('*.xlsx');

%Throw error and end script if folder is not specified
if file == 0
error("No file selected!")
end
pathname = strcat(pathname,file);
disp(pathname);
sheet = sheetnames(pathname);

SUPsorterfun(pathname,pathname,sheet(1),sheet(2));

sheetsel = questdlg('Choose a Sheet to plot', ...
	'Sheet selection', ...
	sheet(1),sheet(2),'Exit',sheet(1));

switch sheetsel
    case sheet(1)
        files = dir(strcat(pwd,'/',sheet(1)));
    case sheet(2)
        files = dir(strcat(pwd,'/',sheet(2)));
    case 'Exit'
        return
end
%Delete hidden files from the struct (files that start with a ".")
files = files(arrayfun(@(x) ~strcmp(x.name(1),'.'),files));

%Create a list of samples the user can choose from 
list = strings(length(files),1);
declist = strings(0);
for i = 1:length(files)
    name = split(files(i).name,"_");
    name = name{1};
    if isequal(lower(name(end)),'d')
        declist = [declist,name];
        name = name(1:end-1);
    end
    list(i) = name;
    
end
list = unique(list);
declist = unique(declist);

%% Ask user which files they want to plot
[indx,tf] = listdlg('PromptString',{'Select a sample.'},'ListString',list);
if ~tf
    return
end
% store user selected samples in a string vector
samplestoplot = strings(length(indx),1);
for i = 1:length(indx)
    samplestoplot(i) = list(indx(i));
end

%% prepare files of interest

%if there are more than one samples selected interesect all the properties 
%to find the ones that are in common
Samplenames = samplestoplot; % create a separate list for the legend before making names lowercase
samplestoplot = lower(samplestoplot);
filesofinterest  = files(1);

% Determine if there are modes in common
if length(samplestoplot)>1 % if user selected more samples find commonalities
    comptable = cell(0);
    for i = 1:length(samplestoplot)
        props = strings(0);
        temp = "";
        for j = 1:length(files)
            if startsWith(string(lower(files(j).name)),strcat(samplestoplot(i),'_')) || startsWith(string(lower(files(j).name)),strcat(samplestoplot(i),'d_'))
                prop = split(lower(files(j).name),["_","."]);
                prop = strcat(prop(2),"_",prop(3));
    
                filesofinterest = [filesofinterest,files(j)];
                if ~isequal(temp,prop)
                    props = [props,prop];
                    temp = prop;
                end
            end
        end
        comptable = [comptable;{props'}];
    end
    
    commonmodes = comptable{1};
    for i = 2:length(comptable)
        commonmodes = intersect(commonmodes,comptable{i});
    end
    disp(commonmodes);
    disp(length(commonmodes)+" modes found in common");
end
% If user only selected one sample just plot all modes
if length(samplestoplot) == 1
    commonmodes = strings(0);
    temp = "";
    for i = 1:length(files)
        if startsWith(string(lower(files(i).name)),strcat(samplestoplot(1),'_')) || startsWith(string(lower(files(i).name)),strcat(samplestoplot(1),'d_'))
            prop = split(lower(files(i).name),["_","."]);
            prop = strcat(prop(2),"_",prop(3));
            filesofinterest = [filesofinterest,files(i)];
            if ~isequal(temp,prop)
                commonmodes = [commonmodes,prop];
                temp = prop;
            end
        end
    end
    disp(commonmodes);
    disp(length(commonmodes)+" modes found");
    clear('temp')
end

%% Plot the selected modes

% Add decompression data



lgd = cell(length(samplestoplot),1);
for j = 1:length(commonmodes)
    % set up figure properties
    fig = figure();
    ax = axes(fig);
    hold(ax,'on');
    title(ax,strrep(commonmodes(j),'_',' '))
    fig.Name = strrep(commonmodes(j),'_',' ');
    xlabel(ax,xaxisT);
    ylabel(ax,yaxisT);
    if boxed
        box(ax,"on")
    end
    fontsize(ax,fontSax,'points')
    pbaspect(ax,aspratio);

    p = gobjects(0);
    ind = 0;
    for i = 1:length(samplestoplot)
        % if no color palette is specified, use the function that creates
        % one
        if isempty(c)
            c = palette(length(samplestoplot),col);
        end
        for k = 1:length(filesofinterest)
            if startsWith(string(lower(filesofinterest(k).name)),strcat(samplestoplot(i),'_',commonmodes(j))) || startsWith(string(lower(filesofinterest(k).name)),strcat(samplestoplot(i),'d_',commonmodes(j)))
                path = strcat(filesofinterest(k).folder,"/",filesofinterest(k).name);
                M = readmatrix(path);
                if startsWith(string(lower(filesofinterest(k).name)),strcat(samplestoplot(i),'d_',commonmodes(j)))
                    pt = scatter(ax,M(:,1),M(:,2),msize,'LineWidth',2,MarkerEdgeColor=c(i,:));
                    
                else
                    pt = scatter(ax,M(:,1),M(:,2),msize,'filled',MarkerFaceColor=c(i,:));
                    
                end

                if ind ~= i
                    p = [p,pt];
                    lgd(i) = {Samplenames(i)};
                    ind=i;
                end
            end
        end
    end
    lgdh = legend(ax,p,lgd,'Interpreter','none');
    lgdh.FontSize = fontS;
end

function col = palette(n,type)
    switch type
        case "parula"
            col = parula(n);
        case "turbo"
            col = turbo(n);
        case "hsv"
            col = hsv(n);
        case "hot"
            col = hot(n);
        case "cool"
            col = cool(n);
        case "spring"
            col = spring(n);
        case "summer"
            col = summer(n);
        case "autumn"
            col = autumn(n);
        case "winter"
            col = winter(n);
        case "gray"
            col = gray(n);
        case "bone"
            col = bone(n);
        case "copper"
            col = copper(n);
        case "pink"
            col = pink(n);
        case "sky"
            col = sky(n);
        case "abyss"
            col = abyss(n);
        case "jet"
            col = jet(n);
        case "lines"
            col = lines(n);
        case "colorcube"
            col = colorcube(n);
        case "prism"
            col = prism(n);
        case "flag"
            col = flag(n);
        case "white"
            col = white(n);
    end
end


%% SUPsorter
% This is a spectral data formatting and sorting function for Raman and FTIR
% spectral peak position data for Diamond anvil cell experiments for use at
% Sewanee Under Pressure (SUP) laboratory group. This script converts a
% pre-made user friendly Excel file that contains the fitted peak positions
% into a computer friendly list of comma separated .txt files which are
% convenient for plotting and processing when using MatLab or similar
% software.
% SUPplotter.m makes sure that the files are in the appropriate format for
% plotting by SUPplotter.m or SUPplotter_adv.m
function [rtarg, ftarg] = SUPsorterfun(rsource,Fsource,rsheetname,fsheetname)
    
    % folder in which you want to store your sorted formatted csv data 
    % Example: "/Users/mategarai/Documents/1_Thompson_Lab/Raman_peaks/"
    if ~exist(strcat(pwd,'/',rsheetname), 'dir')
        mkdir(strcat(pwd,'/',rsheetname));
    end
    if ~exist(strcat(pwd,'/',fsheetname), 'dir')
        mkdir(strcat(pwd,'/',fsheetname));
    end

    rtarget = strcat(pwd,'/',rsheetname,'/'); %raman target folder
    ftarget = strcat(pwd,'/',fsheetname,'/'); %FTIR target folder

    rtarg = rtarget; %output raman target folder name
    ftarg = ftarget; %output FTIR target folder name
    
    %Create tables containing Raman and FTIR files
    TRaman = readtable(rsource,'Sheet',rsheetname);
    TFTIR = readtable(Fsource,'Sheet',fsheetname);
    
    
    %Create vectors of just the names of the columns so we can identify which
    %column is what
    Ramanvars = string(TRaman.Properties.VariableNames');
    FTIRvars = string(TFTIR.Properties.VariableNames');
    
    %% Determine what samples we have
    name = split(Ramanvars(1),"_"); %get the first variable and split it at delimiters (temporary)
    name = name(1); %Get the first entry to name which is the name of the sample
    
    % create a list of strings containing the names of all Raman samples
    Ramansamplenames = name;
    for i = 2:length(Ramanvars)
        currentname = split(Ramanvars(i),"_");
        currentname = currentname(1);
    
        if isequal(name,currentname)
        else
            Ramansamplenames = [Ramansamplenames,currentname];
            name = currentname;
        end
    end
    
    name = split(FTIRvars(1),"_"); %get the first variable and split it at delimiters (temporary)
    name = name(1); %Get the first entry to name which is the name of the sample
    % create a list of strings containing the names of all FTIR samples
    FTIRsamplenames = name;
    for i = 2:length(FTIRvars)
        currentname = split(FTIRvars(i),"_");
        currentname = currentname(1);
    
        if isequal(name,currentname)
        else
            FTIRsamplenames = [FTIRsamplenames,currentname];
            name = currentname;
        end
    end
    clear("name","currentname") % clear temporary variables to get rid of clutter
    
    
    %% this creates text files of all the vibration modes for all samples
    
    % cycle through raman samples
    for k = 1:length(Ramansamplenames)
    for i = 1:length(Ramanvars)
        samplename = strcat(Ramansamplenames(k),"_");
        pressdata = strcat(samplename,"P"); % determine which column contains the pressures
        if startsWith(Ramanvars(i),samplename) && Ramanvars(i) ~= pressdata % if the current column is the sample we're interested in put it in a text file
            m = [TRaman.(pressdata),TRaman.(i)]; %creates the vector as [Pressure, peak position]
            writematrix(m,strcat(rtarget,Ramanvars(i),".txt"));
        end
    end
    end
    
    % cycle through FTIR samples
    for k = 1:length(FTIRsamplenames)
    for i = 1:length(FTIRvars)
        samplename = strcat(FTIRsamplenames(k),"_");
        pressdata = strcat(samplename,"P"); % determine which column contains the pressures
        if startsWith(FTIRvars(i),samplename) && FTIRvars(i) ~= pressdata % if the current column is the sample we're interested in put it in a text file
            m = [TFTIR.(pressdata),TFTIR.(i)]; %creates the vector as [Pressure, peak position]
            writematrix(m,strcat(ftarget,FTIRvars(i),".txt"));
        end
    end
    end
end