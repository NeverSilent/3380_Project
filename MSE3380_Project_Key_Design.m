
%Needs values from the previous section!
T_3_lbfft = 383.26237;
T_3_lbfin = T_3_lbfft * 12;


%Table 7-6
%3/8 inches from the shaft diameter of 1.625 inch
t_key = 0.375;

%Yield Strength in Psi
S_y_key_psi = 67000;

d = 1.625;
T = T_3_lbfin;
r = d/2;

F = T/r;

n_key = 2;

l_key = (2*F*n_key)/(t_key*S_y_key_psi);



