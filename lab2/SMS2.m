%% Входные данные
TxPowerBS = 46; %дБм
TxPowerUE = 24; %дБм

AntGainBS = 21; %дБи, усиление антенны BS
PenetrationM = 15; %дБ, запас сквозь стены
IM = 1; %дБ, запас на интерференцию
MIMO_antennas = 2;

f_GHz = 1.8; %ГГц
BW_UL = 10e6; %Гц
BW_DL = 20e6; %Гц

NF_BS = 2.4; %дБ
NF_UE = 6; %дБ
SINR_DL = 2; %дБ
SINR_UL = 4; %дБ

sectors = 3; %секторов на 1 BS
area_total = 100;
area_mall = 4;


%1пункт (mapl_ul)
FeederLoss = 2; %дБ
MIMOGain = 3; %дБ

TN_UL = -174 + 10*log10(BW_UL);
RxSens_BS = NF_BS + TN_UL + SINR_UL;

MAPL_UL = TxPowerUE - FeederLoss + AntGainBS + MIMOGain - IM - PenetrationM - RxSens_BS;

disp('1 пункт(MAPL_UL)');
disp(['Thermal_Noise_UL: ', num2str(TN_UL), ' дБм']);
disp(['RxSens_BS: ', num2str(RxSens_BS), ' дБм']);
disp(['MAPL_UL: ', num2str(MAPL_UL), ' дБ']);

%2 пункт (mapl_dl)
TN_DL = -174 + 10*log10(BW_DL);
RxSens_UE = NF_UE + TN_DL + SINR_DL;

MAPL_DL = TxPowerBS - FeederLoss + AntGainBS + MIMOGain - IM - PenetrationM - RxSens_UE;

disp(' ');
disp('2 пункт(MAPL_DL)');
disp(['Thermal_Noise_DL: ', num2str(TN_DL), ' дБм']);
disp(['RxSens_UE: ', num2str(RxSens_UE), ' дБм']);
disp(['MAPL_DL: ', num2str(MAPL_DL), ' дБ']);

%3 пункт (зависим величины вход потерь радиосигнала от расст между приемником и передатчиком)

d_m = logspace(1, 4, 400); %10м-10км
d_km  = d_m / 1000;
f_MHz = f_GHz * 1000;

%uminlos
PL_uminlos = 26 * log10(f_GHz) + 22.7 + 36.7 * log10(d_m);
figure;
hold on;
grid on;
plot(d_m, PL_uminlos);
xlabel('Расстояние, м');
ylabel('Потери сигнала, дБ');

%okumura-hata
A = 46.3;
B = 33.9;
hBS = 30; %30-200м
hms = 2; %1-10м
a = 3.2 * (log10(11.75*hms))^2 - 4.97; %U
Lclutter = 0; %U
s_far  = 44.9 - 6.55*log10(f_MHz); % d >= 1 км
s_near = (47.88 + 13.9*log10(f_MHz) - 13.9*log10(hBS)) / log10(50); % d < 1 км
s = s_far*(d_km >= 1) + s_near*(d_km < 1);

PL_okumura = A + B * log10(f_MHz) - 13.82 * log10(hBS) - a + s .* log10(d_km) + Lclutter;
plot(d_m, PL_okumura);



%walfish-ikegami
dh = 15; %м - ср h зданий
w = 20; %м - средняя ширина улиц
b = 40; %м - среднее расстояние между зданиями
phi = 45; %градусов, угол между направлением сигнала и улицей

L0 = 32.44 + 20*log10(f_MHz) + 20*log10(d_km); %потери в своб пространстве

L_gradus = 2.5 + 0.075*phi;
L2 = -16.9 - 10*log10(w) + 10*log10(f_MHz) + 20*log10(dh - hms) + L_gradus; %от крыш зданий

L11 = -18 * log10(1 + hBS - dh); %hbs > dh (30 > 15)
ka = 54; %hBS > dh
kd = 18; %hBS > dh
kf = -4 + 0.7 * ((f_MHz/925)-1);
L1 = L11 + ka + kd*log10(d_km) + kf*log10(f_MHz) - 9*log10(b); %переотражения от стен зданий
PL_wi = L0 + max(L1 + L2, 0);
plot(d_m, PL_wi);
yline(MAPL_UL, 'r--', 'MAPL\_UL', 'LineWidth', 1.2);
yline(MAPL_DL, 'g--', 'MAPL\_DL', 'LineWidth', 1.2);
legend('UMiNLOS', 'Okumura Hata', 'Walfish-Ikegami', 'Location', 'southeast');
title('Потери сигнала по моделям, f = 1.8 ГГц');

%4 пункт (радиус BS)
%R макросоты okumura
i_UL = find(PL_okumura >= MAPL_UL, 1);
i_DL = find(PL_okumura >= MAPL_DL, 1);

R_UL_macro = interp1(PL_okumura(i_UL-1:i_UL), d_km(i_UL-1:i_UL), MAPL_UL);

R_DL_macro = interp1(PL_okumura(i_DL-1:i_DL), d_km(i_DL-1:i_DL), MAPL_DL);

R_macro = min(R_UL_macro, R_DL_macro);

S_macro = 1.95 * R_macro^2;

N_macro = ceil(area_total / S_macro);

disp(' ');
disp('Макросоты (Okumuru Hata)');
disp(['Радиус UL: ', num2str(R_UL_macro), ' км']);
disp(['Радиус DL: ', num2str(R_DL_macro), ' км']);
disp(['Рабочий радиус: ', num2str(R_macro), ' км']);
disp(['Площадь одной БС: ', num2str(S_macro), ' км^2']);
disp(['Количество БС для 100 км^2: ', num2str(N_macro)]);

%R микросот uminlos
i_UL = find(PL_uminlos >= MAPL_UL, 1);
i_DL = find(PL_uminlos >= MAPL_DL, 1);

R_UL_micro = interp1(PL_uminlos(i_UL-1:i_UL), d_km(i_UL-1:i_UL), MAPL_UL);

R_DL_micro = interp1(PL_uminlos(i_DL-1:i_DL), d_km(i_DL-1:i_DL), MAPL_DL);

R_micro = min(R_UL_micro, R_DL_micro);

S_micro = 1.95 * R_micro^2;

N_micro = ceil(area_mall / S_micro);

disp(' ');
disp('Микросоты (UMiNLOS)');
disp(['Радиус UL: ', num2str(R_UL_micro * 1000), ' м']);
disp(['Радиус DL: ', num2str(R_DL_micro * 1000), ' м']);
disp(['Рабочий радиус: ', num2str(R_micro * 1000), ' м']);
disp(['Площадь одной БС: ', num2str(S_micro), ' км^2']);
disp(['Количество БС для 4 км^2: ', num2str(N_micro)]);