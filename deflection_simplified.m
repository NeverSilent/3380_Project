%%
% load('Matfiles/force_analysis_vars.mat') % Load all force analysis vars
load('Matfiles/force_analysis_vars.mat', 'Mxy', 'Mxz')

%% Test with parameters from Ex. 7-2 and 7-3

D1 = 1.0;   % [in]
D2 = 1.4;
D3 = 1.625;
D4 = 2.0;

% Axial locations rightwards from the datum (left end of shaft) [in]
A = 0.75;       % Bearing A
B = 10.75;      % Bearing B
G = 2.75;       % Gear 3
J = 8.50;       % Gear 4
length = 11.50;

% Transmitted gear loads [lbf]
Wt_23 = 540;
Wr_23 = 197;
Wt_54 = 2431;
Wr_54 = 885;

% Young's modulus
E = 30e6;    % [psi]

[slope_xy, defl_xy] = deflection_analysis(D1,D2,D3,D4, A,B,G,J, Mxy, E);
[slope_xz, defl_xz] = deflection_analysis(D1,D2,D3,D4, A,B,G,J, Mxz, E);

%% Function
function [slope, defl] = deflection_analysis(D1,D2,D3,D4, A,B,G,J, BM, E)
    addpath('SFBM');
    % INPUT PARAMETERS:
    % Shaft section diameters
    %   D1 = D7
    %   D2 = D6
    %   D3 = D5

    % Axial locations rightwards from the datum (left end of shaft)
    % See Fig. 7-10, pg. 386
    %   A: Bearing A
    %   B: Bearing B
    %   G: Gear 3
    %   J: Gear 4
    %   length: Overall length of shaft

    % M: symbolic piecewise function of bending moment.

    % E: Young's Modulus

    % Determine if deflections and slopes at the key locations (Bearing A, 
    % Bearing B, Gear 3, Gear 4) are acceptable as per Table 7-2 (p. 391)
    
    % Redefine the shaft axial positions with bearing A's location as the
    % datum:
    loc_A = A - A;
    loc_B = B - A;
    loc_G = G - A;
    loc_J = J - A;

    % Calculate flexural rigidities
    EI_D1 = E * (pi * D1^4) / 64;
    EI_D3 = E * (pi * D3^4) / 64;   
    EI_D7 = EI_D1;

    % DEFLECTION AND SLOPE COMPUTATION -----------------------------------
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
    BC_AG_nodefl = subs_defl_AG == 0
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
    BC_JB_nodefl = subs_defl_JB == 0
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
    BC_AGGJ_eqdefl = subs_defl_AGGJ_1 == subs_defl_AGGJ_2
    % BOUNDARY CONDITION: at J, deflection of GJ = deflection of JA
    subs_defl_GJJB_1 = subs(defl_GJ, x, loc_J);
    subs_defl_GJJB_2 = subs(defl_JB, x, loc_J);
    BC_GJJB_eqdefl = subs_defl_GJJB_1 == subs_defl_GJJB_2

    % REMAINING BOUNDARY CONDITIONS
    subs_slope_AGGJ_1 = subs(slope_AG, x, loc_G);
    subs_slope_AGGJ_2 = subs(slope_GJ, x, loc_G);
    BC_AGGJ_eqslope = subs_slope_AGGJ_1 == subs_slope_AGGJ_2

    subs_slope_GJJB_1 = subs(slope_GJ, x, loc_J);
    subs_slope_GJJB_2 = subs(slope_JB, x, loc_J);
    BC_GJJB_eqslope = subs_slope_GJJB_1 == subs_slope_GJJB_2

    coefficient_solutions = solve(BC_AG_nodefl, ...
                                  BC_JB_nodefl, ...
                                  BC_AGGJ_eqdefl, ...
                                  BC_GJJB_eqdefl, ...
                                  BC_AGGJ_eqslope, ...
                                  BC_GJJB_eqslope)

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
    
    figure()
    fplot(slope_AG, [loc_A loc_G])
    hold on;
    fplot(slope_GJ, [loc_G loc_J])
    fplot(slope_JB, [loc_J loc_B])
    title('Slope')
    xlabel('Axial position from bearing A (in)')
    ylabel('Slope \theta (rad)')
    yline(0)
    hold off;

    figure()
    fplot(defl_AG, [loc_A loc_G])
    hold on;
    fplot(defl_GJ, [loc_G loc_J])
    fplot(defl_JB, [loc_J loc_B])
    title('Deflection')
    xlabel('Axial position from bearing A (in)')
    ylabel('Deflection y (in)')
    yline(0)
    hold off;

    % Return expressions
    syms x
    slope = piecewise(loc_A <= x & x <= loc_G, slope_AG, ...
                      loc_G < x & x <= loc_J, slope_GJ, ...
                      loc_J < x & x <= loc_B, slope_JB);
    defl = piecewise(loc_A <= x & x <= loc_G, defl_AG, ...
                     loc_G < x & x <= loc_J, defl_GJ, ...
                     loc_J < x & x <= loc_B, defl_JB);
end
