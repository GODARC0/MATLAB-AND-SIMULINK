%% Step 3: FFT Analysis — Frequency Domain
% -----------------------------------------------
% Project: Predictive Maintenance Using Signal Processing
% Author : Mohd Luqmaan
% -----------------------------------------------

%   Time domain shows HOW MUCH vibration. Frequency domain shows
%   WHERE the vibration is coming from. 
% -----------------------------------------------

% --- Load both signals ---
load('normal_signal.mat');   % signal_normal, t, fs
load('faulty_signal.mat');   % signal_faulty

N = length(t);               % Total number of samples = 1000


fft_normal_raw = fft(signal_normal);         % Complex FFT output
fft_faulty_raw = fft(signal_faulty);

mag_normal = abs(fft_normal_raw) / N;        % Normalised magnitude
mag_faulty = abs(fft_faulty_raw) / N;

% Keep only positive frequency half
half = 1 : N/2 + 1;
mag_normal_half = 2 * mag_normal(half);
mag_faulty_half = 2 * mag_faulty(half);

% Build the frequency axis — each index maps to a real Hz value
% freq(k) = (k-1) * fs / N
f_axis = (0 : N/2) * fs / N;   % Goes from 0 Hz to 500 Hz in 1 Hz steps


% PLOT 1: Side-by-side FFT spectra

figure('Name', 'FFT Analysis — Frequency Domain');

subplot(2,1,1);
plot(f_axis, mag_normal_half, 'Color', [0.11 0.62 0.46], 'LineWidth', 1.5);
title('FFT — Normal Signal (Healthy Machine)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 300]);
grid on;
% Mark the 50 Hz peak
[pk_n, idx_n] = max(mag_normal_half(1:300));
text(f_axis(idx_n)+5, pk_n, sprintf('50 Hz\nA=%.2f', pk_n), ...
     'Color', [0.11 0.62 0.46], 'FontSize', 9);

subplot(2,1,2);
plot(f_axis, mag_faulty_half, 'Color', [0.85 0.33 0.10], 'LineWidth', 1.5);
title('FFT — Faulty Signal (Bearing Defect Simulated)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([0 300]);
grid on;
% Mark the two peaks automatically
[~, sorted_idx] = sort(mag_faulty_half(1:300), 'descend');
top2 = sorted_idx(1:2);
for k = 1:2
    text(f_axis(top2(k))+4, mag_faulty_half(top2(k)), ...
         sprintf('%.0f Hz\nA=%.2f', f_axis(top2(k)), mag_faulty_half(top2(k))), ...
         'Color', [0.85 0.33 0.10], 'FontSize', 9);
end


% PLOT 2: Overlay — see the extra fault spike clearly

figure('Name', 'FFT Overlay — Normal vs Faulty');
plot(f_axis, mag_normal_half, 'Color', [0.11 0.62 0.46], ...
     'LineWidth', 2, 'DisplayName', 'Normal');
hold on;
plot(f_axis, mag_faulty_half, 'Color', [0.85 0.33 0.10], ...
     'LineWidth', 1.5, 'DisplayName', 'Faulty');
hold off;
xlim([0 300]);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('FFT Overlay — Normal vs Faulty');
legend('Location', 'northeast');
grid on;

% -----------------------------------------------
% PLOT 3: Stem plot — cleaner view of discrete peaks
% -----------------------------------------------
figure('Name', 'FFT Stem Plot — Fault Peaks');
subplot(1,2,1);
stem(f_axis(1:300), mag_normal_half(1:300), 'Color', [0.11 0.62 0.46], ...
     'MarkerSize', 3, 'LineWidth', 0.8);
title('Normal — Stem');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(1,2,2);
stem(f_axis(1:300), mag_faulty_half(1:300), 'Color', [0.85 0.33 0.10], ...
     'MarkerSize', 3, 'LineWidth', 0.8);
title('Faulty — Stem');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

% -----------------------------------------------
% CONSOLE REPORT
% -----------------------------------------------
% Find the actual peak magnitudes at 50 Hz and 120 Hz
idx_50  = round(50  * N/fs) + 1;   % index for 50 Hz
idx_120 = round(120 * N/fs) + 1;   % index for 120 Hz

fprintf('\n====== FFT Analysis Report ======\n');
fprintf('\nNORMAL signal:\n');
fprintf('  Peak at 50 Hz  : magnitude = %.4f\n', mag_normal_half(idx_50));
fprintf('  Peak at 120 Hz : magnitude = %.4f  (should be ~0)\n', mag_normal_half(idx_120));

fprintf('\nFAULTY signal:\n');
fprintf('  Peak at 50 Hz  : magnitude = %.4f\n', mag_faulty_half(idx_50));
fprintf('  Peak at 120 Hz : magnitude = %.4f  (FAULT COMPONENT)\n', mag_faulty_half(idx_120));

fprintf('\nFault detection:\n');
fault_threshold = 0.3;   % if 120 Hz peak exceeds this → fault
if mag_faulty_half(idx_120) > fault_threshold
    fprintf('  STATUS: FAULT DETECTED at 120 Hz (magnitude %.4f > threshold %.2f)\n', ...
            mag_faulty_half(idx_120), fault_threshold);
else
    fprintf('  STATUS: Normal\n');
end
fprintf('=================================\n');