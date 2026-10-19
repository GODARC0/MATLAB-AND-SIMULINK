
clear;
clc;
close all;

rng(1);  % Reproducible random initialization

% Generate the benchmark dataset
[U, Y] = createDataset();

% Initial parameters
w = rand(9,1);

% Initial means spread across the input domain
m = [-0.5; 0; 0.5; -0.5; 0; 0.5];

% Initial Gaussian widths
sigma = 0.35 * ones(6,1);

% Evaluate the untrained FNN
Yhat = zeros(size(Y));

for n = 1:size(U,1)
    Yhat(n) = fnnForward(U(n,:), w, m, sigma);
end

% Display the results
results = table( ...
    U(:,1), U(:,2), Y, Yhat, Y-Yhat, ...
    'VariableNames', ...
    {'u1','u2','Desired','Predicted','Error'});

disp(results);

fprintf('Initial MSE = %.8f\n', mean((Y-Yhat).^2));

% Compare desired and predicted outputs
figure;
plot(1:9, Y, 'o-', 'LineWidth', 1.5);
hold on;
plot(1:9, Yhat, 'x--', 'LineWidth', 1.5);
grid on;

xlabel('Training sample');
ylabel('Output');
legend('Desired output','Initial FNN output', ...
    'Location','best');
title('FNN Before Training');
