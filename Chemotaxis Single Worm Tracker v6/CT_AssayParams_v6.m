function CT_AssayParams_v6()

%% File description
%   This file is a parameters file in which users can easily set various
%   parameters associated with single worm chemotaxis tracking assays. All
%   the variables here will be global, the aid interfacing with the
%   CT_WormTracks codebase.
%
%   Version 6.0
%   Version Date: 12/2/19
%
%%  Revision History
%   8-27-19     Created by Astra S. Bryant
%   9-24-19     Renamed Version 5
%   12-2-19     Renamed Version 6. Added additional assay types, including: pheromone assay,
%               odor assay, renamed old odor assay to bacterial chemotaxis
%               assay. (ASB)

%% Code
global assaytype % Retrieve the global variable assaytype defined in CT_ExptList. 1 = Odor Assay; 2 = CO2 Assay
global radius
global scoringradius
global portradius
global inter_port_interval

if assaytype == 1
    radius = 4.9/2; % radius of bacterial chemotaxis assay circle
    scoringradius = 2/2; % radius of scoring circles
    inter_port_interval = (radius*2)-(scoringradius*2); % calculate distance between centers of two ports
    disp('Bacterial Chemotaxis Assay Parameters Loaded');
end

if assaytype == 2
    radius = 3.75/2; % radius of CO2 assay circle
    portradius = 0.3175/2; % inner radius of CO2/Air ports
    inter_port_interval = 4.75; % NB measured this distance for ASB on 9/24/19
    disp('CO2 Assay Parameters Loaded');
   
end

if assaytype == 3
    radius = 5/2; % radius of pheromone chemotaxis assay circle; provided to ASB on 12/2/19
    scoringradius = 2/2; % radius of scoring circles
    inter_port_interval = (radius*2)-(scoringradius*2); % calculate distance between centers of two ports
    disp('Pheromone Assay Parameters Loaded');
end

if assaytype == 4
    radius = 5/2; % radius of odor chemotaxis assay circle
    scoringradius = 1/2; % radius of scoring circles
    inter_port_interval = 2; % MLC gave ASB this distance on 12/4/19
    disp('Odor Assay Parameters Loaded');
end

end
