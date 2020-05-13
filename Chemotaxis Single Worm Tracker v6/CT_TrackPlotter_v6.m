function [] = CT_TrackPlotter_v6(xvals,yvals,CPortStdLoc, neutZone,name,pathstr, subsetplot, individualplots)
%% File Description
%   TrackPlotterCT.m Modular function for plotting worm tracks in a chemotaxis
%   setup.
%
%   Version 6.0
%   Version date: 12/4/19
%
%
%%   Revision history:
%       2/1/18      Created by Astra S. Bryant 
%       3/20/19     Adapted for NB and FR (ASB) 
%       4/5/19      added functionality, incl: plot of random subset of tracks, grey shaded box indicating neutral zone (ASB) 
%       5/05/19     Changed to include individual figures (FR) 
%       6/3/19      Added cbrewer functionality for color plots (ASB)
%       6/18/19     Fixed a bug that I don't understand that was altering how the .eps file was being exported. See: https://www.mathworks.com/matlabcentral/answers/92521-why-does-matlab-not-export-eps-files-properly (ASB) 
%       8/12/19     Updated so that the assay is in a circle, rather
%                   than a square. Altered the exclusion zone so its not a rectangle,
%                   but rather a discorectangle (aka a stadium). 
%       8/13/19     Upgraded the stars of
%                   the ports to a larger circle centered around the average position,
%                   with an accurate-to-reality diameter. Also now exluding portions of tracks that go outside the scoring arena (ASB)
%       8/27/19     Updated to use global variables that determine whether the
%                   thing being plotted is a CO2 assay or an odor assay.
%       8/30/19     Added- "Make individual plots for each track" (FR) [See
%                   next note, ASB]
%       9/20/19     Added 'Interpreter','none' to title() call. Also adjusted FR edit from 8/30/19 that added duplicate code
%                   while ignoring the logical trigger. (ASB)
%       9/23/19     Changed how cbrewer color schemes were generated in
%                   DrawThePlot - this will remove some warning messages that
%                   were popping up. Also made the individual plots
%                   invisible as they're being generated, b/c that many
%                   figure windows was annoying.
%       9/24/19     Renamed version 5
%       12/4/19     Renamed version 6, moved generating the lobical variables subsetplot and
%                   individual plots to CT_WormTracks_v6 so they'll be
%                   easier for users to find.


%% Retrieve some global variables!
global radius % retrieve radius of assay circle

%% Cleaning up the data for plotting
% Given the radius of the asasy circle, remove track elements that go
% beyond the circle. I can use displace.m for this. calculate the
% displacement of each track relative to the center of the assay.
assayorigin = [neutZone.center,0]; % Center of the assay circle
[maxdisplacement pathlength meanspeed instantspeed displacement]= displace ([(repmat(assayorigin(1),1,size(xvals,2)));(repmat(assayorigin(2),1,size(yvals,2)))],xvals, yvals);

% Trim plotting values to exclude points that fall outside the assay zone.
xvals(displacement > radius) = NaN;
yvals(displacement > radius) = NaN;

%% Make a plot with all the tracks, then save it.
DrawThePlot(xvals, yvals, neutZone, assayorigin, CPortStdLoc, name);
saveas(gcf, fullfile(pathstr,[name,'/', name, '-all.eps']),'epsc');
saveas(gcf, fullfile(pathstr,[name,'/', name,'-all.png']));


%% Make a plot with a random subset of the tracks
if subsetplot>0;
    if size(xvals,2)>10;
        plotit = 1;
        while plotit>0 % loop through the subset plotter until you get one you like.
            n = 10; % number of tracks to plot
%             C=cbrewer('qual','Dark2',n,'PCHIP');
%             set(groot,'defaultAxesColorOrder',C);
            rng('shuffle'); % Seeding the random number generator to it's random.
            p = randperm(size(xvals,2),n);
            
            DrawThePlot(xvals(:,p), yvals(:,p), neutZone, assayorigin, CPortStdLoc, strcat(name, ' subset'));
            
            answer = questdlg('Plot it again?', 'Subset Plot', 'Yes');
            switch answer
                case 'Yes'
                    plotit=1;
                case 'No'
                    plotit=-1;
                case 'Cancel'
                    plotit=-1;
            end
        end
        
        set(gcf, 'renderer', 'Painters');
        saveas(gcf, fullfile(pathstr,[name,'/', name, '-subset.eps']),'epsc');
        saveas(gcf, fullfile(pathstr,[name,'/', name,'-subset.png']));
    end
    
end

%% Make individual plots for each track

if individualplots>0
    disp('Plotting and saving individual plots, invisibly');
    set(0,'DefaultFigureVisible','off');
    for i=1:size(xvals,2)
        DrawThePlot(xvals(:,i), yvals(:,i), neutZone, assayorigin, CPortStdLoc, strcat(name, ' - Worm ',num2str(i)));
        saveas(gcf, fullfile(pathstr,[name, '/', name, ' - Worm ',num2str(i),'.png']),'png');
    end
    set(0,'DefaultFigureVisible','on');
end
 end

%% The bit that makes the figure
% Oh look, an inline script!

function DrawThePlot(xvals, yvals, neutZone, assayorigin, CPortStdLoc, name)
% Retrieve some global variables!
global assaytype % retrieve variable stating type of assay -> 1 = Odor Assay; 2 = CO2 Assay
global radius % retrieve radius of assay circle
global portradius % retrieve inner radius of ports for CO2 assay
global scoringradius % retrieve radius of scoring circles for odor assay


figure;
movegui('northeast');
C=cbrewer('qual','Set1',size(CPortStdLoc.x,2),'PCHIP');
set(groot,'defaultAxesColorOrder',C);
hold on;

% Drawing assay arena circle
circle(assayorigin,radius, 'none', 'k');

% Assay-specific things
if assaytype == 1 || assaytype == 3 || assaytype == 4 % Odor Assays
    circle([median(CPortStdLoc.x), median(CPortStdLoc.y)],scoringradius,'none','k');
    circle([0,0], scoringradius,'none','r');
elseif assaytype ==2 %% CO2 Assay
    discorectangle((neutZone.upperlimit - neutZone.lowerlimit),[neutZone.center,0],radius,'k',0.3);
    circle([median(CPortStdLoc.x), median(CPortStdLoc.y)],portradius,'k','none');
    circle([0,0], portradius,'r','none');
end

% Drawing Tracks
plot(xvals, yvals, 'LineWidth',1);
plot(xvals(1,:),yvals(1,:),'k+'); % plotting starting locations


hold off

% Labeling the figure and saving
ylabel('Distance (cm)'); xlabel('Distance (cm)');
axis('equal');
title(name,'Interpreter','none');
set(gcf, 'renderer', 'Painters');
end
