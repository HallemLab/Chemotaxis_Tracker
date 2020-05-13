function [n, nfinal, neutZone]= CT_Odor_Quantification_v6(plotxvals, plotyvals, CportStdLoc)
%% File Description
%   Like the function name says, this function includes additional
%   analyses for single-worm odor tracking assays.
%
%   Currently, calculating number of worms that end in scoring circles/region with a globally defined size, as
%   well as time spent in scoring circles/region by individual worms.
%
%   Version 6.0
%   Version Date: 12/2/19
%
%% Inputs/Outputs
% Inputs:
% plotxvals, plotyvals: the compiled xvals of worm tracks, standardized to the
% "experimental" port. Using this I can easily calculate the amount of time
% the worm spends in the experimental vs control side scoring circles.
%
% Outputs:
% n.E, n.C: the amount of time (in seconds) that individual worms spent
%   inside Experimental or Control scoring regions of predetermined radius. 
% nfinal.E, nfinal.C: the number of animals that end the experiment in the
%   experimental scoring region and the control scoring region
% nenter.E, nenter.C: the number of animals that enter the
%   experimental scoring region and the control scoring region at least once. This value is
%   currently commented out.
%
%% Revision History
%   8/27/19     Forked over from CT_CO2_MoreQuantification_v4, to be adjusted so it does the quantification using assay circles by ASB
%   8/28/19     Adjusting scoring regions so they are circular (ASB).
%   9/24/19     Renamed v5 (ASB)
%   12/2/19     Renamed v6 (ASB)

%% Time spend on experimental vs control scoring circle 
% A pretty easy calculation, using the pythagorean theorem to determine if 
% the distance of the worm from the center of the experimental/control scoring region is less th
% less than the radius of the circular scoring region. 
% No exclusion zone here.

% Define control and experimental scoring regions
global scoringradius % import global variable defining the radius of the scoring circles

% Define x and y coordinates of the control of the control scoring circle
CtrlSR.center(1) = median(CportStdLoc.x); 
CtrlSR.center(2) = median(CportStdLoc.y);

% Resize CportStdLoc matrix so we can do the matrix subtraction while
% calculating displacement
tempCportStdLoc.x=repmat(CportStdLoc.x,[size(plotxvals,1),1]);
tempCportStdLoc.y=repmat(CportStdLoc.y,[size(plotxvals,1),1]);

% By definition the experimental scoring circle is centered at [0,0]
ExptSR.center(1) = [0];
ExptSR.center(1) = [0];

neutZone.center = median(CportStdLoc.x/2); %in cm - Center of arena

% Calculate displacement of tracks relative to center of each tracks control and experimental scoring circle. 
displacement.C = sqrt((plotxvals-tempCportStdLoc.x).^2 + (plotyvals-tempCportStdLoc.y).^2);
displacement.E = sqrt((plotxvals-0).^2 + (plotyvals-0).^2); % By definition the experimental scoring circle is centered at [0,0]

% Generating logical arrays for if a worm is within the experimental or
% control scoring region. 0 = not in the score region, 1 = within the
% scoring region
cC = displacement.C<=scoringradius ;% if the displacement from control center (aka hypoteneus) is less  than the radius of the scoring region, the worm is within the control scoring zone.
cE = displacement.E<=scoringradius ;% if the displacement from experimental center (aka hypoteneus) is less  than the radius of the scoring region, the worm is within the experimental scoring zone.

% How many timepoints does each worm spend within the experimental or control zone 
nE = arrayfun(@(x) nnz(cE(:,x)), 1:size(plotxvals,2)); % applying the function nnz to every x column in cE
nC = arrayfun(@(x) nnz(cC(:,x)), 1:size(plotxvals,2)); % applying the function nnz to every x column in cC

n.E=nE*2; % assuming 1 frame/ 2 seconds - this tells us the amount of time (number of seconds) the worm spent within the experimental scoring region.
n.C=nC*2; % assuming 1 frame/ 2 seconds - this tells us the amount of time (number of seconds) the worm spent within the control scoring region.

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
