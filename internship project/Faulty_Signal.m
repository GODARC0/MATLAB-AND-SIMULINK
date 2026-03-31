%% Step 2: Faulty Vibration Signal Generation
% -----------------------------------------------
% Project: Predictive Maintenance Using Signal Processing
% Author : Mohd Luqmaan
% -----------------------------------------------

% --- Load normal signal from Step 1 ---
load('normal_signal.mat');   % loads: signal_normal, t, fs

% --- Fault Parameters ---
freq_fault = 120;    % Fault introduces a 120 Hz component (e.g. worn bearing)
amp_fault  = 0.3;   % Fault amplitude (0.8 = strong fault)
noise_level = 0.05;  % Random noise level

% --- Generate fault components ---
fault_component = amp_fault * sin(2 * pi * freq_fault * t);
noise_component = noise_level * randn(size(t));   % Gaussian random noise

% --- Combine: faulty = normal + fault + noise ---
signal_faulty = signal_normal + fault_component + noise_component;

% --- Save for later steps ---
save('faulty_signal.mat', 'signal_faulty', 't', 'fs');

% --- Plot 1: Full comparison side by side ---
figure('Name', 'Signal Comparison — Normal vs Faulty');

subplot(2,1,1);
plot(t, signal_normal, 'Color', [0.11 0.62 0.46], 'LineWidth', 1);
title('Normal Vibration Signal (50 Hz — Healthy Machine)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;
ylim([-3 3]);

subplot(2,1,2);
plot(t, signal_faulty, 'Color', [0.85 0.33 0.10], 'LineWidth', 1);
title('Faulty Vibration Signal (50 Hz + 120 Hz fault + noise)');
xlabel('Time (s)'); ylabel('Amplitude'); grid on;
ylim([-3 3]);

% --- Plot 2: Zoomed overlay for clear visual difference ---
figure('Name', 'Zoomed Overlay — First 200 ms');
plot(t(1:200), signal_normal(1:200), 'Color', [0.11 0.62 0.46], ...
     'LineWidth', 1.5, 'DisplayName', 'Normal');
hold on;
plot(t(1:200), signal_faulty(1:200), 'Color', [0.85 0.33 0.10], ...
     'LineWidth', 1.5, 'DisplayName', 'Faulty');
hold off;
title('Zoomed Overlay — Normal vs Faulty (First 200 ms)');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Location', 'best');
grid on;

% --- Console summary ---
fprintf('\n--- Step 2 Summary ---\n');
fprintf('Normal signal RMS : %.4f\n', rms(signal_normal));
fprintf('Faulty signal RMS : %.4f\n', rms(signal_faulty));
fprintf('RMS ratio (F/N)   : %.4f\n', rms(signal_faulty)/rms(signal_normal));
fprintf('Fault frequency   : %d Hz\n', freq_fault);
fprintf('Fault amplitude   : %.1f\n', amp_fault);
fprintf('Noise level       : %.1f\n', noise_level);
fprintf('----------------------\n');