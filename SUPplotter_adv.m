
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
% plug in the folder location in a string format 
% ex.:"/Documents/Raman_peaks"
% This folder should only contain the comma separated .txt files of the
% peak data in the format [Pressure1,Peak1; Pressure2, peak2;...]
pathname = "";

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
Samplenames = [];

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