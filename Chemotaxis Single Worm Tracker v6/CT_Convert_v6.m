function [plotxvals, plotyvals, FinalDist, plotCport] = CT_Convert_v6(xvalscm, yvalscm, CTorient, port_tracks, port_refs, finaldisp)
%%  File Description
%   ChemotaxisConvert.m Modular function that adjusts x/y coordinates of
%   tracked worms (in cm) in relation to the location of a given odorant
%
%   Version 6.0
%   Version Date: 12/2/19
%
%   Inputs:
%   xvalscm, yvalscm: tracks in cm
%   CTorient: information about what orientation the tracks should be in
%   (related to the location of the odor on the plate)
%
%   Outputs:
%   plotxvals, plotyvals = movement of worms along plate, with the
%   orientations altered as set by CTorient
%   FinalDist = final displacements in cm relative to the experimental and control ports
%   plotCport = x and y coordinates of the control port relative to the [0,0] location of the experimental "port" 
%
%%   Revision history:
%       12/31/17    Created by ASB
%       3/20/19     Modified by ASB to collate experimenal vs control side
%                   tracks
%       4/5/19      Renamed v4 by ASB
%       9/24/19     Renamed v5 by ASB
%       12/2/19     Renamed v6 by ASB

tracklength=size(xvalscm,1);

CTorient(CTorient>0)=-1; %Value = 1, experimental port = L
CTorient(CTorient>-1)=1; %Value = 0, experimental port = R
CTorient=CTorient';
CTorient=repmat(CTorient, tracklength,1);

xvalsStd=zeros(size(port_tracks.Lx)); %preallocating arrays to save time
yvalsStd=zeros(size(port_tracks.Ly)); %preallocating arrays to save time

%Collating tracks oriented to the experimental port, also collating control
%port location.
for i=1:size(CTorient,2);
    if CTorient(1,i)<0 % if experimental port = L
        xvalsStd (:,i)= port_tracks.Lx(:,i);
        yvalsStd (:,i)= port_tracks.Ly(:,i);
        CportStd.x (:,i)= abs(port_refs.Rx(i,:)); % then the control port is the Right port
        CportStd.y (:,i)= abs(port_refs.Ry(i,:));
        FinalDist.Eport (:,i)= finaldisp.L(:,i); % final displacements in cm relative to the experimental and control ports
        FinalDist.Cport (:,i)= finaldisp.R(:,i);
     
    else % if the experimental port is Right
        xvalsStd(:,i) = port_tracks.Rx(:,i);
        yvalsStd(:,i) = port_tracks.Ry(:,i);
        CportStd.x(:,i) = abs(port_refs.Lx(i,:)); % then the control port is the left port
        CportStd.y (:,i)= abs(port_refs.Ly(i,:));
        FinalDist.Eport (:,i)= finaldisp.R(:,i); % final displacements in cm relative to the experimental and control ports
        FinalDist.Cport (:,i)= finaldisp.L(:,i);
    end
end



%% Orient tracks depending on the location of the odorant
% This some of this code is based on older code, from when there was no port
% information.

plotxvals = xvalsStd; % This used to involve multiplying with the CTorient, but it doesn't any longer b/c the calculation of distance from the port already does this.
plotyvals = yvalsStd*-1;
plotCport.x = CportStd.x;
plotCport.y = CportStd.y*-1;



end



