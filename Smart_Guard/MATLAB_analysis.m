% ============================================================
%  SmartGuard — MATLAB Signal Analysis & Fault Detection
%  Works with: dummy data (now) or real ESP32 CSV (later)
%  Faults detected: Overcurrent, Undervoltage, Overvoltage,
%                   Thermal Overload (predictive)
%  Author: godarc | Project: SmartGuard
% ============================================================

clc; clear; close all;

%% ============================================================
%  SECTION 1 — DATA SOURCE
%  To switch to real data later: change USE_DUMMY to false
%  and set CSV_FILE to your actual file path
% ============================================================

USE_DUMMY = true;
CSV_FILE  = 'session_2026-04-11_15-29-08.csv';  % Real ESP32 CSV when ready

if USE_DUMMY
    data = generate_dummy_data();
    disp('Using simulated dummy data.');
else
    raw  = readtable(CSV_FILE);
    data.time  = raw{:,1} / 1000;   % ms → seconds
    data.acV   = raw{:,2};
    data.dcV   = raw{:,3};
    data.curr  = raw{:,4};
    data.temp  = raw{:,5};
    fprintf('Loaded real data: %d samples from %s\n', length(data.time), CSV_FILE);
end

N = length(data.time);
fprintf('Total samples: %d | Duration: %.1f seconds\n', N, data.time(end));

%% ============================================================
%  SECTION 2 — FAULT THRESHOLDS (from our hardware analysis)
% ============================================================

thresh.dcV_low       = 10.0;   % V  — undervoltage fault
thresh.dcV_warn      = 10.5;   % V  — undervoltage warning
thresh.dcV_high      = 12.8;   % V  — overvoltage fault
thresh.curr_warn     = 1.5;    % A  — overcurrent warning
thresh.curr_fault    = 1.8;    % A  — overcurrent fault
thresh.curr_stall    = 3.0;    % A  — stall / hard fault
thresh.temp_warn     = 55.0;   % °C — thermal warning
thresh.temp_fault    = 70.0;   % °C — thermal fault
thresh.temp_rate     = 4.0;    % °C/min — rate of rise fault (predictive)
thresh.acV_low       = 200.0;  % V  — AC undervoltage
thresh.acV_high      = 250.0;  % V  — AC overvoltage

%% ============================================================
%  SECTION 3 — FAULT DETECTION
% ============================================================

% --- 3.1 Overcurrent ---
fault.overcurrent      = data.curr > thresh.curr_fault;
fault.overcurrent_warn = data.curr > thresh.curr_warn & ~fault.overcurrent;
fault.stall            = data.curr > thresh.curr_stall;

% --- 3.2 DC Undervoltage ---
fault.undervoltage      = data.dcV < thresh.dcV_low;
fault.undervoltage_warn = data.dcV < thresh.dcV_warn & ~fault.undervoltage;

% --- 3.3 DC Overvoltage ---
fault.overvoltage = data.dcV > thresh.dcV_high;

% --- 3.4 AC Supply Faults ---
fault.ac_low  = data.acV < thresh.acV_low;
fault.ac_high = data.acV > thresh.acV_high;

% --- 3.5 Thermal Fault (static threshold) ---
fault.thermal_warn  = data.temp > thresh.temp_warn;
fault.thermal_fault = data.temp > thresh.temp_fault;

% --- 3.6 Predictive Thermal — Rate of Rise (the key innovation) ---
% Calculate temperature rate of change in °C/min
dt_min       = diff(data.time) / 60;          % time diff in minutes
dT           = diff(data.temp);               % temp diff in °C
temp_rate    = dT ./ dt_min;                  % °C per minute
temp_rate    = [0; temp_rate(:)];             % pad first sample

% Smooth the rate to reduce noise (moving average, window=10)
window = 10;
temp_rate_smooth = movmean(temp_rate, window);

% Predictive fault flag — rising fast before hitting hard limit
fault.predictive = temp_rate_smooth > thresh.temp_rate & ...
                   data.temp > 40 & ...       % only flag if already warm
                   ~fault.thermal_fault;      % not already in hard fault

% Predict time to critical temperature using linear extrapolation
predict_times = zeros(N, 1);
for i = window+1 : N
    if temp_rate_smooth(i) > 0.5
        temp_remaining = thresh.temp_fault - data.temp(i);
        time_to_fault  = temp_remaining / temp_rate_smooth(i); % minutes
        predict_times(i) = max(0, time_to_fault);
    end
end

%% ============================================================
%  SECTION 4 — RMS & STATISTICS
% ============================================================

rms_current  = rms(data.curr);
rms_dcV      = rms(data.dcV);
mean_temp    = mean(data.temp);
max_temp     = max(data.temp);
max_current  = max(data.curr);
min_dcV      = min(data.dcV);

% RMSE between DC voltage and nominal (12V)
rmse_voltage = sqrt(mean((data.dcV - 12.0).^2));

fprintf('\n=== SmartGuard Signal Statistics ===\n');
fprintf('RMS Current      : %.4f A\n',   rms_current);
fprintf('RMS DC Voltage   : %.4f V\n',   rms_dcV);
fprintf('Mean Temperature : %.2f C\n',   mean_temp);
fprintf('Max Temperature  : %.2f C\n',   max_temp);
fprintf('Max Current      : %.4f A\n',   max_current);
fprintf('Min DC Voltage   : %.4f V\n',   min_dcV);
fprintf('RMSE (DC vs 12V) : %.4f V\n',   rmse_voltage);
fprintf('\n=== Fault Summary ===\n');
fprintf('Overcurrent faults    : %d samples\n', sum(fault.overcurrent));
fprintf('Undervoltage faults   : %d samples\n', sum(fault.undervoltage));
fprintf('Overvoltage faults    : %d samples\n', sum(fault.overvoltage));
fprintf('Thermal faults        : %d samples\n', sum(fault.thermal_fault));
fprintf('Predictive alerts     : %d samples\n', sum(fault.predictive));

%% ============================================================
%  SECTION 5 — FFT ANALYSIS ON CURRENT SIGNAL
% ============================================================

Fs = 1 / mean(diff(data.time));   % Sampling frequency (Hz)
L  = N;
Y  = fft(data.curr);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2 * P1(2:end-1);
f  = Fs * (0:floor(L/2)) / L;

% Find dominant frequency peaks
[pks, locs] = findpeaks(P1, f, 'MinPeakHeight', 0.02, 'MinPeakDistance', 0.5);
fprintf('\n=== FFT Dominant Frequency Peaks ===\n');
for k = 1:min(5, length(pks))
    fprintf('  Peak at %.2f Hz — amplitude %.4f A\n', locs(k), pks(k));
end

%% ============================================================
%  SECTION 6 — PLOTS
% ============================================================

fig_color   = [0.97 0.97 0.97];
fault_red   = [0.85 0.15 0.15];
warn_orange = [0.95 0.55 0.10];
pred_purple = [0.50 0.10 0.80];
normal_blue = [0.15 0.45 0.75];
green_ok    = [0.10 0.65 0.30];

% ── Figure 1: Time Domain Overview ──
figure('Name','SmartGuard — Time Domain','Color',fig_color,'Position',[50 50 1200 800]);
sgtitle('SmartGuard — Sensor Signals & Fault Detection', 'FontSize', 14, 'FontWeight', 'bold');

% Plot 1: DC Current
subplot(4,1,1);
plot(data.time, data.curr, 'Color', normal_blue, 'LineWidth', 1.2); hold on;
yline(thresh.curr_fault, '--', 'Color', fault_red,   'LineWidth', 1.5, 'Label', 'Fault threshold');
yline(thresh.curr_warn,  '--', 'Color', warn_orange, 'LineWidth', 1.2, 'Label', 'Warning');
scatter(data.time(fault.overcurrent), data.curr(fault.overcurrent), 40, fault_red, 'filled', 'DisplayName','Fault');
scatter(data.time(fault.overcurrent_warn), data.curr(fault.overcurrent_warn), 25, warn_orange, 'filled', 'DisplayName','Warning');
ylabel('Current (A)'); title('DC Motor Current'); grid on; legend('Signal','Location','northeast');
xlim([data.time(1) data.time(end)]);

% Plot 2: DC Voltage
subplot(4,1,2);
plot(data.time, data.dcV, 'Color', normal_blue, 'LineWidth', 1.2); hold on;
yline(thresh.dcV_low,  '--', 'Color', fault_red,   'LineWidth', 1.5, 'Label', 'UV Fault');
yline(thresh.dcV_high, '--', 'Color', fault_red,   'LineWidth', 1.5, 'Label', 'OV Fault');
yline(thresh.dcV_warn, '--', 'Color', warn_orange, 'LineWidth', 1.2, 'Label', 'UV Warning');
scatter(data.time(fault.undervoltage), data.dcV(fault.undervoltage), 40, fault_red, 'filled');
scatter(data.time(fault.overvoltage),  data.dcV(fault.overvoltage),  40, [0.8 0.1 0.8], 'filled');
ylabel('Voltage (V)'); title('DC Bus Voltage'); grid on;
xlim([data.time(1) data.time(end)]);

% Plot 3: Temperature
subplot(4,1,3);
plot(data.time, data.temp, 'Color', [0.80 0.30 0.10], 'LineWidth', 1.2); hold on;
yline(thresh.temp_warn,  '--', 'Color', warn_orange, 'LineWidth', 1.2, 'Label', 'Warning 55°C');
yline(thresh.temp_fault, '--', 'Color', fault_red,   'LineWidth', 1.5, 'Label', 'Fault 70°C');
scatter(data.time(fault.predictive), data.temp(fault.predictive), 30, pred_purple, 'filled', 'DisplayName','Predictive alert');
scatter(data.time(fault.thermal_fault), data.temp(fault.thermal_fault), 40, fault_red, 'filled', 'DisplayName','Thermal fault');
ylabel('Temperature (°C)'); title('Motor Body Temperature'); grid on;
legend('Temp','Location','northwest'); xlim([data.time(1) data.time(end)]);

% Plot 4: AC Voltage
subplot(4,1,4);
plot(data.time, data.acV, 'Color', [0.20 0.55 0.20], 'LineWidth', 1.2); hold on;
yline(thresh.acV_low,  '--', 'Color', fault_red, 'LineWidth', 1.5, 'Label', 'AC Low');
yline(thresh.acV_high, '--', 'Color', fault_red, 'LineWidth', 1.5, 'Label', 'AC High');
ylabel('Voltage (V)'); title('AC Mains Voltage (ZMPT101B)'); grid on;
xlabel('Time (seconds)'); xlim([data.time(1) data.time(end)]);

% ── Figure 2: FFT Analysis ──
figure('Name','SmartGuard — FFT Analysis','Color',fig_color,'Position',[100 100 900 500]);
plot(f, P1, 'Color', normal_blue, 'LineWidth', 1.3); hold on;
scatter(locs, pks, 60, fault_red, 'filled');
for k = 1:min(3, length(pks))
    text(locs(k), pks(k)+0.005, sprintf('%.1f Hz', locs(k)), ...
         'FontSize', 9, 'Color', fault_red, 'HorizontalAlignment','center');
end
xlabel('Frequency (Hz)'); ylabel('Amplitude (A)');
title('FFT — Current Signal Frequency Spectrum');
subtitle('Abnormal peaks indicate mechanical or electrical faults');
grid on; xlim([0 min(50, Fs/2)]);

% ── Figure 3: Predictive Thermal Analysis ──
figure('Name','SmartGuard — Predictive Thermal','Color',fig_color,'Position',[150 150 900 600]);

subplot(2,1,1);
plot(data.time, data.temp, 'Color', [0.80 0.30 0.10], 'LineWidth', 1.5); hold on;

% Trend line using polyfit over last 30% of data
trend_start = floor(0.7 * N);
p = polyfit(data.time(trend_start:end), data.temp(trend_start:end), 1);
t_extend = linspace(data.time(trend_start), data.time(end)*1.4, 100);
temp_proj = polyval(p, t_extend);
plot(t_extend, temp_proj, '--', 'Color', pred_purple, 'LineWidth', 1.5, 'DisplayName', 'Projected trend');

% Mark where projection crosses fault threshold
t_cross_idx = find(temp_proj >= thresh.temp_fault, 1);
if ~isempty(t_cross_idx)
    xline(t_extend(t_cross_idx), '-.', 'Color', fault_red, 'LineWidth', 1.5, 'Label', 'Predicted fault time');
    advance_warning = t_extend(t_cross_idx) - data.time(end);
    title(sprintf('Motor Temperature + Trend Projection  |  Advance warning: %.0f seconds (%.1f min)', ...
          advance_warning, advance_warning/60));
else
    title('Motor Temperature + Trend Projection');
end
yline(thresh.temp_fault, '--', 'Color', fault_red,   'LineWidth', 1.5, 'Label', '70°C fault');
yline(thresh.temp_warn,  '--', 'Color', warn_orange, 'LineWidth', 1.2, 'Label', '55°C warning');
ylabel('Temperature (°C)'); grid on; legend('Location','northwest');
xlim([data.time(1) t_extend(end)]);

subplot(2,1,2);
plot(data.time, temp_rate_smooth, 'Color', pred_purple, 'LineWidth', 1.3); hold on;
yline(thresh.temp_rate, '--', 'Color', fault_red, 'LineWidth', 1.5, 'Label', 'Rate threshold');
scatter(data.time(fault.predictive), temp_rate_smooth(fault.predictive), 40, fault_red, 'filled');
xlabel('Time (seconds)'); ylabel('Rate (°C/min)');
title('Temperature Rate of Rise — Predictive Fault Indicator');
grid on; xlim([data.time(1) data.time(end)]);

% ── Figure 4: Fault Event Timeline ──
figure('Name','SmartGuard — Fault Timeline','Color',fig_color,'Position',[200 200 1000 400]);
hold on;

fault_types = {'Overcurrent','Undervoltage','Overvoltage','Thermal','Predictive','AC Fault'};
fault_flags = {fault.overcurrent, fault.undervoltage, fault.overvoltage, ...
               fault.thermal_fault, fault.predictive, fault.ac_low | fault.ac_high};
colors = {fault_red, [0.1 0.4 0.8], [0.7 0.1 0.7], [0.9 0.4 0.1], pred_purple, green_ok};

for k = 1:length(fault_types)
    idx = find(fault_flags{k});
    if ~isempty(idx)
        scatter(data.time(idx), k*ones(size(idx)), 30, colors{k}, 'filled');
    end
end

yticks(1:length(fault_types)); yticklabels(fault_types);
xlabel('Time (seconds)'); title('Fault Event Timeline');
grid on; xlim([data.time(1) data.time(end)]);
ylim([0 length(fault_types)+1]);

fprintf('\nAll plots generated successfully.\n');

%% ============================================================
%  SECTION 7 — EXPORT RESULTS TO CSV
% ============================================================

results = table(data.time, data.curr, data.dcV, data.acV, data.temp, ...
                temp_rate_smooth, ...
                fault.overcurrent, fault.undervoltage, fault.overvoltage, ...
                fault.thermal_fault, fault.predictive, ...
                'VariableNames', {'time_s','current_A','dc_voltage_V', ...
                'ac_voltage_V','temperature_C','temp_rate_Cpermin', ...
                'fault_overcurrent','fault_undervoltage','fault_overvoltage', ...
                'fault_thermal','fault_predictive'});

writetable(results, 'smartguard_analysis_results.csv');
fprintf('Results exported to smartguard_analysis_results.csv\n');

%% ============================================================
%  HELPER FUNCTION — Generate Realistic Dummy Data
% ============================================================

function data = generate_dummy_data()
    % 300 seconds of data at 2Hz = 600 samples
    Fs   = 2;
    t    = (0:1/Fs:299)';
    N    = length(t);

    % --- Normal DC Voltage (12V with small noise) ---
    dcV = 11.8 + 0.2*randn(N,1);

    % Inject undervoltage fault: samples 200-240 (pot turned down)
    dcV(200:240) = linspace(11.8, 9.2, 41)';

    % Inject overvoltage spike: samples 400-410
    dcV(400:410) = 13.2 + 0.1*randn(11,1);

    % --- Normal Current (0.6A idle, rises with load) ---
    curr = 0.6 + 0.05*randn(N,1);

    % Normal loaded section: 50-180 samples
    curr(50:180) = 1.0 + 0.08*randn(131,1);

    % Inject overcurrent fault: samples 260-280 (short circuit sim)
    curr(260:280) = 2.2 + 0.15*randn(21,1);

    % Stall current spike: sample 350-355
    curr(350:355) = 3.4 + 0.2*randn(6,1);

    % --- Temperature (starts at 28°C, rises with load) ---
    temp = zeros(N,1);
    temp(1) = 28;
    for i = 2:N
        if i < 50
            rate = 0.02;       % idle warmup
        elseif i < 180
            rate = 0.12;       % normal running
        elseif i < 260
            rate = 0.06;       % light load
        else
            rate = 0.22;       % heavy load — thermal fault building
        end
        temp(i) = temp(i-1) + rate + 0.05*randn();
    end

    % --- AC Voltage (230V nominal with small variation) ---
    acV = 228 + 3*randn(N,1);

    % Inject AC undervoltage dip: samples 480-510
    acV(480:510) = linspace(228, 195, 31)';

    data.time = t;
    data.dcV  = dcV;
    data.curr = abs(curr);
    data.temp = temp;
    data.acV  = acV;
end