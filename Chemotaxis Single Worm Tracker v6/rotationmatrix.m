function [Xrot, Yrot, Portxrot, Portyrot] = rotationmatrix(tracksx, tracksy, portx, porty);
% A rotation matrix is used to perform a rotation in Euclidean space. It
% establishes a cartesian coordinate system, and rotates the points in the
% plane around the origin.

% Written by Astra S. Bryant 4/4/2019


% When rotating (x, y) by alpha degrees:
% x' = x cos alpha - y sin alpha
% y' = x sin alpha + y cos alpha

% As a matrix:
% (x',y') = (x,y) * [cos alpha, -sin alpha; sin alpha, cos alpha]

% INPUTS:
% tracksx, tracky: x and y track coordinates that need to be rotated, 
% portx, porty: x and y coordinated of non-aligned port, used to calculate angle of rotation

% OUTPUTS:
% Xrot: x values, rotated
% Yrot: y values, rotated
% Portxrot: Rotated x location of non-aligned port
% Portyrot: Rotated y location of non-aligned port

% Step 1: Determine the angle (in radians) that the port is offset from the
% origin
alpha = atan2(porty,portx); %to convert this to degrees: alpha * (180/pi)
s = sin (-alpha);
c = cos (-alpha);

% Step 2: Rotate each worm by the appropriate angle
for i = 1:size(tracksx,2)
    A = [tracksx(:,i)'; tracksy(:,i)'];
    B = [portx(i); porty(i)];
    
    R = [c(i), -s(i); s(i), c(i)]; % Rotation Matrix
    Arot = R * A;
    Brot = R * B;
    
    % Saving the rotated worm tracks
    Xrot(:,i)=Arot(1,:)'; 
    Yrot(:,i)=Arot(2,:)';
    
    %Saving the rotated adjusted Port locations
    Portxrot(i,1)= Brot(1);
    Portyrot(i,1) = Brot(2);
end


end