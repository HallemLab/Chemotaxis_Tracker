function [n, nfinal, neutZone]= CT_CO2_Quantification_v6(plotxvals, CportStdLoc)
%%  File Description
%   Like the function name says, this function includes additional 
%   analyses specific for for single-worm CO2 tracking assays. 
%
%   Currently, calculating number of worms that end in scoring regions, as
%   well as time spent in scoring regions by individual worms.
% 
%   Version 6.0
%   Version Date: 12/2/19
%
%%  Inputs/Outputs
%   Inputs:
%       plotxvals: the compiled xvals of worm tracks, standardized to the
%       "experimental" port. Using this I can easily calculate the amount of time
%       the worm spends on the experimental side vs control side of its starting
%       position.
%
%   Outputs:
%       n.E, n.C: the amount of time (in seconds) that individual worms spent
%       outside of a 1 cm neutral exclusion zone towards the Experimental or
%       Control sides.
%       nfinal.E, nfinal.C: the number of animals that end the experiment in the
%       experimental zone and the control zone
%       nenter.E, nenter.C: the number of animals that enter the
%       experimental zone and the control zone at least once. This value is
%       currently commented out.
%
%%  Revision History
%   4/4/19      Created by Astra S. Bryant.
%   8/27/19     Renamed CT_CO2_MoreQuantification_v4
%   9/24/19     Renamed version 5
%   12/2/19     Renamed version 6

%% Time spend on experimental vs control side 
% A pretty easy calculation, given that the x values are aligned to the
% experimental port (at the origin). Will exclude a 1 cm neutral zone
% centered on the median between the two ports.

neutZone.center = median(CportStdLoc.x/2); %in cm
neutZone.lowerlimit= neutZone.center - 0.5; %in cm
neutZone.upperlimit= neutZone.center + 0.5; %in cm

cE = plotxvals<neutZone.lowerlimit; % a lower x value than the lower bound of the neutral zone means the worm is towards the experimental port and outside the neutral zone.
cC = plotxvals > neutZone.upperlimit; % a higher x value than the upper bound of the neutral zone means the worm is towards the control port and outside the neutral zone.
   
nE = arrayfun(@(x) nnz(cE(:,x)), 1:size(plotxvals,2)); % applying the function nnz to every x column in cE
nC = arrayfun(@(x) nnz(cC(:,x)), 1:size(plotxvals,2)); % applying the function nnz to every x column in cC

n.E=nE*2; % assuming 1 frame/ 2 seconds - this tells us the amount of time (number of seconds) the worm spent closer to the experimental side.
n.C=nC*2; % assuming 1 frame/ 2 seconds - this tells us the amount of time (number of seconds) the worm spent closer to the control side.

%% Number of animals that end the assay on the experimental vs control side
% First find the end of the track
B= ~isnan(plotxvals);
Indices = arrayfun(@(x) find(B(:,x),1,'last'), 1:size(plotxvals,2)); % logical array

% For how many worms is the final x position on the experimental side?
    fE = arrayfun(@(x,y) cE(x,y), Indices, 1:size(plotxvals,2));
    nfinal.E = nnz(fE); % number of nonzero elements

    % Is the final x position on the control side?
    fC = arrayfun(@(x,y) cC(x,y), Indices, 1:size(plotxvals,2));
    nfinal.C = nnz(fC);  % number of nonzero elements

%% Number of animals entering experimental vs control side
% Currently, this value is +1 if an animal ever enters an active zone; it
% does not add more counts in the animal enters multiple times
%     nenter.E = nnz(nE); % number of non-zero elements in the count of how many frames each worm was in the experimental zone
%     nenter.C = nnz(nC); % number of non-zero elements in the count of how many frames each worm was in the control zone

end
