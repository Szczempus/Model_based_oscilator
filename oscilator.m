%% SiT5346 - simple oscillator model

clear;
clc;

%% Oscillator parameters
f0 = 10e6;          % Nominal frequency [Hz]
y0 = 0.1e-6;        % Initial fractional frequency error [-]

%% Simulation
Ts = 0.1;           % Simulation step [s]
t_end = 100;        % Simulation duration [s]
t = 0:Ts:t_end;

%% Frequency error
y = y0 * ones(size(t));

%% Actual oscillator frequency
f = f0 .* (1 + y);

%% Clock time error
x = cumtrapz(t, y);

%% Convert time error to nanoseconds
x_ns = x * 1e9;

%% Results
fprintf("Nominal frequency: %.0f Hz\n", f0);
fprintf("Actual frequency:  %.3f Hz\n", f(1));
fprintf("Frequency offset:  %.3f Hz\n", f(1)-f0);
fprintf("Time error after %.0f s: %.1f ns\n", ...
        t_end, x_ns(end));

%% Plot
figure;
plot(t, x_ns);
grid on;

xlabel("Time [s]");
ylabel("Clock error [ns]");
title("SiT5346 clock error");