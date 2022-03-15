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

%%