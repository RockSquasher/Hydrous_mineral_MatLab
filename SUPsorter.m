%% Welcome to SUPsorter
% This script was written by Mate Garai C'24 in 02/2024

% This is a spectral data formatting and sorting script for Raman and FTIR
% spectral peak position data for Diamond anvil cell experiments for use at
% Sewanee Under Pressure (SUP) laboratory group. This script converts a
% pre-made user friendly Excel file that contains the fitted peak positions
% into a computer friendly list of comma separated .txt files which are
% convenient for plotting and processing when using MatLab or similar
% software.
% SUPplotter.m makes sure that the files are in the appropriate format for
% plotting by SUPplotter.m or SUPplotter_adv.m


% The user should have an Excel sheet ready with the following
% specifications:
% The Excel file should be formatted such that every sample has a
% dedciated column for the pressure steps. The other columns contain the
% peak positions for each mode respectively. The order of the columns does
% not matter. The important detail is that the first entry in each should
% be the appropriate sample title formatted as such:
% Samplename_molecule_vibrationmode_peaknumber.txt
% Example: SMP3_OH_v13_1.txt
% If there is only one peak corresponding to a vibrational mode still
% label it as *_1.txt
% The columns containing the Pressures should also have the title:
% Samplename_P.txt
% Example: SMP3_P.txt
% A Sample Excel sheet called "MelanteriteSum.xlsx" can be found in our 
% master Google Drive and should be used as a guide
% 
% I know it is inconvenient (maybe someone will improve this code) but
% please make sure that the Excel sheet does not contain anything else
% other than the appropriately formatted data. The first row should contain
% all the column titles (Pressures and Peak positions) and nothing else.
% From the second row on the sheet should only contain the numerical data
% of pressure and peak position values


%% USER INPUT
% Enter the source (path and name) of the Excel sheets containing the
% spectral peak data
% Example: "/Users/mategarai/Documents/1_Thompson_Lab/MelanteriteSUM.xlsx"
ramansource = "/Users/mategarai/Documents/1_Thompson_Lab/MelanteriteSUM.xlsx";
FTIRsource = "/Users/mategarai/Documents/1_Thompson_Lab/MelanteriteSUM.xlsx";

% Enter the name of the sheet that contains the appropriate data
% Example: 'Raman'
ramansheetname = 'Raman';
FTIRsheetname = 'FTIR';

% Enter the folder in which you want to store your sorted formatted csv data 
% Example: "/Users/mategarai/Documents/1_Thompson_Lab/Raman_peaks/"
ramantarget = "/Users/mategarai/Documents/1_Thompson_Lab/Raman_peaks/";
FTIRtarget = "/Users/mategarai/Documents/1_Thompson_Lab/FTIR_peaks/";






%% CODE
%Create tables containing Raman and FTIR files
TRaman = readtable(ramansource,'Sheet',ramansheetname);
TFTIR = readtable(FTIRsource,'Sheet',FTIRsheetname);


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
        writematrix(m,strcat(ramantarget,Ramanvars(i),".txt"));
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
        writematrix(m,strcat(FTIRtarget,FTIRvars(i),".txt"));
    end
end
end