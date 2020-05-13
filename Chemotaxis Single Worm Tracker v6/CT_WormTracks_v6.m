function [] =CT_WormTracks_v5()
%%  File Description
%   Single Worm Chemotaxis Tracking
%   
%   Function that takes manual worm tracks from Fiji 
%   and makes a figure that overlays the tracks.
%   Used to analyze single worm chemotaxis tracking assays. 
%   Flexibly handles both odor tracking and CO2 tracking assays.
%
%   Version 6.0 created by ASB
%   Version Date: 12/2/19
%
%%  REVISION HISTORY
%   12/22/17    Created by Astra S. Bryant.
%   12/30/17    Made modular (ASB) 
%   2/1/18      Adjusted for SG's chemotaxis tracking setup (ASB)
%   3/18/19     added functionatilty for NB and FR (ASB)
%   4/5/19      added functionality, incl: more quantifications and a
%               rotational adjustment. Also renamed the codebase as version 2 (ASB)
%   6/18/19     More robust spreadsheet saving code makes it work across Mac and
%               PC systems. (ASB)
%   6/18/19     Renamed version 2 to version 3. Discorectangle added. Uploaded to Hallem Lab Codebase. This is the primary version(ASB.)
%   6/27/19     Updated to version 4, adding the ability to choose whether the
%               assay being analyzed is a CO2 tracking or odor tracking experiment.
%               These two experiments have different arena sizes and scoring regions; 
%               this is now taken into account during both quantification and plotting.
%               This version also takes into account the addition of new tracking
%               stations, which might have different pixels/cm parameters. So will now
%               require a new input via the Index sheet, of pixels/cm for
%               each worm. (ASB)
%   9/23/19     Changed how the pixelspercm value is inputed and handled, to account
%               for instances where the camera is at an angle. (ASB)
%   9/24/19     Renamed version 5. (ASB)
%   12/2/19     Added 2 new assay types: pheromone assay and odor assay
%               (renamed old odor assay to bacterial chemotaxis assay).
%               (ASB)
%   12/4/19     Moved generating the lobical variables subsetplot and
%                   individual plots from CT_TrackPlotter_v6 so they'll be
%                   easier for users to find (ASB)
%
%% IMPORTANT ASSUMPTIONS: 
%       Assumes that the frame rate of the images is 1 frame/2 seconds.
%
%% DEPENDENCIES
%   circle.m
%   discorectangle.m
%   displace.m 
%   importfileXLS.m
%   ImportTracks.m
%   rotationmatrix.m
%   CT_AnalyzeTracks_v6.m
%   CT_AssayParams_v6.m
%   CT_CO2_Quantification_v6.m
%   CT_Convert_v6.m
%   CT_ExptList_v6.m
%   CT_Odor_Quantification_v6.m
%   CT_ScaleAdjustments_v6.m
%   CT_TrackPlotter_v6.m
%
%
%% Variables
%   Input = excel spreadsheet with an Index sheet listing:
%       the number of worms to analyze, 
%       the UIDs associated with the tracks analyze that are ...
%           ... the names of the tabs in the excel file with the track datas
%       for each UID: orientation of ctrl vs experimental side ...
%           where a value of 1 = experimental port = L; a value of 0 =
%           experimental port = R.
%           
%           ...XY coordinates for location of ctrl vs experimental chemical (4 columns: Xleft, Yleft, Xright, Yright)...
%           ...pixelspercm value for each UID - this may change depending
%           on which tracking station was used to collect the data

close all; clear all

%% User Provided Variables (used during plotting) - logical values
subsetplot = 1; %Generate subset plot y/n (logical)? Note: if there are less than 10 worms, the subset plot won't be generated anyway.
individualplots = 1; % Generate individual plots for each track y/n (logical)?


%% GUI for selecting what experiment to analyze.
[file] = CT_ExptList_v6();
CT_AssayParams_v6; % Calls the parameters .m file that includes things like the radius of CO2 vs odor assay arenas...
[pathstr, name, ~] = fileparts(file.CL);

%% Import variables from the Index sheet
disp('Reading data from file....');
numworms = importfileXLS(file.CL, 'Index', 'A2');
[num, identity] = xlsread(file.CL, 'Index', 'A1');
[num, wormUIDs] = xlsread(file.CL, 'Index', strcat('B2:B', num2str(1+numworms))); 
[CTorient]=xlsread(file.CL, 'Index', strcat('C2:C', num2str(1+numworms)));

[Ports.ref.Lx]=xlsread(file.CL,'Index',strcat('D2:D',num2str(1+numworms)));
[Ports.ref.Ly]=xlsread(file.CL,'Index',strcat('E2:E',num2str(1+numworms)));
[Ports.ref.Rx]=xlsread(file.CL,'Index',strcat('F2:F',num2str(1+numworms)));
[Ports.ref.Ry]=xlsread(file.CL,'Index',strcat('G2:G',num2str(1+numworms)));
[pixelspercm.CL, txtppcm, ~]=xlsread(file.CL, 'Index', strcat('H2:H',num2str(1+numworms)));
if any(pixelspercm.CL<10)
    error('The Index sheet appears to have at least one pixels per cm column value that is are smaller than expected. Please make sure that column H contains the correct information. Then restart the tracker code.');
end

if size(pixelspercm.CL,1)<numworms % If the number of imported pixels per cm values doesn't match the expected number of worms, pad with NaN, they're probably slopes
   pixelspercm.CL((size(pixelspercm.CL,1)+1):numworms,1)=NaN;
end

tracklength = importfileXLS(file.CL, 'Index', 'A5');


%% Import tracks
[tracks.CL.xvals, tracks.CL.yvals]=ImportTracks(file.CL, wormUIDs, tracklength, numworms); 
disp('...done.');

%% Main Chemotaxis Analysis
global assaytype % Retrieve the global variable assaytype defined in CT_ExptList. 1 = Odor Assay; 2 = CO2 Assay
disp('Analyzing and plotting');
[newPorts, pixelpercmarray] = CT_ScaleAdjustments_v6 (tracks.CL.xvals, tracks.CL.yvals, pixelspercm.CL, Ports.ref);
[tracks.CL.xvalscm, tracks.CL.yvalscm, Ports.tracks, Ports.refcm,pathlength, distanceratio, meanspeed, instantspeed, finaldisp]=CT_AnalyzeTracks_v6(tracks.CL.xvals, tracks.CL.yvals, pixelspercm.CL, newPorts, pixelpercmarray);
[plotxvals, plotyvals, EndLoc, CportStdLoc]= CT_Convert_v6 (tracks.CL.xvalscm, tracks.CL.yvalscm, CTorient, Ports.tracks, Ports.refcm, finaldisp);

%% Run additional analyses depending on the type of assay (Odor vs CO2)
if assaytype == 1 || assaytype == 3 || assaytype == 4
    [zonetime, nfinal, neutZone] = CT_Odor_Quantification_v6 (plotxvals, plotyvals,CportStdLoc);
elseif assaytype == 2
    [zonetime, nfinal, neutZone] = CT_CO2_Quantification_v6 (plotxvals,CportStdLoc);
end

%% Plotting and Saving
if ~exist(fullfile(pathstr,name),'dir')
    mkdir([fullfile(pathstr,name)]);
end

CT_TrackPlotter_v6(plotxvals, plotyvals, CportStdLoc, neutZone, name, pathstr, subsetplot, individualplots);

headers={'Distance_Ratio', 'Mean_Speed_cm_per_s', 'Pathlength_cm', 'Final_Location_Relative_to_Control_cm', 'Final_Location_Relative_to_Experimental_cm', 'Time_in_Control_Zone_sec', 'Time_in_Experimental_Zone_sec'};
T=table(distanceratio', meanspeed', pathlength', EndLoc.Cport', EndLoc.Eport', zonetime.C',zonetime.E','VariableNames',headers);
writetable(T,fullfile(pathstr,name,strcat(name,'_results.xlsx')));
TT=table(nfinal.C, nfinal.E, 'VariableNames', {'number_of_worms_ending_in_Control_Zone', 'number_of_worms_ending_in_Experimenal_Zone'});
writetable(TT,fullfile(pathstr,name, strcat(name,'_Ctrls_vs_Exp_count.xlsx')));
TTT=table(instantspeed,'VariableNames',{'InstantSpeed'});
writetable(TTT,fullfile(pathstr,name,strcat(name,'_instantspeed.xlsx')));

close all
disp('Finished Analyzing Worm Tracks!');
end


