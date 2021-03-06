% Using spur gears so there will be no axial force in the intermediate
% shaft. There will be; however, radial and tangential forces from
% the gears. Force and Moment balance will be used to 
% obtain the reaction forces. The Torque on this shaft will only be aplied
% at the input gear and fully taken off at the output gear... but will
% depend on the diameter of gear 2.
% Singularity functions will be able to determine the bending moment 
% diagrams and the shear force diagrams, which will be summed as vectors to
% obtain where the max bending moment is: the critical location.

%will need peicewise functions to properly define singularity functions
%including a peicewise for the torque in the shaft as well
%set up the independant variable as a symbolic
syms Vxy(x) Vxz(x) Mxy(x) Mxz(x) x Torque(x)

pressureAngle = 20; %pressure angle of gears in degrees
diamGear2 = 12; %diameter of gear 2
diamGear3 = 2; %diameter of gear 3
F12T = 540; %Force from gear 1 on gear 2 tangential (lbf)
F12R = F12T*tan(deg2rad(pressureAngle)); %Force from gear 1 on gear 2 radial (lbf)
F43T = 2431; %Force from gear 4 on gear 3 tangential (lbf)
F43R = F43T*tan(deg2rad(pressureAngle)); %Force from gear 4 on gear 3 radial (lbf)

%going to be taking the effective length of analysis to be from the center
%of bearing A to the center of bearing B... datum if center of bearing A
%position from the datum in inches

bearingWidth = 1; %width of outside bearing (inch)
Gearwidth3 = 0.75; %width of left gear on intermediate shaft (inch)
supportALoc = 0.75; %center of A from the datum (inch)
supportBLoc = 10.75; %center of B from the datum (inch)
position2 = 2.75; %center position of gear 2 (inch)
position3 = 8.50; %center position of gear 3 (inch)
leftGear3 = position3 - Gearwidth3; %left face of gear 3 (inch)
rightGear3 = position3 + Gearwidth3; %right face of gear 3 (inch)
leftBearingB = supportBLoc - bearingWidth; %left face of B bearing (inch)
rightBearingB = supportBLoc + bearingWidth; %right face of B bearing (inch)

%find the reaction forces, **xy xz plane: tan = xz rad = xy**
%Force and moment balance used where ??Fx = ??Fy = ??Fz = ??M = 0
%Eq.(3-1) and (3-2)
% **direction assumptions**
%input gear: tangential positive, radial negitive || gear 2
%output gear: tangential negitive, radial negitive || gear 3
%reaction forces: all positive direction

reactionBy = -(-F12R*(position2 - supportALoc) - F43R*(position3 - supportALoc))/(supportBLoc - supportALoc);
reactionAy = -(-F12R -F43R + reactionBy);
reactionBz = -(F12T*(position2 - supportALoc) - F43T*(position3 - supportALoc))/(supportBLoc - supportALoc);
reactionAz = -(F12T -F43T + reactionBz);
reactionA = sqrt(reactionAz^2 + reactionAy^2);
reactionB = sqrt(reactionBz^2 + reactionBy^2);

reactions = [reactionAz, reactionAy, reactionA, reactionBz, reactionBy, reactionB];

tableReact = table(reactions',  VariableNames = {'Reaction Forces (lbf)'}, RowNames = {'Az', 'Ay', 'A Total', 'Bz', 'By', 'B Total'})

%define singularity functions using table 3-1 
%start at V(x) and then manually do M(x) as the integration in MATLAB
%doesn't properly integrate singularity functions
Vxy(x) = piecewise((0 <= x)  & (x < (position2 - supportALoc)), reactionAy*(x^0), ...
    ((position2 - supportALoc) <= x) & (x < (position3 - supportALoc)), (reactionAy*(x^0) - F12R*((x - (position2 - supportALoc))^0)), ...
((position3 - supportALoc) <= x) & (x < (supportBLoc - supportALoc)), (reactionAy*(x^0) - F12R*((x - (position2 - supportALoc))^0) - F43R*((x - (position3 - supportALoc))^0)), ...
((supportBLoc - supportALoc) <= x), (reactionAy*(x^0) - F12R*((x - (position2 - supportALoc))^0) - F43R*((x - (position3 - supportALoc))^0) + reactionBy));

Vxz(x) = piecewise((0 <= x)  & (x < (position2 - supportALoc)), reactionAz*(x^0), ...
    ((position2 - supportALoc) <= x) & (x < (position3 - supportALoc)), (reactionAz*(x^0) + F12T*((x - (position2 - supportALoc))^0)), ...
((position3 - supportALoc) <= x) & (x < (supportBLoc - supportALoc)), (reactionAz*(x^0) + F12T*((x - (position2 - supportALoc))^0) - F43T*((x - (position3 - supportALoc))^0)), ...
((supportBLoc - supportALoc) <= x), (reactionAz*(x^0) + F12T*((x - (position2 - supportALoc))^0) - F43T*((x - (position3 - supportALoc))^0) + reactionBz));

%integrate to get the bending moments
Mxy(x) = piecewise((0 <= x)  & (x < (position2 - supportALoc)), reactionAy*(x^1), ...
    ((position2 - supportALoc) <= x) & (x < (position3 - supportALoc)), (reactionAy*(x^1) - F12R*((x - (position2 - supportALoc))^1)), ...
((position3 - supportALoc) <= x) & (x < (supportBLoc - supportALoc)), (reactionAy*(x^1) - F12R*((x - (position2 - supportALoc))^1) - F43R*((x - (position3 - supportALoc))^1)), ...
((supportBLoc - supportALoc) <= x), (reactionAy*(x^1) - F12R*((x - (position2 - supportALoc))^1) - F43R*((x - (position3 - supportALoc))^1)));

Mxz(x) = piecewise((0 <= x)  & (x < (position2 - supportALoc)), reactionAz*(x^1), ...
    ((position2 - supportALoc) <= x) & (x < (position3 - supportALoc)), (reactionAz*(x^1) + F12T*((x - (position2 - supportALoc))^1)), ...
((position3 - supportALoc) <= x) & (x < (supportBLoc - supportALoc)), (reactionAz*(x^1) + F12T*((x - (position2 - supportALoc))^1) - F43T*((x - (position3 - supportALoc))^1)), ...
((supportBLoc - supportALoc) <= x), (reactionAz*(x^1) + F12T*((x - (position2 - supportALoc))^1) - F43T*((x - (position3 - supportALoc))^1)));

%vector sum the shear and bending
V(x) = sqrt(Vxy^2 + Vxz^2);
M(x) = sqrt(Mxy^2 + Mxz^2);

%find the torque distrobution
Torque(x) = piecewise((0 <= x) & (x < (position2 - supportALoc)), 0, ...
    ((position2 - supportALoc <= x) & (x < position3 - supportALoc)), (F12T*(diamGear2 / 2)), ...
    ((position3 - supportALoc <= x) & (x < supportBLoc - supportALoc)), (0));

%plot some of the graphs thusfar
figure();
subplot(3, 2, 1);
fplot(Vxy(x), [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("V x-y Plane (lbf)");
title('V x-y Plane');

subplot(3, 2, 3);
fplot(Mxy, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("M x-y Plane (lbf-in)");
title('M x-y Plane');

subplot(3, 2, 2);
fplot(Vxz, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("V x-z Plane (lbf)");
title('V x-z Plane');

subplot(3, 2, 4);
fplot(Mxz, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("M x-z Plane (lbf-in)");
title('M x-z Plane');

subplot(3, 2, 5);
fplot(M, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("MTot (lbf-in)");
xlabel("Distance from Datum (in)");
title('M Total');

subplot(3, 2, 6);
fplot(Torque, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("Torque (lbf-in)");
xlabel("Distance from Datum (in)");
title('Torque');

%find the max bending moment and where it is relative to the datum of the
%far left edge of the shaft
x = [0 : 0.001 : (supportBLoc - supportALoc)];
[MaxBendingMoment, MaxBendingMomemtLoc] = max(subs(M(x)))
MaxBendingMoment = vpa(MaxBendingMoment, 6)
MaxBendingMomemtLoc = vpa((MaxBendingMomemtLoc * 0.001) + supportALoc, 4)

%report critical locations in table with asscioated bending moment
x = [leftGear3, position3, rightGear3, leftBearingB, supportBLoc, rightBearingB];
CritBendingMoment = double(subs(M(x)));
momentTable = table(x', CritBendingMoment', VariableNames = {'Position from Center of Bearing A (inch)', 'Bending Moment at Location (lbf-in)'})
