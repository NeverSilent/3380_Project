%First part of the gear specification


groupNum = 7;

% Power to be delivered [hp]
powerToDeliver = (mod(groupNum, 5) * 5) + 20;

% Steady-state input speed [rpm]
inputSpeed = (mod(groupNum, 6) * 100) + 1750;

% Maximum input speed [rpm]
inputSpeedMax = inputSpeed * 1.20;

% Minimum speed reduction (20:1)
speedReduction_min = 20;

% Output speed [rpm]
outputSpeed = inputSpeed / speedReduction_min;

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

% Gear teeth calculations
N_2 = N_P;
N_4 = N_P;

N_3 = ceil(N_2 * m_G);
N_5 = N_3;

%Angular velocity in rpm (revolution/min)
w_5 = (N_2/N_3)*(N_4/N_5)*inputSpeed;


train_value_e = (N_2/N_3)*(N_4/N_5);
w_2 = inputSpeed;
w_3 = (N_2/N_3)*inputSpeed;
w_4 = w_3;

%Power relationship

%Torque in N*m so we have to perform a unit conversion
%hp to W, rpm to rad/s to get N*m

T_2 = (powerToDeliver*745.7)/(w_2*((2*pi)/60));
T_3 = T_2 * (w_2/w_3);
T_4 = T_3;
T_5 = T_2 * (w_2/w_5);



%Second part of the gear specification

%Assumption in m
gear_box_height_Y = 0.55;
clearance = 0.05;
wall_thickness = 0.03;


%Equation 18-3
%Solving for P_minimum, minimum diametral pitch
%Number of teeth per diameter of the gear

P_minimum = (N_3 + (N_2/2) + (N_5/2) + 2)/(gear_box_height_Y-clearance-wall_thickness);

%We get 251.0638 teeth/m for the minimum diametral pitch
%Round up to 252 teeth/m

P = ceil(P_minimum);
P_inch = ceil(P_minimum/39.3701);


%Getting the gear diameters from the selected diametral pitch, P
%Diameters are in m
d_2 = N_2/P;
d_3 = N_3/P;
d_4 = N_4/P;
d_5 = N_5/P;

d_2_inch = 39.3701*d_2;
d_3_inch = 39.3701*d_3;
d_4_inch = 39.3701*d_4;
d_5_inch = 39.3701*d_5;

%Pitch-line velocity and transmitted loads
%Pitch-line velocity in m/min
%transmitted load in N*m, conversion of hp to W is required

%Equation 13-34 for the pitch-line velocity in ft/min
V_23 = (pi*d_2_inch*w_2)/12;
V_45 = (pi*d_5_inch*w_5)/12;

%Equation 13-35 for the transmitted load in lbf
W_23 = (33000*powerToDeliver)/V_23;
W_45 = (33000*powerToDeliver)/V_45;


%Gear 4 is evaulated first because it is the smallest one that 
%is most likely to be critical. (Limiting factor)

%Equation 14-23 for geometry factor, I
%Use 1 for the load sharing ratio since we are using spur gear
load_sharing_ratio = 1;
I_Geo = ((cos(pressureAngle)*sin(pressureAngle))/(2*load_sharing_ratio))*(m_G/(m_G+1));

%Equation 14-28 to find A and B values for 14-27
%Assume Q_v=7
Q_v = 7;
B_dyn = 0.25*((12-Q_v)^(2/3));
A_dyn = 50 + 56*(1-B_dyn);

%Equation 14-27 for the dynamic factor, K_v. Use inch for V (For later
%calculations)
K_v = ((A_dyn + sqrt(V_45))/(A_dyn))^B_dyn;

%Face width in m, trying 4 times the diametral pitch
face_width = 4*(pi/P);

%Load distribution factor
%Calculate everything in inch and then convert back to m

%Equation 14-31
%Uncrowned
C_mc = 1;

face_width_inch = face_width*39.3701;

%Equation 14-32
%face_width_inch is larger than 1 inch and less than 17 inch

C_pf = (face_width_inch/(10*d_4_inch))-0.0375+(0.0125*face_width_inch);

%Equation 14-33
%Straddle mounted

C_pm = 1;

%Equation 14-34
%Commercial enclosed unit

A_Cma = 0.127;
B_Cma = 0.0158;
C_Cma = -0.0000930;

C_ma = A_Cma + B_Cma*face_width_inch + C_Cma*(face_width_inch^2);

%Equation 14-35
%All other condition

C_e = 1;

%Equation 14-30

K_m = 1 + C_mc*(C_pf*C_pm + C_ma*C_e);

%Table 14-8, steel, for psi
C_p = 2300;

%Assume Ko, Ks, Cf value to be 1.
%14-16
%Contact stress in psi
Contact_stress_4 = C_p*sqrt((W_45*K_v*K_m)/(d_4_inch*face_width_inch*I_Geo));

%Number of cycles for 12000 hours
%L_4 in rev
L_4 = 12000 * 60 * w_4;

%Figure 14-15 using L_4
Z_N = 0.89;

%Assuming K_R, K_T, C_H = 1
%Assuming Safety Factor of 1.2 (S_H)
S_H = 1.2;
%Gear contact strength in psi
S_c = (S_H * Contact_stress_4)/Z_N;


%Table 14-6
%We need Grade 3, Carburized and Hardened heat treatment
%It gives 275000 psi of gear contact strength 
% that is larger than 261330 psi
%Achieved FOS
n_c = (275000*Z_N)/Contact_stress_4;


%GEAR 4 bending
%From figure 4, we have 16 teeth on gear 4 and 72 teeth on mating gear
J_geo_4 = 0.27;

%Equation 14-15
%Using the same values except J and K_B = 1
Stress_num_bending_4 = (W_45*K_v*P_inch*K_m)/(face_width_inch*J_geo_4);

%Stress number for bending for gear 4 is 70059 psi
%Using figure 14-14, L_4 = 296000000
Y_N_4 = 0.97;

%Using Grade 3, Carburized and hardened heat treatment, 
%Gear bending strength = 75000 psi
Allowable_Bending_Stress_4 = 75000*Y_N_4;

n_bending_4 = Allowable_Bending_Stress_4/Stress_num_bending_4;


%Calculating Gear 5's bending and wear
%Figure 14-6
J_geo_5 = 0.41;
L_5 = 12000*60*w_5;
%Figure 14-14
Y_N_5 = 0.96;
%Figure 14-15
Z_N_5 = 0.98;

Contact_stress_5 = C_p*sqrt((W_45*K_v*K_m)/(d_4_inch*face_width_inch*I_Geo));

Stress_num_bending_5 = (W_45*K_v*P_inch*K_m)/(face_width_inch*J_geo_5);

%Table 14-6 and 14-3 to choose the heat treatment and grade
%Grade 2 Carburized and Hardened. S_C = 225000 psi, S_t = 65000 psi
n_c_5 = 225000/Contact_stress_5;
n_5 = 65000/Stress_num_bending_5;



%Gear 2 Wear
K_v_23 = ((A_dyn + sqrt(V_23))/(A_dyn))^B_dyn;

%Less load is expected so using 1.5 inch
face_width_inch_23 = 1.5;



%Load distribution factor for gear 2
%Calculate everything in inch and then convert back to m

%Equation 14-31
%Uncrowned
C_mc = 1;

%Equation 14-32
%face_width_inch is larger than 1 inch and less than 17 inch

C_pf_23 = (face_width_inch_23/(10*d_2_inch))-0.0375+(0.0125*face_width_inch_23);

%Equation 14-33
%Straddle mounted

C_pm = 1;

%Equation 14-34
%Commercial enclosed unit

A_Cma = 0.127;
B_Cma = 0.0158;
C_Cma = -0.0000930;

C_ma_23 = A_Cma + B_Cma*face_width_inch_23 + C_Cma*(face_width_inch_23^2);

%Equation 14-35
%All other condition

C_e = 1;

%Equation 14-30

K_m_23 = 1 + C_mc*(C_pf_23*C_pm + C_ma_23*C_e);



Contact_stress_2 = C_p*sqrt((W_23*K_v_23*K_m_23)/(d_2_inch*face_width_inch_23*I_Geo));
L_2 = 12000*60*w_2;

%From L_2
Z_N_2 = 0.78;

%From table 14-6,
%Grade 1 flamed hardened: S_C_2 = 170000 psi

n_c_2 = (170000*Z_N_2)/Contact_stress_2;


%Gear 2 Bending

J_geo_2 = 0.27;
Y_N_2 = 0.87;
Stress_num_bending_2 = (W_23*K_v_23*P_inch*K_m_23)/(face_width_inch_23*J_geo_2);

%From table 14-3,
%Grade 1 flamed hardend: S_t_2 = 45000 psi

n_2 = (45000*Z_N_2)/Stress_num_bending_2;



%Gear 3 wear and bending
L_3 = 12000*60*w_3;
J_geo_3 = 0.41;
Y_N_3 = 0.97;
Z_N_3 = 0.89;

Contact_stress_3 = C_p*sqrt((W_23*K_v_23*K_m_23)/(d_3_inch*face_width_inch_23*I_Geo));

Stress_num_bending_3 = (W_23*K_v_23*P_inch*K_m_23)/(face_width_inch_23*J_geo_3);

%Table 14-6 and 14-3 to choose the heat treatment and grade
%Grade 1 flamed and Hardened. S_C = 170000 psi, S_t = 22000 psi

n_c_3 = (Z_N_3*170000)/Contact_stress_3;
n_3 = (22000*Y_N_3)/Stress_num_bending_3;






%GEAR SPECIFICATION SUMMARY TABLE
Gear_Numbers = {'Gear 2'; 'Gear 3'; 'Gear 4'; 'Gear 5'};
Gear_Diametral_Pitch_Inch = [P_inch; P_inch; P_inch; P_inch];
Gear_Heat_Treatment = {'Grade 1 flamed hardend'; 'Grade 1 flamed and Hardened'; 
    'Grade 3 Carburized and hardened'; 'Grade 3 Carburized and hardened'};
Gear_Contact_Strength_Psi = [170000; 170000; 275000; 275000];
Gear_Bending_Strength_Psi = [22000; 22000; 75000; 75000];
Gear_Diameters_Inch = [d_2_inch; d_3_inch; d_4_inch; d_5_inch];
Gear_Face_Width_Inch = [face_width_inch_23; face_width_inch_23;
    face_width_inch; face_width_inch];

Gear_Summary_Inch = table(Gear_Numbers,Gear_Diameters_Inch,Gear_Heat_Treatment, ...
    Gear_Contact_Strength_Psi,Gear_Bending_Strength_Psi,Gear_Diameters_Inch, ...
    Gear_Face_Width_Inch)