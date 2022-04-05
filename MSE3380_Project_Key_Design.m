
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

%Shaft diameter d in inch
d_inch = 1.625;
d_m = d_inch * 0.0254;

T = T_3_Nm;
r = d_m/2;

F = T/r;

%Factor of safety for key
n_key = 2;

l_key = (2*F*n_key)/(t_key_m*S_y_key_Pa);

table_variables = {'Square key side [m]'; 'Square key length [m]'};
table_values = [t_key_m; l_key];
key_design_table = table(table_variables, table_values)