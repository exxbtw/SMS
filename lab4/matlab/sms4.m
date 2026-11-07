N = 31;
x1 = [0 1 1 0 0]; % x1 = 12 = 01100
y1 = [1 0 0 1 1]; % y1 = x1+7 = 19 = 10011
x2 = [0 1 1 0 1]; % x2 = x1 + 1 = 12 + 1 = 13
y2 = [0 1 1 1 0]; % y2 = y1 - 5 = 19 - 5 = 14

seq1 = zeros(1, N);
for t = 1:N
    out = xor(x1(5), y1(5));
    seq1(t) = out;

    xor_x1 = xor(x1(4), x1(5)); %x == x4 xor x5
    xor_y1 = xor(y1(2), y1(5)); %y == y2 xor y5

    for i = 5:-1:2
        x1(i) = x1(i-1);
        y1(i) = y1(i-1);
    end;

    x1(1) = xor_x1;
    y1(1) = xor_y1;

end;

seq2 = zeros(1, N);
for t = 1:N
    out = xor(x2(5), y2(5));
    seq2(t) = out;

    xor_x2 = xor(x2(4), x2(5)); %x == x4 xor x5
    xor_y2 = xor(y2(2), y2(5)); %y == y2 xor y5

    for i = 5:-1:2
        x2(i) = x2(i-1);
        y2(i) = y2(i-1);
    end;

    x2(1) = xor_x2;
    y2(1) = xor_y2;

end;

disp('Последовательность 1:');
disp(seq1);
disp('Последовательность 2:');
disp(seq2);

%%autocorr
ac = autocorr(seq1, 'NumLags', N-1); % автокорреляция 0-30

disp('Сдвиг | Автокорреляция');
for k = 1:N
    fprintf('%d | %.6f\n', k-1, ac(k));
end

%% Взаимная корреляция seq1 и seq2
b1 = 2*seq1 - 1; % 0 -> -1, 1 -> +1
b2 = 2*seq2 - 1;
[c, lags] = xcorr(b1, b2, 'coeff');
vzaim_corr = c(lags == 0);
fprintf('Взаимная корреляция: %.6f\n', vzaim_corr);

%% графики
b1 = 2*seq1 - 1;
[R, lags] = xcorr(b1, 'coeff'); % автокорреляция по всем лагам -30..30
lags_ac = 0:N-1; % лаги для autocorr

figure;

subplot(2, 1, 1);
stem(lags_ac, ac, 'filled');
grid on;
xlabel('Lag');
ylabel('Автокорреляция');
title('autocorr');

subplot(2, 1, 2);
stem(lags, R, 'filled');
grid on;
xlabel('Lag');
ylabel('Автокорреляция');
title('xcorr');