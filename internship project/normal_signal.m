%% Step 1: Normal Vibration Signal Generation
% -----------------------------------------------
% Project: Predictive Maintenance Using Signal Processing
% Author : Mohd Luqmaan
% -----------------------------------------------

% --- Parameters ---
fs = 1000;           % Sampling frequency: 1000 samples per second
t  = 0 : 1/fs : 1 - 1/fs;   % Time vector: 1 second, sampled every 1ms

% --- Generate Normal Signal ---
freq_normal = 50;                          % Machine runs at 50 Hz (healthy)
signal_normal = sin(2 * pi * freq_normal * t);   % Pure sine wave

% --- Save data for later steps ---
save('normal_signal.mat', 'signal_normal', 't', 'fs');

% --- Plot ---
figure('Name', 'Normal Vibration Signal');

subplot(2,1,1);
plot(t, signal_normal, 'Color', [0.11 0.62 0.46]);
title('Normal Vibration Signal — Full 1 Second');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t(1:200), signal_normal(1:200), 'Color', [0.11 0.62 0.46], 'LineWidth', 1.5);
title('Zoomed View — First 200 ms');
xlabel('Time (seconds)');
ylabel('Amplitude');
grid on;

% --- Print summary to console ---
fprintf('\n--- Signal Summary ---\n');
fprintf('Sampling frequency : %d Hz\n', fs);
fprintf('Duration           : %.1f second\n', t(end));
fprintf('Total samples      : %d\n', length(t));
fprintf('Signal frequency   : %d Hz\n', freq_normal);
fprintf('Max amplitude      : %.4f\n', max(signal_normal));
fprintf('Min amplitude      : %.4f\n', min(signal_normal));
fprintf('RMS value          : %.4f\n', rms(signal_normal));
fprintf('----------------------\n');
