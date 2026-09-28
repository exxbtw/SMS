%1 пункт
disp('1 пункт');
f = 16;
t = 0:0.001:1;
y = 7 * cos(2*pi*f*t + pi/13);

figure;
plot(t, y);
title('Непрерывный сигнал y(t)');
xlabel('t, с');
ylabel('y(t)');
grid on;
disp('4 пункт');

%2-4 пункт
f = 16;
disp(['Макс частота в спектре: ', num2str(f), ' Гц']);

fs = 16 * 2 * 4; %в 4 раза больше
disp(['fs(min) = ', num2str(fs), ' Гц']);

T = 1 / fs;
disp(['T = ', num2str(T)]);

t = 0:T:1-T;

y = 7 * cos(2*pi*f*t+pi/13);

figure;
stem(t, y);
title('y(t)');
xlabel('t')
ylabel('y(t)')
grid on;

disp(['Массив отсчетов сигнала y(t): ', num2str(y)]);
disp(['Число отсчётов: ', num2str(length(y))]);

%5 пункт
disp('5 пункт');

N = length(y);
Y_dft = zeros(1, N);

for k = 0:N-1
    summ = 0;
    for n = 0:N-1
        summ = summ + y(n+1) * exp(-1i*2*pi*k*n/N);
    end
    Y_dft(k+1) = summ;
end

disp(Y_dft)

info = whos('y');
disp(['Тип данных: ', info.class]);
disp(['Объём памяти: ', num2str(info.bytes), ' байт']);

%6 пункт
t_orig = 0:0.001:1;
y_orig = 7 * cos(2*pi*f*t_orig + pi/13);
figure;
plot(t_orig, y_orig, 'b-');
hold on;
plot(t, y, 'r-');
title('Сравнение оригинального и восстановленного сигнала');
xlabel('t, с');
ylabel('y');
legend('Оригинальный сигнал', 'Восстановленный');
grid on;
hold off;

%8 пункт - максимальная частота в спектре 22000Гц, след по котельникову
%частота дискретизации должна быть минимум 44000Гц

%9 пункт
disp('9 пункт')
[y, Fs] = audioread('sms.wav');
disp(['Частота дискретизации (Fs): ', num2str(Fs), ' Гц']);
disp(['Размер массива (y): ', num2str(size(y))]);

%10 пункт
disp('10 пункт');

num_samples = size(y, 1);
disp(['Количество элементов в записи: ', num2str(num_samples)]);

info = audioinfo('sms.wav');
duration = info.Duration;
disp(['Длительность записи: ', num2str(duration), ' с']);

Fs_my = num_samples / duration;
disp(['Вычисленная вручную частота дискретизации:', num2str(Fs_my)]);

%11 пункт
figure;
y1=downsample(y, 10); %прореживаем массив y, оставляя каждый 10й отсчет
zvuk = audioplayer(y1,Fs/10);
play(zvuk); 
plot(y1);


%12 пункт
disp('12 пункт');

fragment_size = 20000;

y_fragment = y(1:fragment_size, 1);
y1_fragment = downsample(y_fragment, 10);

N = length(y_fragment);
Y_dft = zeros(1, N);
tic;
for k = 0:N-1
    summ = 0;
    for n = 0:N-1
        summ = summ + y_fragment(n+1) * exp(-1i*2*pi*k*n/N);
    end
    Y_dft(k+1) = summ;
end
disp(['Время расчёта ДПФ оригинала (', num2str(N), ' отсчётов): ', num2str(toc), ' сек']);

N1 = length(y1_fragment);
Y1_dft = zeros(1, N1);
tic;
for k = 0:N1-1
    summ = 0;
    for n = 0:N1-1
        summ = summ + y1_fragment(n+1) * exp(-1i*2*pi*k*n/N1);
    end
    Y1_dft(k+1) = summ;
end
disp(['Время расчёта ДПФ прореженного (', num2str(N1), ' отсчётов): ', num2str(toc), ' сек']);

half_N = floor(N/2);
half_N1 = floor(N1/2);

freqs = (0:half_N-1) * (Fs/N);
freqs1 = (0:half_N1-1) * ((Fs/10)/N1);

amp = abs(Y_dft(1:half_N)) / N;
amp1 = abs(Y1_dft(1:half_N1)) / N1;

figure;
plot(freqs, amp, 'r');
hold on;
plot(freqs1, amp1, 'b');
title('Амплитудный спектр: оригинал и прореженный сигнал');
xlabel('Частота, Гц');
ylabel('Magnitude');
legend('Оригинал', 'Прореженный');
grid on;
hold off;


%13 пункт
disp('13 пункт');

f = 16;
fs = 16 * 2 * 4;
T = 1/fs;
t = 0:T:1-T;
y = 7 * cos(2*pi*f*t + pi/13);

N = length(y);

Y_dft_orig = zeros(1, N);
for k = 0:N-1
    summ = 0;
    for n = 0:N-1
        summ = summ + y(n+1) * exp(-1i*2*pi*k*n/N);
    end
    Y_dft_orig(k+1) = summ;
end
freqs = (0:N-1) * (fs/N);
amp_orig = abs(Y_dft_orig) / N;

bit_options = [3, 4, 5, 6];

for idx = 1:length(bit_options)
    bits = bit_options(idx);
    max_val = 2^bits - 1;
    
    scaled_sig = (y - min(y)) / (max(y) - min(y)) * max_val;
    quantized_sig = round(scaled_sig);
    quantized_sig = max(0, min(max_val, quantized_sig));
    rec_sig = min(y) + (quantized_sig / max_val) * (max(y) - min(y));
    
    qer = mean(abs(y - rec_sig));
    disp(['Средняя ошибка квантования (', num2str(bits), ' бит): ', num2str(qer)]);
    
    Y_dft_quant = zeros(1, N);
    for k = 0:N-1
        summ = 0;
        for n = 0:N-1
            summ = summ + rec_sig(n+1) * exp(-1i*2*pi*k*n/N);
        end
        Y_dft_quant(k+1) = summ;
    end
    amp_quant = abs(Y_dft_quant) / N;
    
    figure;
    plot(freqs, amp_orig, 'b', 'LineWidth', 2);
    hold on;
    plot(freqs, amp_quant, 'r');
    title(['Спектр: оригинал vs квантованный (', num2str(bits), ' бит)']);
    xlabel('Частота, Гц');
    ylabel('Magnitude');
    legend('Оригинал', ['Квантованный (', num2str(bits), ' бит)']);
    grid on;
    hold off;
end