
%Needs values from the previous section!
T_3_lbfft = 383.26237;
T_3_lbfin = T_3_lbfft * 12;
T_3_Nm = 519.634;


%Table 7-6 (in inch)
%3/8 inches from the shaft diameter of 1.625 inch
t_key_inch = 0.375;
t_key_m = 0.375 * 0.0254;

%Yield Strength in Pa
S_y_key_Pa = 460000000;

%Yield Strength in Psi
S_y_key_Psi = 67000;

%Shaft diameter d in inch
d_inch = 1.625;
d_m = d_inch * 0.0254;

r_m = d_m/2;
r_inch = d_inch/2;



F_N = T_3_Nm/r_m;
F_lbf = T_3_lbfin/r_inch;

%Factor of safety for key
n_key = 2;

l_key_inch = (2*F_lbf*n_key)/(t_key_inch*S_y_key_Psi);
l_key_m = (2*F_N*n_key)/(t_key_m*S_y_key_Pa);



table_variables_SI = {'Square key side [m]'; 'Square key length [m]'};
table_values_SI = [t_key_m; l_key_m];
key_design_table_SI = table(table_variables_SI, table_values_SI)

table_variables_inch = {'Square key side [inch]'; 'Square key length [inch]'};
table_values_inch = [t_key_inch; l_key_inch];
key_design_table_inch = table(table_variables_inch, table_values_inch)