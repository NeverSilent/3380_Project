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

deflection_analysis(D1,D2,D3,D4, A,B,G,J, Mxy, Mxz, E)

%% Functions
function deflection_analysis(D1,D2,D3,D4, A,B,G,J, Mxy, Mxz, E)
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

    % Mxy: symbolic piecewise function of bending moment in xy-plane
    % Mxz: symbolic piecewise function of bending moment in xz-plane

    % E: Young's Modulus

    % Determine if deflections and slopes at the key locations (Bearing A, 
    % Bearing B, Gear 3, Gear 4) are acceptable as per Table 7-2 (p. 391)
    
    % Redefine the shaft axial positions with bearing A's location as the
    % datum:
    loc_A = A - A
    loc_B = B - A
    loc_G = G - A
    loc_J = J - A

    % Calculate flexural rigidities
    EI_D1 = E * (pi * D1^4) / 64
    EI_D3 = E * (pi * D3^4) / 64;   
    EI_D7 = EI_D1;

    % DEFLECTION AND SLOPE COMPUTATION FOR Mxy --------------------------
    % Moment equations are three linear equations of the form ax + b:
    syms x

    % Obtain symbolic function for integrals between A and G
    assume((loc_A < x) & (x < loc_G))
    integral_xy_AG = int(Mxy) / EI_D1
    syms C1 C2      % integration constants
    slope_xy_AG = (simplify(integral_xy_AG)) + C1    %   = slope
    defl_xy_AG = (simplify(int(slope_xy_AG))) + C2   %   = deflection
    % BOUNDARY CONDITION: at A, bearing acts like a pin support 
    % -> zero deflection.
    subs_defl_xy_AG = subs(defl_xy_AG(loc_A), x, 0)
    C2 = solve(subs_defl_xy_AG == 0)
    % Substitute C2 (= 0) into deflection
    defl_xy_AG = eval(defl_xy_AG)

    % Obtain symbolic function for integrals between J and B
    assume((loc_J < x) & (x < loc_B))
    integral_xy_JB = int(Mxy) / EI_D7
    syms C3 C4      % integration constants
    slope_xy_JB = (vpa(simplify(integral_xy_JB))) + C3    %   = slope
    defl_xy_JB = (simplify(int(slope_xy_JB))) + C4   %   = deflection
    % BOUNDARY CONDITION: at B, bearing acts like a pin support 
    % -> zero deflection.
    subs_defl_xy_JB = subs(defl_xy_JB(loc_B), x, loc_B)
    C4 = solve(subs_defl_xy_JB == 0, C4)    % Solve for C4 in terms of C3
    % Substitute solved C4 into deflection
    defl_xy_JB = eval(defl_xy_JB)
end

function SF_BM_diagrams(A,B,G,J,length, Wt_23,Wr_23,Wt_54,Wr_54)
    addpath('SFBM');
    % Axial locations rightwards from the datum (left end of shaft)
    % See Fig. 7-10, pg. 386
    %   A: Bearing A
    %   B: Bearing B
    %   G: Gear 3
    %   J: Gear 4
    %   length: Overall length of shaft

    % Forces transmitted through gears (magnitudes - positive values):
    %   Wt_23
    %   Wr_23
    %   Wt_54
    %   Wr_54

    % Treat shaft as simply supported beam in xy- and xz-planes.

    % Problem Name
    Name_xz = 'xz-Plane';
    % Length and Supports
    LengthSupport_xz = [length,A,B]; % length  = 20m, supports at 5m and 20m;
    % Concentrated Loads
    load_Wt_23 = {'CF', Wt_23, G};
    load_Wt_54 = {'CF', -Wt_54, J};

    % Problem Name
    Name_xy = 'xy-Plane';
    % Length and Supports
    LengthSupport_xy = [length,A,B]; % length  = 20m, supports at 5m and 20m;
    % Concentrated Loads
    load_Wr_23 = {'CF', -Wr_23, G};
    load_Wr_54 = {'CF', -Wr_54, J};

    % Call the function to create the SF and BM diagrams
    SFBM(Name_xz,LengthSupport_xz,load_Wt_23, load_Wt_54);
    SFBM(Name_xy,LengthSupport_xy,load_Wr_23, load_Wr_54);
end