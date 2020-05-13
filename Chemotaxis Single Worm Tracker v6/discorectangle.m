function[] = discorectangle(w, xycenter, r,facecolor, opacity)

%% Draws a discorectangle. 
% Inputs:
%   w = width of the discorectangle
%   xycenter = 1x2 array containing x,y coordinates of the center of the
%       discorectangle
%   r = radius of the circle that defines the arch of the semicircular
%       portion of the discorectangle
%   facecolor =  array defining fill color 
%   opactiy = array defining opacity of the filled region

%% Revision History
%   8-12-19 Created by ASB
%   8-13-19 Edited to make more generalizable (ASB)

%% Code
% Define parameters of the discorectangle (aka the stadium shape).
b = sqrt((r^2 - (w/2)^2)); % 1/2 of height of rectangular section of the discorectangle
h = r - b; % height of the semicircular portion of the discorectangle
discoangle = rad2deg(2*(asin(w/(2*r))));

% Drawing the rectangle portion of the discorectangle
x = [(xycenter(1)-(w/2)) (xycenter(1)-(w/2)) (xycenter(1)+(w/2)) (xycenter(1)+(w/2))];
y= [-b b b -b];
patch(x,y,facecolor, 'FaceAlpha',opacity,'EdgeColor','none');

% Drawing the upper circular segment portion of the discorectangle
theta = linspace(90-(discoangle/2), 90+(discoangle/2), 100); % calculating the arc of the circular segment
% Define x and y using "Degrees" version of sin and cos.
xdisco = r * cosd(theta) + xycenter(1); 
ydisco = r * sind(theta) + xycenter(2); 
patch(xdisco, ydisco,facecolor,'FaceAlpha',opacity, 'EdgeColor','none');

% Drawing the lower circular segment portion of the discorectangle
theta = linspace(270-(discoangle/2), 270+(discoangle/2), 100); % calculating the arc of the circular segment
% Define x and y using "Degrees" version of sin and cos.
xdisco = r * cosd(theta) + xycenter(1); 
ydisco = r * sind(theta) + xycenter(2); 
patch(xdisco, ydisco,facecolor,'FaceAlpha',opacity, 'EdgeColor','none');


end