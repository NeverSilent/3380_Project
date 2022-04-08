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
diamGear2 = 12; %diameter of gear 2 (inch)
diamGear3 = 2; %diameter of gear 3 (inch)
F12T = 540; %Force from gear 1 on gear 2 tangential (lbf)
F12R = F12T*tan(deg2rad(pressureAngle)); %Force from gear 1 on gear 2 radial (lbf)
F43T = 2431; %Force from gear 4 on gear 3 tangential (lbf)
F43R = F43T*tan(deg2rad(pressureAngle)); %Force from gear 4 on gear 3 radial (lbf)

%going to be taking the effective length of analysis to be from the center
%of bearing A to the center of bearing B... datum if center of bearing A
%position from the datum in inches

FaceWidth3 = 2; %facewidth of gear 3 (inch)
Outside_Bearing = 1 %width of outside bearings (inch)
supportALoc = 0.75; %center of A from the datum (inch)
supportBLoc = 10.75; %center of B from the datum (inch)
position2 = 2.75; %center position of gear 2 (inch)
position3 = 8.50; %center position of gear 3 (inch)
leftOfGear3 = (position3 - FaceWidth3/2); %position of left face of gear from datum (inch)
rightOfGear3 = (position3 + FaceWidth3/2); %position of right face of gear from datum (inch)
leftOfSupportB = (supportBLoc - Outside_Bearing/2); %position of left face of bearing to the right of gear 3 from datum (inch)
rightOfSupportB = (supportBLoc + Outside_Bearing/2); %position of right face of bearing to the right of gear 3 from datum (inch)

%find the reaction forces, **xy xz plane: tan = xz rad = xy**
%Force and moment balance used where ΣFx = ΣFy = ΣFz = ΣM = 0
%Eq.(3-1) and (3-2)
% **direction assumptions**
%input gear: tangential positive, radial negitive || gear 2
%output gear: tangential negitive, radial negitive || gear 3
%reaction forces: all positive

reactionBy = -(-F12R*(position2 - supportALoc) - F43R*(position3 - supportALoc))/(supportBLoc - supportALoc);
reactionAy = -(-F12R -F43R + reactionBy);
reactionBz = -(F12T*(position2 - supportALoc) - F43T*(position3 - supportALoc))/(supportBLoc - supportALoc);
reactionAz = -(F12T -F43T + reactionBz);
reactionA = sqrt(reactionAy^2 + reactionAz^2);
reactionB = sqrt(reactionBy^2 + reactionBz^2);
Areactions = [reactionAz, reactionAy, reactionA];
Breactions = [reactionBz, reactionBy, reactionB];

reactionForces = table(Areactions', Breactions', VariableNames = {'A Reaction Forces (lbf)', 'B Reaction Forces (lbf)'}, RowNames = {'Z direction', 'Y Direction', 'Vector Sum'})

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
subplot(6, 1, 1);
fplot(Vxy(x), [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("V x-y Plane (lbf)");

subplot(6, 1, 2);
fplot(Mxy, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("M x-y Plane (lbf*in)");

subplot(6, 1, 3);
fplot(Vxz, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("V x-z Plane (lbf)");

subplot(6, 1, 4);
fplot(Mxz, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("M x-z Plane (lbf*in)");

subplot(6, 1, 5);
fplot(M, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("MTot (lbf*in)");

subplot(6, 1, 6);
fplot(Torque, [0, supportBLoc - supportALoc], MeshDensity=200, LineWidth = 2)
ylabel("Torque (lbf*in)");
xlabel("Distance from Datum (Inch)");

%find the max bending moment and where it is relative to the datum of the
%far left edge of the shaft
x = [0 : 0.001 : (supportBLoc - supportALoc)];
[MaxBendingMoment, MaxBendingMomemtLoc] = max(subs(M(x)));
MaxBendingMoment = vpa(MaxBendingMoment, 6)
MaxBendingMomemtLoc = vpa((MaxBendingMomemtLoc * 0.001) + supportALoc, 4)

%compare the MaxBendingMomemtLoc to the closest SCF and choose the critical
%point to pay attention to. Will also want to know the max bending moment
%at all SCF's concerning diameter changes and key hole centers. 
%set x to be a matrix of critical locations on the right side of the center
%of the shaft(where the bending moments are larger)
x = [leftOfGear3, position3, rightOfGear3, leftOfSupportB, supportBLoc, rightOfSupportB];
x = x  - supportALoc; %need to subtract off the support A location to achieve datum of the 
bendingMoments = subs(M(x));
RowNames = {'Position From Center of Support A (Inch)', 'Bending Moment (lbf*in)'};
LocationsToCheck = table(x', bendingMoments', VariableNames = RowNames)