
%% Welcome to SUP peakplotter (advanced version)
% This script was written by Mate Garai C'24 in 02/2024

% This script is the more compact, faster version of SUPplotter. A script
% that plots Raman, FTIR or related peak position data as a function of
% pressure. Pre-processing of the data should be done by "SUPsorter.m" script
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
%
% The title of these files also has to be in a particular formatting as it
% is essential for the script to identify what it is working with.
% The title of the files should be as such:
% Samplename_molecule_vibrationmode_peaknumber.txt
% Example: SMP3_OH_v13_1.txt
% If there is only one peak corresponding to a vibrational mode still
% label it as *_1.txt


%% USER INPUT
% Enter the source (path and name) of the Excel sheets containing the
% spectral peak data
% Example: "Documents/MelanteriteSUM.xlsx"
ramansource = "/Users/mategarai/Documents/1_Thompson_Lab/MelanteriteSUM.xlsx";
FTIRsource = "/Users/mategarai/Documents/1_Thompson_Lab/MelanteriteSUM.xlsx";

% Enter the name of the sheet that contains the appropriate data
% Example: 'Raman'
ramansheetname = 'Raman';
FTIRsheetname = 'FTIR';

% Select spectral type 'r' for raman, 'f' for FTIR
spectr = 'r';

% Select sample 
% Specify samples you would like to plot in the form of a string array.
% Example:
% samplestoplot = ["smp3","smp19","smp8"];
%
% Make sure the selected samples exist and the sample names correspond to
% the whatever is before the _ in the file name
% Example: if the file name is SMP3_OH_v13_1.txt the entry in the string
% array should be "SMP3" or "smp3" as the treats "_" as delimiters in the
% file name
Samplenames = ["SMP3","SMP6"];

% Here are some aesthetic details you may change:
col = "lines"; % colormap of the plots (default MatLab colormaps)
fontS = 14; % legend font size
fontSax = 13; % axis font size
boxed = true; % boxes your plot
msize = 40; % Marker size
xaxisT = "P (GPa)"; % x axis title
yaxisT = ""; % y axis title

%custom colormap (leave empty if you don't need it)
c = [];

% clear all variables after execution?
clr = true;


% YOU ARE READY TO ROLL!


%% CODE

[ramansource,FTIRsource] = SUPsorterfun(ramansource,FTIRsource,ramansheetname,FTIRsheetname);

switch spectr
    case 'f'
        pathname = FTIRsource;
    case 'r'
        pathname = ramansource;
end

% Find the folder specified by the user
if isequal(lower(pathname), 'exit')
    return
end
files = dir(pathname);

%Throw error and end script if folder is not found
if isempty(files)
error(pathname+" not found. Check the path or file permissions.")
end

%Delete hidden files from the struct (files that start with a ".")
files = files(arrayfun(@(x) ~strcmp(x.name(1),'.'),files));

%Create a list of samples the user can choose from 
list = string(); 
for i = 1:length(files)
    name = split(files(i).name,"_");
    name = name(1);
    if i == 1
        currentname = name;
        list(1)=name{1};
    elseif ~isequal(currentname,name)
        list = [list;name{1}];
        currentname = name;
    end
end
clear("curentname", "name")
disp(length(files)+" files and "+length(list)+" samples found");


%% Prepare files of interest
%if there are more than one samples selected interesect all the properties 
%to find the ones that are in common
filesofinterest  = files(1);
samplestoplot = lower(Samplenames);
if length(samplestoplot)>1
comptable = cell(0);
for i = 1:length(samplestoplot)
    props = strings(0);
    temp = "";
    for j = 1:length(files)
        if startsWith(string(lower(files(j).name)),strcat(samplestoplot(i),'_'))
            prop = split(lower(files(j).name),["_","."]);
            prop = strcat(prop(2),"_",prop(3));

            filesofinterest = [filesofinterest,files(j)];
            if ~isequal(temp,prop)
                props = [props,prop];
                temp = prop;
            end
        end
    end
    clear('temp')
    comptable = [comptable;{props'}];
end

commonmodes = comptable{1};
for i = 2:length(comptable)
    commonmodes = intersect(commonmodes,comptable{i});
end
disp(commonmodes);
disp(length(commonmodes)+" modes found in common");

else
    commonmodes = strings(0);
    temp = "";
    for i = 1:length(files)
        if startsWith(string(lower(files(i).name)),strcat(samplestoplot(1),'_'))
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
end

%% Plot the selected modes
lgd = cell(length(samplestoplot),1);
for j = 1:length(commonmodes)

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

    p = gobjects(0);
    ind = 0;
    for i = 1:length(samplestoplot)
        if isempty(c)
            c = palette(length(samplestoplot),col);
        end
        for k = 1:length(filesofinterest)
            if startsWith(string(lower(filesofinterest(k).name)),strcat(samplestoplot(i),'_',commonmodes(j)))
                path = strcat(filesofinterest(k).folder,"/",filesofinterest(k).name);
                M = readmatrix(path);
                pt = scatter(ax,M(:,1),M(:,2),msize,'filled',MarkerFaceColor=c(i,:));

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
if clr
    clear
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

    rtarget = strcat(pwd,'/',rsheetname,'/');
    ftarget = strcat(pwd,'/',fsheetname,'/');

    rtarg = rtarget;
    ftarg = ftarget;
    
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