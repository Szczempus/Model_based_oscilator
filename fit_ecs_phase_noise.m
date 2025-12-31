clear;
clc;
close all;

%% ECS-TXO53-S3, 50 MHz
f0 = 50e6;

f_pn = [1 10 100 1e3 10e3 100e3]';
L_pn = [-55 -83 -108 -130 -148 -155]';

%% SSB phase noise -> one-sided phase PSD
Sphi_meas = 2 .* 10.^(L_pn/10);

%% Model:
% S_phi(f) = h_-4/f^4 + h_-3/f^3 + h_-2/f^2 + h_-1/f + h_0

A = [ ...
    1./f_pn.^4, ...
    1./f_pn.^3, ...
    1./f_pn.^2, ...
    1./f_pn, ...
    ones(size(f_pn)) ];

%% Non-negative least squares
h = lsqnonneg(A,Sphi_meas);

disp('Noise coefficients:')
disp(h)

Sphi_fit = A*h;

L_fit = 10*log10(Sphi_fit/2);

fprintf('\nComparison:\n');
fprintf('f [Hz]       ECS [dBc/Hz]      Model [dBc/Hz]\n');

for k = 1:length(f_pn)
    fprintf('%8g       %8.2f            %8.2f\n', ...
        f_pn(k),L_pn(k),L_fit(k));
end

f_plot = logspace(0,5,2000)';

A_plot = [ ...
    1./f_plot.^4, ...
    1./f_plot.^3, ...
    1./f_plot.^2, ...
    1./f_plot, ...
    ones(size(f_plot)) ];

Sphi_plot = A_plot*h;

L_plot = 10*log10(Sphi_plot/2);

figure;
semilogx(f_plot,L_plot,'LineWidth',1.5);
hold on;
semilogx(f_pn,L_pn,'o','MarkerSize',8,'LineWidth',1.5);

grid on;
xlabel('Offset frequency [Hz]');
ylabel('SSB Phase Noise L(f) [dBc/Hz]');
title('ECS-TXO53-S3 Phase Noise Model');
legend('Power-law model','ECS datasheet points','Location','best');



%% Log-domain fit

% początkowe przybliżenie
q0 = [-10 -8 -6 -8 -15];

% q = log10(h)
costFun = @(q) phaseNoiseError(q, f_pn, L_pn);

options = optimoptions('lsqnonlin', ...
    'Display','iter', ...
    'MaxFunctionEvaluations',10000, ...
    'MaxIterations',2000);

q_fit = lsqnonlin(costFun, q0, [], [], options);

h_fit = 10.^q_fit(:);

disp('Fitted noise coefficients:')
disp(h_fit)

%% Wyniki w punktach ECS

A = [ ...
    1./f_pn.^4, ...
    1./f_pn.^3, ...
    1./f_pn.^2, ...
    1./f_pn, ...
    ones(size(f_pn)) ];

Sphi_fit = A*h_fit;

L_fit = 10*log10(Sphi_fit/2);

fprintf('\nComparison:\n');
fprintf('f [Hz]     ECS [dBc/Hz]    Model [dBc/Hz]    Error [dB]\n');

for k = 1:length(f_pn)
    fprintf('%8g      %8.2f          %8.2f        %+7.2f\n', ...
        f_pn(k), L_pn(k), L_fit(k), L_fit(k)-L_pn(k));
end

h_m3 = 6.836999747127976e-06;
h_m2 = 2.152148613888309e-07;
h_m1 = 3.812740009320457e-12;
h_0  = 5.748270274700225e-16;

f = logspace(0,5,2000);

S_m3 = h_m3 ./ f.^3;
S_m2 = h_m2 ./ f.^2;
S_m1 = h_m1 ./ f;
S_0  = h_0 .* ones(size(f));

S_total = S_m3 + S_m2 + S_m1 + S_0;

figure;

semilogx(f,10*log10(S_m3/2),'LineWidth',1.2);
hold on;
semilogx(f,10*log10(S_m2/2),'LineWidth',1.2);
semilogx(f,10*log10(S_m1/2),'LineWidth',1.2);
semilogx(f,10*log10(S_0/2),'LineWidth',1.2);
semilogx(f,10*log10(S_total/2),'LineWidth',2);

semilogx(f_pn,L_pn,'o','MarkerSize',8,'LineWidth',1.5);

grid on;

xlabel('Offset frequency [Hz]');
ylabel('SSB Phase Noise L(f) [dBc/Hz]');

legend( ...
    'f^{-3}: Flicker FM', ...
    'f^{-2}: White FM', ...
    'f^{-1}: Flicker PM', ...
    'f^0: White PM', ...
    'Total model', ...
    'ECS datasheet', ...
    'Location','southwest');

title('ECS-TXO53-S3 Phase Noise Components');

function err = phaseNoiseError(q, f, L_target)

    h = 10.^q(:);

    A = [ ...
        1./f.^4, ...
        1./f.^3, ...
        1./f.^2, ...
        1./f, ...
        ones(size(f)) ];

    Sphi = A*h;

    L_model = 10*log10(Sphi/2);

    err = L_model - L_target;
end