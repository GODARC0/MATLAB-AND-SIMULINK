%parameters
P1 = 1 ;
P2 = 0.5 ;
P3 = 20 ;

%initial conditions
z10 = -5;
z20 = 20;

%Time span for simulation 
tspan = [0 10];

%Define ODE system as First-order system
% State variable: Z= [z1; z2] = [z; dz/dt]

odeSol = @(t,Z) [Z(2); -P3/P1*Z(1)-P2/P1*Z(2)];

%solve ODE 
[time, Z] = ode45(odeSol,tspan, [z10; z20]);

%Plot  Displacement (natural response)
figure;
plot(time, Z(:,1), 'LineWidth',2);
grid on;
xlabel('Time (seconds)');
ylabel('Z(t)');
title('Natural response of second order system')