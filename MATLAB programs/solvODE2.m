%Parameters
P1 = 2;
P2 = 0.8;
P3 = 3;

%initial conditions
z10 = 0;
z20 = 20;

%Time span for simulation
tspan = [0 10];

%Input parameters (forcing function)
Vm = 10;  % input (v)
alpha = 1; %Decay rate constant (1/s)

%Exponantial input 
Vin = @(t) Vm * exp(-alpha * t);

%defining ODE system as first-order system
% State variables : Z = [z1; z2] = [z; dz/dt]

odeSol = @(t, Z) [Z(2); -P3/P1*Z(1)-P2/P1*Z(2)+1/P1*Vin(t)];

%solving ODE
[time, Z] = ode45(odeSol, tspan, [z10; z20]);

%graph plotting (to see system response)

plot(time, Z(:,1), "LineWidth",4);
hold on
grid on;

xlabel('time(sec)');
ylabel('Z(t)');
title('Response of Second order system');