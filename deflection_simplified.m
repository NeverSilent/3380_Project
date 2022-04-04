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

deflection_analysis(D1,D2,D3,D4, A,B,G,J, Mxy, E)
deflection_analysis(D1,D2,D3,D4, A,B,G,J, Mxz, E)

%% Function
function deflection_analysis(D1,D2,D3,D4, A,B,G,J, BM, E)
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
    integral_xy_AG = int(BM) / EI_D1;
    syms C1 C2      % integration constants
    slope_xy_AG = (simplify(integral_xy_AG)) + C1;    %   = slope
    defl_xy_AG = (simplify(int(slope_xy_AG))) + C2;   %   = deflection
    % BOUNDARY CONDITION: at A, bearing acts like a pin support 
    % -> zero deflection.
    subs_defl_xy_AG = subs(defl_xy_AG, x, loc_A);                    
    BC_AG_nodefl = subs_defl_xy_AG == 0
    C2 = solve(subs_defl_xy_AG == 0);

    % Obtain symbolic function for integrals between J and B
    assume((loc_J < x) & (x < loc_B))
    integral_xy_JB = int(BM) / EI_D7;
    syms C3 C4      % integration constants
    slope_xy_JB = (vpa(simplify(integral_xy_JB))) + C3;    %   = slope
    defl_xy_JB = (simplify(int(slope_xy_JB))) + C4;   %   = deflection
    % BOUNDARY CONDITION: at B, bearing acts like a pin support 
    % -> zero deflection.
    subs_defl_xy_JB = subs(defl_xy_JB, x, loc_B);                    
    BC_JB_nodefl = subs_defl_xy_JB == 0
    C4 = solve(subs_defl_xy_JB == 0, C4);   % Solve for C4 in terms of C3

    % Obtain symbolic function for integrals between G and J
    assume((loc_G < x) & (x < loc_J))
    integral_xy_GJ = int(BM) / EI_D3;
    syms C5 C6      % integration constants
    slope_xy_GJ = (vpa(simplify(integral_xy_GJ))) + C5;    %   = slope
    defl_xy_GJ = (simplify(int(slope_xy_GJ))) + C6;   %   = deflection
    % BOUNDARY CONDITION: at G, deflection of AG = deflection of GJ
    subs_defl_xy_AGGJ_1 = subs(defl_xy_AG, x, loc_G);
    subs_defl_xy_AGGJ_2 = subs(defl_xy_GJ, x, loc_G);
    BC_AGGJ_eqdefl = subs_defl_xy_AGGJ_1 == subs_defl_xy_AGGJ_2
    % BOUNDARY CONDITION: at J, deflection of GJ = deflection of JA
    subs_defl_xy_GJJB_1 = subs(defl_xy_GJ, x, loc_J);
    subs_defl_xy_GJJB_2 = subs(defl_xy_JB, x, loc_J);
    BC_GJJB_eqdefl = subs_defl_xy_GJJB_1 == subs_defl_xy_GJJB_2

    % REMAINING BOUNDARY CONDITIONS
    subs_slope_xy_AGGJ_1 = subs(slope_xy_AG, x, loc_G);
    subs_slope_xy_AGGJ_2 = subs(slope_xy_GJ, x, loc_G);
    BC_AGGJ_eqslope = subs_slope_xy_AGGJ_1 == subs_slope_xy_AGGJ_2

    subs_slope_xy_GJJB_1 = subs(slope_xy_GJ, x, loc_J);
    subs_slope_xy_GJJB_2 = subs(slope_xy_JB, x, loc_J);
    BC_GJJB_eqslope = subs_slope_xy_GJJB_1 == subs_slope_xy_GJJB_2

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
    defl_xy_AG = eval(defl_xy_AG);
    defl_xy_GJ = eval(defl_xy_GJ);
    defl_xy_JB = eval(defl_xy_JB);
    slope_xy_AG = eval(slope_xy_AG);
    slope_xy_GJ = eval(slope_xy_GJ);
    slope_xy_JB = eval(slope_xy_JB);
    
    figure()
    fplot(slope_xy_AG, [loc_A loc_G])
    hold on;
    fplot(slope_xy_GJ, [loc_G loc_J])
    fplot(slope_xy_JB, [loc_J loc_B])
    title('Slope')
    xlabel('Axial position from bearing A (in)')
    ylabel('Slope \theta (rad)')
    yline(0)
    hold off;

    figure()
    fplot(defl_xy_AG, [loc_A loc_G])
    hold on;
    fplot(defl_xy_GJ, [loc_G loc_J])
    fplot(defl_xy_JB, [loc_J loc_B])
    title('Deflection')
    xlabel('Axial position from bearing A (in)')
    ylabel('Deflection y (in)')
    yline(0)
    hold off;
end
