%% Problem Specification

groupNum = 7;

% Power to be delivered [W]
powerToDeliver = (mod(groupNum, 5) * 5) + 20;

% Steady-state input speed [rpm]
inputSpeed = (mod(groupNum, 6) * 100) + 1750;

% Maximum input speed [rpm]
inputSpeedMax = inputSpeed * 1.20;

% Minimum speed reduction (20:1)
speedReduction_min = 20;

% Output speed nominal[rpm]
outputSpeed = inputSpeed / speedReduction_min;

% Output speed Max[rpm]
outputSpeedMax = inputSpeedMax / speedReduction_min;

% Output Torque nominal [Nm]
torqueOutput = powerToDeliver * 745.7 / outputSpeed * pi/30;

% Output Torque Max [Nm]
torqueOutputMax = powerToDeliver * 745.7 / outputSpeedMax * pi/30;

%% Speed, Torque, and Gear Ratios

% Gear ratio ( = # pinion teeth / # gear teeth)
gearRatio = 1 / speedReduction_min;

% Let both stages of reduction be the same, to minimize package size. Also,
% this results in input and output shaft being in line with each other.
% So, each individual reduction is simply the square root of the overall
% gear ratio.

% Gear ratio: # of gear teeth to # of pinion teeth for Eq. 13-11
m_G = 1 / sqrt(gearRatio);

% Pressure angle [deg]
pressureAngle = 20;

% Smallest number of pinion teeth without interference (round up). 
% (Eq. 13-11). Full depth teeth: k = 1.
N_P = 2 / ( (1 + 2*m_G) * (sind(pressureAngle))^2 ) ...
      * (m_G + sqrt(m_G^2 + (1 + 2*m_G) * (sind(pressureAngle))^2));

N_P = ceil(N_P);    % Round up to the nearest integer

% Number of teeth
N_2 = N_P;
N_4 = N_P;

N_3 = m_G * N_2;    % 71.55: try rounding up
N_3 = ceil(N_3);