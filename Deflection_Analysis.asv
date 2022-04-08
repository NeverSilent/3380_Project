%% Calculations: Intermediate Shaft Design for Deflection

%% Define parameters to be passed into the function

% Load bending moment equations as piecewise symbolic functions [lbf-in]
load('Matfiles/force_analysis_vars_2022_04_06.mat', 'Mxy', 'Mxz')

% Diameters from the design for stress analysis [in]
D1 = 1.2;
D3 = 1.9;

% Axial locations rightwards from the datum (left end of shaft) [in]
A = 0.75;       % Bearing A
B = 10.75;      % Bearing B
G = 2.75;       % Gear 3
J = 8.50;       % Gear 4

% Redefine the shaft axial positions with bearing A's location as the datum:
loc_A = A - A;
loc_B = B - A;
loc_G = G - A;
loc_J = J - A;

% Young's modulus
E = 30e6;    % [psi], from Table A–5 (p. 1023)

%% Call function for analysis in each plane, determine magnitudes, and show tables

[slope_xy, defl_xy] = deflection_analysis(D1,D3, loc_A,loc_B,loc_G,loc_J, Mxy, E, 'xy');
[slope_xz, defl_xz] = deflection_analysis(D1,D3, loc_A,loc_B,loc_G,loc_J, Mxz, E, 'xz');

mag_slope = sqrt(slope_xy^2 + slope_xz^2);
mag_defl = sqrt(defl_xy^2 + defl_xz^2);

% Get slopes and deflections at key locations (bearings and gears)
slope_A = double(subs(mag_slope, loc_A));
slope_B = double(subs(mag_slope, loc_B));
slope_G = double(subs(mag_slope, loc_G));
slope_J = double(subs(mag_slope, loc_J));
deflection_G = double(subs(mag_defl,loc_G));
deflection_J = double(subs(mag_defl, loc_J));

% Show tables of results
locations1 = {'Bearing A'; 'Bearing B'; 'Gear G'; 'Gear J'};
slopes = [slope_A; slope_B; slope_G; slope_J];
locations2 = {'Gear G'; 'Gear J'};
deflections = [deflection_G; deflection_J;];
table(locations1, slopes, 'VariableNames',{'Locations','Slopes [rad]'})
table(locations2, deflections, 'VariableNames',{'Locations','Deflections [in]'})

%% Function to calculate and plot slope and deflections, given shaft parameters and bending moments
function [slope, defl] = deflection_analysis(D1,D3, loc_A,loc_B,loc_G,loc_J, BM, E, plane)
    addpath('SFBM');
    % INPUT PARAMETERS:
    % Shaft section diameters [in]
    %   D1 = D7
    %   D3 = D5

    % Axial locations rightwards from the location of bearing A [in]
    % See Fig. 7-10, pg. 386
    %   loc_A: Bearing A (=0)
    %   loc_B: Bearing B
    %   loc_G: Gear 3
    %   loc_J: Gear 4
    %   length: Overall length of shaft

    % BM: symbolic piecewise function of bending moment. [lbf-in]

    % E: Young's modulus [psi]

    % Plane: a string indicating which plane's bending moment was used (xy or xz).

    % Determine deflections and slopes at the key locations (Bearing A, 
    % Bearing B, Gear 3, Gear 4). Reference Table 7-2 (p. 391) for 
    % acceptable values.

    % Calculate flexural rigidities
    EI_D1 = E * (pi * D1^4) / 64;
    EI_D3 = E * (pi * D3^4) / 64;   
    EI_D7 = EI_D1;

    % DEFLECTION AND SLOPE COMPUTATION -----------------------------------
    % This section of code follows Equations (4–12) through (4–14), p. 176.
    
    % Moment equations are three linear equations of the form ax + b:
    syms x

    % Obtain symbolic function for integrals between A and G
    assume((loc_A < x) & (x < loc_G))
    integral_AG = int(BM) / EI_D1;
    syms C1 C2      % integration constants
    slope_AG = (simplify(integral_AG)) + C1;    %   = slope
    defl_AG = (simplify(int(slope_AG))) + C2;   %   = deflection
    % BOUNDARY CONDITION: at A, bearing acts like a pin support 
    % -> zero deflection.
    subs_defl_AG = subs(defl_AG, x, loc_A);                    
    BC_AG_nodefl = subs_defl_AG == 0;
    C2 = solve(subs_defl_AG == 0);

    % Obtain symbolic function for integrals between J and B
    assume((loc_J < x) & (x < loc_B))
    integral_JB = int(BM) / EI_D7;
    syms C3 C4      % integration constants
    slope_JB = (vpa(simplify(integral_JB))) + C3;    %   = slope
    defl_JB = (simplify(int(slope_JB))) + C4;   %   = deflection
    % BOUNDARY CONDITION: at B, bearing acts like a pin support 
    % -> zero deflection.
    subs_defl_JB = subs(defl_JB, x, loc_B);                    
    BC_JB_nodefl = subs_defl_JB == 0;
    C4 = solve(subs_defl_JB == 0, C4);   % Solve for C4 in terms of C3

    % Obtain symbolic function for integrals between G and J
    assume((loc_G < x) & (x < loc_J))
    integral_GJ = int(BM) / EI_D3;
    syms C5 C6      % integration constants
    slope_GJ = (vpa(simplify(integral_GJ))) + C5;    %   = slope
    defl_GJ = (simplify(int(slope_GJ))) + C6;   %   = deflection
    % BOUNDARY CONDITION: at G, deflection of AG = deflection of GJ
    subs_defl_AGGJ_1 = subs(defl_AG, x, loc_G);
    subs_defl_AGGJ_2 = subs(defl_GJ, x, loc_G);
    BC_AGGJ_eqdefl = subs_defl_AGGJ_1 == subs_defl_AGGJ_2;
    % BOUNDARY CONDITION: at J, deflection of GJ = deflection of JA
    subs_defl_GJJB_1 = subs(defl_GJ, x, loc_J);
    subs_defl_GJJB_2 = subs(defl_JB, x, loc_J);
    BC_GJJB_eqdefl = subs_defl_GJJB_1 == subs_defl_GJJB_2;

    % REMAINING BOUNDARY CONDITIONS
    % Slope continuity between AG and GJ at G
    subs_slope_AGGJ_1 = subs(slope_AG, x, loc_G);
    subs_slope_AGGJ_2 = subs(slope_GJ, x, loc_G);
    BC_AGGJ_eqslope = subs_slope_AGGJ_1 == subs_slope_AGGJ_2;
    % Slope continuity between GJ and JB at J
    subs_slope_GJJB_1 = subs(slope_GJ, x, loc_J);
    subs_slope_GJJB_2 = subs(slope_JB, x, loc_J);
    BC_GJJB_eqslope = subs_slope_GJJB_1 == subs_slope_GJJB_2;

    coefficient_solutions = solve(BC_AG_nodefl, ...
                                  BC_JB_nodefl, ...
                                  BC_AGGJ_eqdefl, ...
                                  BC_GJJB_eqdefl, ...
                                  BC_AGGJ_eqslope, ...
                                  BC_GJJB_eqslope);

    C1 = coefficient_solutions.C1;
    C2 = coefficient_solutions.C2;
    C3 = coefficient_solutions.C3;
    C4 = coefficient_solutions.C4;
    C5 = coefficient_solutions.C5;
    C6 = coefficient_solutions.C6;

    % Substitute the now known coefficients into slope and deflection eqns
    defl_AG = eval(defl_AG);
    defl_GJ = eval(defl_GJ);
    defl_JB = eval(defl_JB);
    slope_AG = eval(slope_AG);
    slope_GJ = eval(slope_GJ);
    slope_JB = eval(slope_JB);
    
    % PLOT SLOPE AND DEFLECTION DIAGRAMS ---------------------------------
    % Slope
    figure()
    fplot(slope_AG, [loc_A loc_G])
    hold on;
    fplot(slope_GJ, [loc_G loc_J])
    fplot(slope_JB, [loc_J loc_B])
    title([plane, '-plane: Slope'])
    xlabel('Axial position from bearing A (in)')
    ylabel('Slope \theta (rad)')
    yline(0)
    hold off;
    % Deflection
    figure()
    fplot(defl_AG, [loc_A loc_G])
    hold on;
    fplot(defl_GJ, [loc_G loc_J])
    fplot(defl_JB, [loc_J loc_B])
    title([plane, '-plane: Deflection'])
    xlabel('Axial position from bearing A (in)')
    ylabel('Deflection y (in)')
    yline(0)
    hold off;

    % Return piecewise symbolic expressions for slope and deflection
    syms x
    slope = piecewise(loc_A <= x & x <= loc_G, slope_AG, ...
                      loc_G < x & x <= loc_J, slope_GJ, ...
                      loc_J < x & x <= loc_B, slope_JB);
    defl = piecewise(loc_A <= x & x <= loc_G, defl_AG, ...
                     loc_G < x & x <= loc_J, defl_GJ, ...
                     loc_J < x & x <= loc_B, defl_JB);
end
