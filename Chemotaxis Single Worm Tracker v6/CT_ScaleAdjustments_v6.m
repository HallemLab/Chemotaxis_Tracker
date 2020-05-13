function [newPorts, pixelpercmarray] = CT_ScaleAdjustments_v6 (C1xvals,C1yvals, C1ppcm, Ports)
%%  File Description
%
%   Takes (x,y) coordinates of "ports" for CO2 and Odor assays, and adjusts
%   them to take into account scaling differences in the z-axis of the
%   Chemotaxis Tracking Stations.
%
%   Also, for CO2 assays, the location of the ports
%   is shifted to account for the x/y values being the edge of
%   the port, rather than the center. 
%
%   Has functionality to handle situations where
%   the pixels per cm value is in fact a range that varies across the y-axis, 
%   that range is calculated for each Y value, and applied. (ASB)
%   
%   Version 6.0
%   Version date: 12/2/19
%
%%  Revision History
%   9/24/19     Created by ASB, forked over from CT_AnalyzeTracks_v4.m
%   12/2/19     Renamed v6 (ASB)

%%  Code

%% Retrieve some global variables!
global assaytype % retrieve variable stating type of assay -> 1 = Odor Assay; 2 = CO2 Assay
global portradius % retrieve inner radius of ports for CO2 assay
global inter_port_interval % retrieve variable stating the distance (in cm) between the Ports/Odors


%% Adjusting pixel per cm valuation
pixelpercmarray = repmat(C1ppcm', size(C1xvals,1),1);
Ports.R_ppcmarray = pixelpercmarray(1,:)';
Ports.L_ppcmarray = pixelpercmarray(1,:)';


%   Determine whether the pixels per cm value is a slope (i.e. if this is a
%   case where the camera was on an axis), and if so, generate a pixel per cm array.
%   This applies to CT data collected from ~8/26/19 thru 9/23/19. 
%   In these cases, the angular correction matrix is defined by
%   two measurements: a dependent variable value of 194 pixels per cm when the independent value (y) =100, 
%   and a dependent variable value of 184 pixels per cm when the idependent variable (y)=954. 
%
%   Critically, this assumes that the camera position didn't move, but is
%   agnostic to where in the stationary field of view the assay plate was
%   placed. It also assumes that the rotation was only in the y axis.

if sum(isnan(C1ppcm))>0 
    %   Slope Parameters, hardwired for the known measurements collected
    %   in the date range of ~8/26/19 - 9/23/19. If there is another
    %   instance where the camera is at an angle, these values could be
    %   made as variables. Just make sure to put the 1cm measurements as
    %   the "y" values in polyfit (they're the dependent variable).
    coefficients = polyfit([954,100],[184,194],1);
    m=coefficients(1); % slope 
    b=coefficients(2); % intersect 
    ppcm_sloped_index = find(isnan(C1ppcm));
    
    for i=1:size(ppcm_sloped_index,1)
        pixelpercmarray(:,ppcm_sloped_index(i))=(m*C1yvals(:,ppcm_sloped_index(i)))+b;
        Ports.R_ppcmarray(ppcm_sloped_index(i))=(m*Ports.Ry(ppcm_sloped_index(i)))+b;
        Ports.L_ppcmarray(ppcm_sloped_index(i))=(m*Ports.Ly(ppcm_sloped_index(i)))+b;
    end
end

% For CO2 assays, the location of the Ports needs to be shifted out 1
% radius, as the values given are the edge of the port, rather than the
% center.
if assaytype == 2
    Ports.Lx = Ports.Lx - (C1ppcm * portradius); % shift left port x location to the left by the port radius in pixels
    Ports.Rx = Ports.Rx + (C1ppcm * portradius); % shift right port x location to the right by the port radius in pixels
end

%% Adjust the size of the measured "port" coordinates to account for
% z-axis distortion

%   Convert port locations in pixels to locations in cm
Ports.Lx_cm = Ports.Lx./Ports.L_ppcmarray;
Ports.Ly_cm = Ports.Ly./Ports.L_ppcmarray;
Ports.Rx_cm = Ports.Rx./Ports.R_ppcmarray;
Ports.Ry_cm = Ports.Ry./Ports.R_ppcmarray;

%   Determine the distance between the ports
displacement_ports_cm = sqrt((Ports.Lx_cm-Ports.Rx_cm).^2 + (Ports.Ly_cm-Ports.Ry_cm).^2);

%   Determine the offset between the inputted inter-port distance, and the
%   expected distance for Odor or CO2 assays
offset_ports_cm = repmat(inter_port_interval, size(displacement_ports_cm,1),1) - displacement_ports_cm;

%% Shift the ports along the line connecting them, such that they equal the expected distance between the ports.
% This uses trigonometry

% Shift left ports by a negative of the offset
newPorts.Lx_cm = Ports.Lx_cm - (((-offset_ports_cm./2) .* (Ports.Lx_cm - Ports.Rx_cm))./displacement_ports_cm);
newPorts.Ly_cm = Ports.Ly_cm - (((-offset_ports_cm./2) .* (Ports.Ly_cm - Ports.Ry_cm))./displacement_ports_cm);

% Shift right ports by a positive value of offset 
newPorts.Rx_cm = Ports.Rx_cm - (((-offset_ports_cm./2) .* (Ports.Rx_cm - Ports.Lx_cm))./displacement_ports_cm);
newPorts.Ry_cm = Ports.Ry_cm - (((-offset_ports_cm./2) .* (Ports.Ry_cm - Ports.Ly_cm))./displacement_ports_cm);

end



