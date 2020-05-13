function [C1xvalscm, C1yvalscm, tracks, aPort, pathlength, distanceratio, meanspeed, instantspeed, finaldisp] = CT_AnalyzeTracks_v6(C1xvals, C1yvals, C1ppcm, Ports, pixelpercmarray)
%%  Function Description
%   AnalyzeTracks.m Modular function for taking worm tracks, represented as
%   x-, y-coordinates in pixels, and turning them in to cm values. Will take
%   both a single camera input 
%   
%   Inputs: C1xvals, C1yvals = x- and y- coordinates from a primary camera
%   C1ppcm = pixels per cm for the primary camera, one value per worm. 
%   Ports = structure array containing the xy coordinates of the control
%   and experimental "Ports"
%    
%   Outputs: C1xvalscm, C1yvalscm, pathlength, distance ratio, mean spead,
%   instantaenous speed, final location relative to each "port"
%
%   Version 6.0
%   Version Date: 12/2/19
%
%%  Revision History
%   12-31-17    Created by Astra S. Bryant
%   3-18-19     Edited to remove the dual camera input, which is not
%               necessary for chemotaxis station. (ASB)
%   8-27-19     Updated so that the pixels per cm value is declared for each
%               track, to account for the addition of multiple worm tracking setups.
%               Also updating/cleaning up the commenting. (ASB)
%   9-23-19     Updated so that for CO2 assays, the location of the ports
%               is shifted to account for the x/y values being the edge of
%               the port, rather than the center. Also added in functionality
%               so that if the pixels per cm value is in fact a range that varies across the y-axis, 
%               that range is calculated for each Y value, and applied. (ASB)
%   9-24-19     Removed functionality added on 9-23-19, placed in new .m
%               file named CT_ScaleAdjustments_v5. Updated this version to
%               _v5.
%   12/2/19     Renamed version 6

%% Code

% Generate worm track values relative to Port L location (Port L at 0,0).
% CTorient input would be 1
tempx=repmat(Ports.Lx_cm',size(C1xvals,1),1);
tempy=repmat(Ports.Ly_cm',size(C1yvals,1),1);

tracks.Lxunrot=(C1xvals./pixelpercmarray)-tempx;
tracks.Lyunrot=(C1yvals./pixelpercmarray)-tempy;

aPort.Rxunrot=(Ports.Rx_cm-tempx(1,:)'); %Generating Port R location relative to Port L
aPort.Ryunrot=(Ports.Ry_cm-tempy(1,:)'); 

[tracks.Lx, tracks.Ly, aPort.Rx, aPort.Ry]=rotationmatrix(tracks.Lxunrot, tracks.Lyunrot, aPort.Rxunrot, aPort.Ryunrot);

% Generate worm track values relative to Port R location (Port R at 0,0)
% CTorient input would be 0
tempxx=repmat(Ports.Rx_cm',size(C1xvals,1),1);
tempyy=repmat(Ports.Ry_cm',size(C1yvals,1),1);

tracks.Rxunrot=(-C1xvals./pixelpercmarray)+tempxx;
tracks.Ryunrot=(C1yvals./pixelpercmarray)-tempyy;

aPort.Lxunrot=(-Ports.Lx_cm + tempxx(1,:)'); %Generating Port L location relative to Port R
aPort.Lyunrot=(Ports.Ly_cm-tempyy(1,:)');

[tracks.Rx, tracks.Ry, aPort.Lx, aPort.Ly]=rotationmatrix(tracks.Rxunrot, tracks.Ryunrot, aPort.Lxunrot, aPort.Lyunrot);


%% Calculate path and max displacement for generating a distance ratio, in combination with the maximum distance moved.
% I currently don't need the travelpath and pathlength data, but it might
% come in handy later. Since these values are already relative, I'm using
% the ones that aren't adjusted relative to the input ports.
C1xvalscm=C1xvals./pixelpercmarray;
C1yvalscm=C1yvals./pixelpercmarray;

[maxdisplacement pathlength meanspeed instantspeed]= displace([C1xvalscm(1,:);C1yvalscm(1,:)], C1xvalscm, C1yvalscm);
distanceratio=pathlength./maxdisplacement; %Calculation of distance ratio, as defined in Castelletto et al 2014. Total distance traveled/maximum displacement.

%% Calculating final resting place of each worm relative to the left and right ports.

%Calculating final displacement relative to left port
displacement.L =sqrt((tracks.Lx-0).^2 + (tracks.Ly-0).^2);
B= ~isnan(displacement.L);
Indices = arrayfun(@(x) find(B(:,x),1,'last'), 1:size(displacement.L,2));
finaldisp.L = arrayfun(@(x,y) displacement.L(x,y), Indices, 1:size(displacement.L,2));

%Calculating final displacement relative to right port
displacement.R =sqrt((tracks.Rx).^2 + (tracks.Ry).^2);
B= ~isnan(displacement.R);
Indices = arrayfun(@(x) find(B(:,x),1,'last'), 1:size(displacement.R,2));
finaldisp.R = arrayfun(@(x,y) displacement.R(x,y), Indices, 1:size(displacement.R,2));

end




