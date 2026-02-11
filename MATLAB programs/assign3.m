% Define the numerator and denominator coefficients
num = [100 300];
den = [1 16 69 90 100];

% Create the transfer function
sys = tf(num, den);

% Get the step response data
[y, t] = step(sys);

% Find the peak value
peak_value = max(y);

% Display the result rounded to one decimal place
fprintf('The peak value is: %.1f\n', peak_value);

% Plot for visualization
step(sys);
grid on;