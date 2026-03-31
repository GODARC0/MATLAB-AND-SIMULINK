% SNR in decibels — the professional way to report it
signal_power = 0.5;        % RMS power of a unit sine = 0.5
snr_linear = signal_power / noise_power;
snr_dB = 10 * log10(snr_linear);
fprintf('SNR (linear)        : %.2f\n', snr_linear);
fprintf('SNR (dB)            : %.2f dB\n', snr_dB);
% Rule of thumb: SNR > 10 dB = signal clearly visible above noise