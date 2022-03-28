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

SF_BM_diagrams(A,B,G,J, length, Wt_23,Wr_23,Wt_54,Wr_54);

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

function deflection_analysis(D1,D2,D3,D4, A,B,G,J)
    addpath('SFBM');
    % INPUT PARAMETERS:
    % Shaft section diameters
    %   D1 = D7
    %   D2 = D6
    %   D3 = D5

    % Determine if deflections and slopes at the key locations (Bearing A, 
    % Bearing B, Gear 3, Gear 4) are acceptable as per Table 7-2 (p. 391)


    % Start with getting the deflection from the output SF/BMD equations
    % from the pre-built function

    
end