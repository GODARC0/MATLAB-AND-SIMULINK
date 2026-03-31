% Step 4: RMS Calculation and Fault Detection
fs = 1000;
t = 0:1/fs:1-1/fs;

signal_normal = sin(2 * pi * 50 * t);
signal_faulty = signal_normal + 0.8*sin(2*pi*120*t) + 0.5*randn(size(t));

% RMS (Root Mean Square) — overall vibration energy
rms_normal = rms(signal_normal);
rms_faulty = rms(signal_faulty);

fprintf('RMS - Normal Signal: %.4f\n', rms_normal);
fprintf('RMS - Faulty Signal: %.4f\n', rms_faulty);

% Set a threshold for fault detection
threshold = 0.9;  % Adjust based on your results
if rms_faulty > threshold
    fprintf('FAULT DETECTED! RMS exceeds threshold of %.2f\n', threshold);
else
    fprintf('Signal is NORMAL.\n');
end

% Bar chart comparison
figure;
bar([rms_normal, rms_faulty]);
set(gca, 'XTickLabel', {'Normal', 'Faulty'});
title('RMS Comparison: Normal vs Faulty Signal');
ylabel('RMS Value');
yline(threshold, '--r', 'Fault Threshold');
grid on;