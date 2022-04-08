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

% SF_BM_diagrams(A,B,G,J, length, Wt_23,Wr_23,Wt_54,Wr_54);

deflection_analysis(D1,D2,D3,D4, A,B,G,J, E)

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

%%
function deflection_analysis(D1,D2,D3,D4, A,B,G,J, E)
    addpath('SFBM');
    % INPUT PARAMETERS:
    % Shaft section diameters
    %   D1 = D7
    %   D2 = D6
    %   D3 = D5

    % E: Young's Modulus

    % Determine if deflections and slopes at the key locations (Bearing A, 
    % Bearing B, Gear 3, Gear 4) are acceptable as per Table 7-2 (p. 391)
    
    % Calculate flexural rigidities
    EI_D1 = E * (pi * D1^4) / 64;
    EI_D2 = E * (pi * D2^4) / 64;
    EI_D3 = E * (pi * D3^4) / 64;
    EI_D4 = E * (pi * D4^4) / 64;

    % Moment equations are three piecewise functions made of linear 
    % equations of the form ax + b:

    % xy-plane
    a1 = 356.725;
    b1 = -267.472;
    
    a2 = 159.725;
    b2 = 274.209;

    a3 = -725.275;
    b3 = 7796.399;

    syms x;
    syms slope(x);      % = EI * integral(moment)
    syms defl(x);       % = integral(slope)

    syms moment_xy_piece1(x) moment_xy_piece2(x) moment_xy_piece3(x)
    moment_xy_piece1(x) = a1*x + b1;
    moment_xy_piece2(x) = a2*x + b2;
    moment_xy_piece3(x) = a3*x + b3;

    % Symbolic integration to check differential equation results
    integral_xy_piece1 = int(moment_xy_piece1)
    integral_xy_piece2 = int(moment_xy_piece2)
    integral_xy_piece3 = int(moment_xy_piece3)

    % Differential equations (since need to obtain integration constants)

    % For A < x < D (diameter=D1, within piece 1)
    eqn = diff(slope(x))==moment_xy_piece1(x);
    sol_AD = dsolve(eqn)
    slope_xy_AD = EI_D1 * sol_AD

    % For D < x < F (diameter=D2, within piece 1)
    eqn = diff(slope(x))==moment_xy_piece1(x);
    sol_DF = dsolve(eqn)
    slope_xy_DF = EI_D2 * sol_AD
    
    solve_constants = slope_xy_AD - slope_xy_DF == 0
    solve(solve_constants)
    

    

%     fplot(moment_xy_piece1, [A, G])
%     hold on;
%     fplot(moment_xy_piece2, [G, J])
%     fplot(moment_xy_piece3, [J, B])


    fplot(integral_xy_piece1, [A, G])
    hold on;
    fplot(integral_xy_piece2, [G, J])
    fplot(integral_xy_piece3, [J, B])
end