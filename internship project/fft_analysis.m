% Step 3: FFT Analysis — Frequency Domain
fs = 1000;
t = 0:1/fs:1-1/fs;
N = length(t);  % Number of samples

signal_normal = sin(2 * pi * 50 * t);
signal_faulty = signal_normal + 0.8*sin(2*pi*120*t) + 0.5*randn(size(t));

% Compute FFT for both signals
fft_normal = abs(fft(signal_normal)) / N;
fft_faulty = abs(fft(signal_faulty)) / N;

% Frequency axis (only positive half needed)
f = (0:N/2) * fs / N;
fft_normal_half = 2 * fft_normal(1:N/2+1);
fft_faulty_half = 2 * fft_faulty(1:N/2+1);

% Plot
figure;
subplot(2,1,1);
plot(f, fft_normal_half);
title('FFT of Normal Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(2,1,2);
plot(f, fft_faulty_half, 'r');
title('FFT of Faulty Signal');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
xlim([0 300]);  % Focus on 0-300 Hz range