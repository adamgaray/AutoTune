function Y = autotune(X, fs, w)
% X: Input signal
% fs: Sampling frequency
% w: window length

% Compress to mono
X = mean(X, 2);

% Generate window
w = 2^nextpow2(w);
hamWindow = window(@hamming, w);

Y = zeros(length(X), 1);
numWindows = floor(length(X) / w);

for i = 0 : numWindows - 1

    % Get window
    n = i*w + 1;
    currentWindow = X(n : n + length(hamWindow) - 1) .* hamWindow;

    % Perform fft
    Xfft = abs(fft(currentWindow, fs));

    % Find most prominent frequency
    [~, peak] = max(Xfft);
    
    % Find the nearest note in tuning A = 440 Hz
    freq = (peak-1)*fs / w; 
    nearest = 2^(round(12*log2(freq/440))/12) * 440;

    if (nearest == 0 || freq == 0)
       ratio = 1.0; 
    else
       ratio = nearest/freq;
    end
    
    % Shift pitch
    if (ratio ~= 1.0)
        Ywindow = pitchShift(currentWindow, w/16, w/64, ratio);
    else
        Ywindow = currentWindow;
    end
    
    Y(n : n + w - 1) = Ywindow(1:w);
    
end
 
plot(X)
figure
plot(Y)