%% =========================================================================
%  RACE DATA DASHBOARD
%  =========================================================================
%  Author      : Eliazar Alvarez
%  Date        : April 2026
%  Institution : University of Texas at San Antonio
%  Description : Lap time analysis dashboard using real Formula 1 race data.
%                Analyzes lap time progression, consistency, and cumulative
%                time gap between drivers. Skills directly applicable to
%                NASCAR, IndyCar, and IMSA data engineering roles.
%  Race        : 2011 Brazilian Grand Prix (Race ID 841)
%  Drivers     : Sebastian Vettel (P1) vs Jenson Button (P3)
%  Data Source : Kaggle — Formula 1 World Championship 1950-2020
%  Tools       : MATLAB
%  GitHub      : github.com/aeliazar11/Race-Data-Dashboard
%% =========================================================================

%% --- HOUSEKEEPING ---
clear;
clc;
close all;

%% --- LOAD DATA ---
data = readtable('lap_times.csv');

% Preview the first few rows to confirm it loaded correctly
disp('Column names:');
disp(data.Properties.VariableNames);
disp('First 5 rows:');
disp(data(1:5,:));
%% --- FILTER: SELECT ONE RACE AND TWO DRIVERS ---
% Race 841 = 2011 Brazilian Grand Prix
% Driver 20 = Sebastian Vettel (race winner)
% Driver 4  = Jenson Button (finished 3rd)

race_id     = 841;
driver1_id  = 20;
driver2_id  = 4;

% Filter data for each driver in this race
d1 = data(data.raceId == race_id & data.driverId == driver1_id, :);
d2 = data(data.raceId == race_id & data.driverId == driver2_id, :);

% Convert milliseconds to seconds for cleaner numbers on plots
d1_seconds = d1.milliseconds / 1000;
d2_seconds = d2.milliseconds / 1000;

% Lap numbers for each driver
d1_laps = d1.lap;
d2_laps = d2.lap;

% Quick sanity check — print how many laps each driver completed
fprintf('Driver 1 (Vettel) laps: %d\n', height(d1));
fprintf('Driver 2 (Button) laps: %d\n', height(d2));
fprintf('Driver 1 fastest lap: %.3f seconds\n', min(d1_seconds));
fprintf('Driver 2 fastest lap: %.3f seconds\n', min(d2_seconds));
%% =========================================================================
%  SECTION 1 — LAP TIME PROGRESSION
%% =========================================================================

%% --- FIGURE 1: Lap Time Trace — Both Drivers ---
figure(1);
hold on;
plot(d1_laps, d1_seconds, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Vettel (P1)');
plot(d2_laps, d2_seconds, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Button (P3)');
hold off;

xlabel('Lap Number');
ylabel('Lap Time (seconds)');
title('Lap Time Progression — 2011 Brazilian Grand Prix');
legend('show', 'Location', 'northeast');
grid on;set(gcf,'Color','white');set(gca,'Color','white')
xlim([1 58]);

% Add annotation explaining the spike
annotation('textbox', [0.15 0.75 0.2 0.08], ...
    'String', 'Lap 1: Formation + traffic', ...
    'FitBoxToText', 'on', ...
    'BackgroundColor', 'white', ...
    'FontSize', 8);
%% =========================================================================
%  SECTION 2 — LAP TIME CONSISTENCY
%% =========================================================================

%% --- REMOVE PIT STOP LAPS FOR CLEAN ANALYSIS ---
% Pit stop laps are outliers — remove anything more than 5 seconds
% slower than each driver's median lap time
d1_median = median(d1_seconds);
d2_median = median(d2_seconds);

d1_clean = d1_seconds(d1_seconds < d1_median + 5);
d2_clean = d2_seconds(d2_seconds < d2_median + 5);

%% --- CALCULATE CONSISTENCY STATS ---
fprintf('\n--- PERFORMANCE SUMMARY ---\n');
fprintf('Vettel  | Median: %.3fs | Std Dev: %.3fs | Fastest: %.3fs\n', ...
    median(d1_clean), std(d1_clean), min(d1_clean));
fprintf('Button  | Median: %.3fs | Std Dev: %.3fs | Fastest: %.3fs\n', ...
    median(d2_clean), std(d2_clean), min(d2_clean));

%% --- FIGURE 2: Lap Time Distribution ---
figure(2);
hold on;
histogram(d1_clean, 15, 'FaceColor', 'blue', 'FaceAlpha', 0.5, ...
    'DisplayName', 'Vettel (P1)');
histogram(d2_clean, 15, 'FaceColor', 'red', 'FaceAlpha', 0.5, ...
    'DisplayName', 'Button (P3)');
hold off;

xlabel('Lap Time (seconds)');
ylabel('Number of Laps');
title('Lap Time Distribution — 2011 Brazilian Grand Prix');
legend('show', 'Location', 'northwest');
grid on;
set(gcf, 'Color', 'white');
set(gca, 'Color', 'white');
%% =========================================================================
%  SECTION 3 — DELTA TIME ANALYSIS
%  =========================================================================
% Delta time shows the cumulative time gap between two drivers.
% This is how race engineers track whether a gap is growing or shrinking.

%% --- CALCULATE CUMULATIVE LAP TIMES ---
% Only compare laps both drivers completed
num_laps = min(length(d1_seconds), length(d2_seconds));

d1_cumulative = cumsum(d1_seconds(1:num_laps));   % Running total time (s)
d2_cumulative = cumsum(d2_seconds(1:num_laps));   % Running total time (s)

% Delta = how far ahead Vettel is vs Button at each lap
% Positive = Vettel is ahead, Negative = Button is ahead
delta = d1_cumulative - d2_cumulative;

%% --- FIGURE 3: Delta Time ---
figure(3);
hold on;

% Fill above/below zero with different colors
% Green fill where Vettel leads, red fill where Button leads
fill([1:num_laps, fliplr(1:num_laps)], ...
     [delta', zeros(1,num_laps)], ...
     'blue', 'FaceAlpha', 0.15, 'EdgeColor', 'none', ...
     'HandleVisibility', 'off');

plot(1:num_laps, delta, 'b-', 'LineWidth', 2, 'DisplayName', 'Gap (Vettel - Button)');
yline(0, 'k--', 'LineWidth', 1, 'HandleVisibility', 'off');
hold off;

xlabel('Lap Number');
ylabel('Cumulative Time Delta (seconds)');
title('Time Gap — Vettel vs Button | 2011 Brazilian Grand Prix');
legend('show', 'Location', 'best');
grid on;
xlim([1 num_laps]);
set(gcf, 'Color', 'white');
set(gca, 'Color', 'white');

% Add reference annotations
text(5, max(delta)*0.85, 'Above 0 = Vettel ahead', ...
    'FontSize', 9, 'Color', 'blue');
text(5, min(delta)*0.85, 'Below 0 = Button ahead', ...
    'FontSize', 9, 'Color', 'red');