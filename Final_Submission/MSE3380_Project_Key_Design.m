
%Needs values from the previous section!
T_3_lbfft = 383.26237;
T_3_lbfin = T_3_lbfft * 12;


%Table 7-6 (in inch)
%w = 0.5 inch from the shaft diameter of 1.9 inch
t_key_inch = 0.5;


%Table A-27
%Plain carbon steel HR, N
%Yield Strength in Psi
S_y_key_Psi = 63000;

%Shaft diameter d in inch
d_inch = 1.9;

r_inch = d_inch/2;

F_lbf = T_3_lbfin/r_inch;

%Factor of safety for key
n_key = 2;

l_key_inch = (2*F_lbf*n_key)/(t_key_inch*S_y_key_Psi);

table_variables_inch = {'Square key side [inch]'; 'Square key length [inch]'};
table_values_inch = [t_key_inch; l_key_inch];
key_design_table_inch = table(table_variables_inch, table_values_inch)


%The design choice will be discussed in the report.
%According to the calculation result, we want the key longer than
%0.6148 inch.
%1/2" x 1/2", 1" Long, oversized square key was chosen.
%Keyway depth is 1/4"

%New factor of safety.

n_new = S_y_key_Psi/(F_lbf/((t_key_inch*1)/2));
new_Factor_Of_Safety = [n_new];

new_factor_of_safety_for_key = table(new_Factor_Of_Safety)