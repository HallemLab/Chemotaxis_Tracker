function[] = circle (xycenter, r, facecolor, edgecolor, edgethickness)
%% Draws a circle of radius 'r' centered around a given x,y coordinate.

% Inputs:
%   r = radius
%   xycenter = 1x2 array containing x,y coordinates of the center of the
%   circle
%   facecolor =  array defining fill color
%   edgecolor =  array defining edge color
%   edgethickness = thickeness of edge line

%% Revision History
%   8-12-19 created by ASB

%% Code
if ~exist('edgethickness')
    edgethickness = 1;
end

theta = rad2deg(0:pi/500:2*pi);%linspace(0,360, 100); % calculating the arc of the circular segment
% Define x and y using "Degrees" version of sin and cos.
x = r * cosd(theta) + xycenter(1); 
y = r * sind(theta) + xycenter(2); 
patch(x, y,'k','FaceColor',facecolor,'EdgeColor',edgecolor, 'LineWidth',edgethickness);