% Step 2: Simulate a Faulty Vibration Signal
fs = 1000;
t = 0:1/fs:1-1/fs;

% Normal component (50 Hz)
signal_normal = sin(2 * pi * 50 * t);

% Fault component: extra frequency at 120 Hz + random noise
fault_freq = 120;
noise = 0.5 * randn(size(t));           % Random noise
fault_component = 0.8 * sin(2 * pi * fault_freq * t);

signal_faulty = signal_normal + fault_component + noise;

% Compare both signals side by side
figure;
subplot(2,1,1);
plot(t(1:200), signal_normal(1:200));
title('Normal Signal'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
plot(t(1:200), signal_faulty(1:200), 'r');
title('Faulty Signal'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;