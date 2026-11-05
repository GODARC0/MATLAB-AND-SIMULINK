
clear; clc; close all;

%% 1. Load training dataset
[U, Y] = createDataset();
N = size(U, 1);

%% 2. Initialize FNN parameters
rng(1);

w = rand(9, 1);

m = [-0.5; 0; 0.5; ...
     -0.5; 0; 0.5];

sigma = 0.35 * ones(6, 1);

%% 3. Training settings
epochs = 5000;

eta_w = 0.01;
eta_m = 0.001;
eta_sigma = 0.001;

minSigma = 0.01;

MSE_history = zeros(epochs, 1);

%% 4. Initial MSE
Y_initial = zeros(N, 1);

for n = 1:N
    Y_initial(n) = fnnForward(U(n,:), w, m, sigma);
end

initialMSE = mean((Y - Y_initial).^2);

fprintf('Initial MSE: %.8f\n', initialMSE);

%% 5. Backpropagation training
for epoch = 1:epochs

    for n = 1:N

        u = U(n,:)';
        yd = Y(n);

        % ----- Forward pass -----

        mu = zeros(6,1);

        for j = 1:6
            if j <= 3
                inputIndex = 1;
            else
                inputIndex = 2;
            end

            mu(j) = exp( ...
                -(u(inputIndex) - m(j))^2 ...
                / (2 * sigma(j)^2));
        end

        % Rule firing strengths
        r = zeros(9,1);
        k = 1;

        for i = 1:3
            for j = 1:3
                r(k) = mu(i) * mu(j+3);
                k = k + 1;
            end
        end

        % Predicted output
        y = sum(w .* r);

        % Prediction error
        e = yd - y;

        % ----- Gradients for weights -----

        dE_dw = -e * r;

        % ----- Gradients for means and sigmas -----

        dE_dm = zeros(6,1);
        dE_dsigma = zeros(6,1);

        % Contributions from the first input's memberships
        for i = 1:3

            dmu_dm = mu(i) * ...
                (u(1) - m(i)) / sigma(i)^2;

            dmu_dsigma = mu(i) * ...
                (u(1) - m(i))^2 / sigma(i)^3;

            dY_dmu = 0;

            for j = 1:3
                k = (i-1)*3 + j;
                dY_dmu = dY_dmu + w(k)*mu(j+3);
            end

            dY_dm = dY_dmu * dmu_dm;
            dY_dsigma = dY_dmu * dmu_dsigma;

            dE_dm(i) = -e * dY_dm;
            dE_dsigma(i) = -e * dY_dsigma;

        end

        % Contributions from the second input's memberships
        for j = 1:3

            idx = j + 3;

            dmu_dm = mu(idx) * ...
                (u(2) - m(idx)) / sigma(idx)^2;

            dmu_dsigma = mu(idx) * ...
                (u(2) - m(idx))^2 / sigma(idx)^3;

            dY_dmu = 0;

            for i = 1:3
                k = (i-1)*3 + j;
                dY_dmu = dY_dmu + w(k)*mu(i);
            end

            dY_dm = dY_dmu * dmu_dm;
            dY_dsigma = dY_dmu * dmu_dsigma;

            dE_dm(idx) = -e * dY_dm;
            dE_dsigma(idx) = -e * dY_dsigma;

        end

        % ----- Update all 21 parameters -----

        w = w - eta_w * dE_dw;

        m = m - eta_m * dE_dm;

        sigma = sigma - eta_sigma * dE_dsigma;

        % Keep Gaussian widths positive
        sigma = max(sigma, minSigma);

    end

    % ----- Calculate MSE after each epoch -----

    Y_pred = zeros(N,1);

    for n = 1:N
        Y_pred(n) = fnnForward(U(n,:), w, m, sigma);
    end

    MSE_history(epoch) = mean((Y - Y_pred).^2);

    if epoch == 1 || mod(epoch,500) == 0
        fprintf('Epoch %4d | MSE = %.8f\n', ...
            epoch, MSE_history(epoch));
    end

end

%% 6. Final results

fprintf('\nInitial MSE: %.8f\n', initialMSE);
fprintf('Final MSE:   %.8f\n', MSE_history(end));

disp('Final weights:');
disp(w);

disp('Final means:');
disp(m);

disp('Final sigmas:');
disp(sigma);

results = table( ...
    U(:,1), U(:,2), Y, Y_pred, Y-Y_pred, ...
    'VariableNames', ...
    {'u1','u2','Desired','Predicted','Error'});

disp(results);

%% 7. Plot MSE convergence

figure;

semilogy(1:epochs, max(MSE_history, eps), ...
    'LineWidth', 1.5);

grid on;
xlabel('Epoch');
ylabel('Mean Squared Error');
title('FNN Training Using Backpropagation');

%% 8. Compare desired and predicted outputs

figure;

plot(1:N, Y, 'o-', 'LineWidth', 1.5);
hold on;

plot(1:N, Y_pred, 'x--', 'LineWidth', 1.5);

grid on;
xlabel('Training Sample');
ylabel('Output');

legend('Desired Output', 'Trained FNN Output', ...
    'Location', 'best');

title('FNN Output Before and After Training');
