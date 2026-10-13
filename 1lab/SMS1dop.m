%dop
[y, Fs] = audioread('sms.wav');
fragment_size = 45000;
y_voice = y(1:fragment_size, 1).';
L = length(y_voice);

N = round(0.050 * Fs);
N = N + mod(N, 2);
step = N/2;
half = N/2;
m = 2; 

w = 0.5 - 0.5*cos(2*pi*(0:N-1)/N);
yp = [y_voice zeros(1, 2*N)];
out = zeros(1, L + 2*N);

for s = 0:step:L-1
    frame = yp(s+1:s+N) .* w;

    Y = fft(frame);

    Y_new = zeros(1, N);
    for k = 0:half
        kn = round(m*k);
        if kn <= half
            Y_new(kn+1) = Y_new(kn+1) + Y(k+1) * exp(1i*2*pi*(kn-k)*s/N);
        end
    end
    for k = 1:half-1
        Y_new(N-k+1) = conj(Y_new(k+1));
    end

    x_new = real(ifft(Y_new));

    out(s+1:s+N) = out(s+1:s+N) + x_new;
end

out = out(1:L);

disp(['Длительность: было ', num2str(L/Fs), ' с, стало ', num2str(length(out)/Fs), ' с']);

z1 = audioplayer(y_voice, Fs); playblocking(z1);
z2 = audioplayer(out, Fs); playblocking(z2);