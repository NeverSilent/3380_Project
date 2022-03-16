%% Problem Specification

group_num = 7;

% Power to be delivered [W]
power_to_deliver = (mod(group_num, 5) * 5) + 20;

% Steady-state input speed [rpm]
input_speed = (mod(group_num, 6) * 100) + 1750;

% Maximum input speed [rpm]
input_speed_max = input_speed * 1.20;

% Minimum speed reduction (20:1)
speed_reduction_min = 20;

% Output speed [rpm]
output_speed = input_speed / speed_reduction_min;

%% Speed, Torque, and Gear Ratios

% Gear ratio ( = # pinion teeth / # gear teeth)
gear_ratio = 1 / speed_reduction_min;

% Let both stages of reduction be the same, to minimize package size. Also,
% this results in input and output shaft being in line with each other.
% So, each individual reduction is simply the square root of the overall
% gear ratio.

% Gear ratio: # of gear teeth to # of pinion teeth for Eq. 13-11
m_G = 1 / sqrt(gear_ratio);

% Pressure angle [deg]
pressure_angle = 20;

% Smallest number of pinion teeth without interference (round up). 
% (Eq. 13-11). Full depth teeth: k = 1.
N_P = 2 / ( (1 + 2*m_G) * (sind(pressure_angle))^2 ) ...
      * (m_G + sqrt(m_G^2 + (1 + 2*m_G) * (sind(pressure_angle))^2));

N_P = ceil(N_P);    % Round up to the nearest integer