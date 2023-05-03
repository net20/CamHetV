%% Make some noise
tVals = -250e-6:1e-10:250e-6;
%TimeData = randn(size(tVals)); % Gaussian white noise
% TimeData = rand(size(tVals)) - 0.5; % uniform white noise
% TimeData = pinknoise(size(tVals)); % pink noise
winWidth = 1024;
topHatFunc = ones(1, winWidth);
gaussFunc = gausswin(winWidth, 1.9143*sqrt(2*pi));
[Sth, F, T, Pth] = spectrogram(TimeData, topHatFunc, 0, winWidth, 1e10);
[Sg, ~, ~, Pg] = spectrogram(TimeData, gaussFunc, 0, winWidth, 1e10);
T = T - tVals(1);

%% Spectrogram
DispP = IndexSpect(Pth, 256);
figure(1); clf();
image('CData', DispP, 'CDataMapping', 'direct', 'XData', [T(1) T(end)], 'YData', [F(1) F(end)]);
sRth = std(real(Sth), 1, 2);
sIth = std(imag(Sth), 1, 2);
sRg = std(real(Sg), 1, 2);
sIg = std(imag(Sg), 1, 2);
figure(2); clf();
plot(F, sRth, F, sIth, F, sRg, F, sIg);
figure(4); clf();
sigmaActTh = std([real(Sth), imag(Sth)], 1, 2);
sigmaAlreadyTh = sqrt(2/pi) * mean(abs(Sth), 2);
sigmaActG = std([real(Sg), imag(Sg)], 1, 2);
sigmaAlreadyG = sqrt(2/pi) * mean(abs(Sg), 2);
plot(F, sigmaActTh, F, sigmaAlreadyTh, F, sigmaActG, F, sigmaAlreadyG);
% so I have decent agreement between my Maxwell-Boltzmann and my
% just-look-at-the-distribution approaches, except that when f = 0 or f =
% fs/2 the imaginary component is always zero (and the peak broadening from
% the Gabor window distributes some of that to low-frequency components),
% and Maxwell-Boltzmann isn't applicable.
% Gaussian window has a noise s.d. of 3.43, top-hat 7.98

%% What is the window function doing to my noise s.d.?
% Maybe Parseval's theorem?  Power factor should be as sum of squares of
% window value.  Then square root it because we're working with amplitude
% not power.
PwTh = sum(topHatFunc.^2);
PwG = sum(gaussFunc.^2);
wFact = sqrt(PwTh / PwG);
figure(5); clf();
plot(F, sigmaActTh, F, sigmaActG * wFact);
% Okay, good agreement.  Does it hold for other window widths?  Seems to.

%% Why is pink noise so very white?
% because it doesn't work for very large numbers of points, I think?
% Probably a numerical precision problem

%% Try generating our own noise
% Generate a vector of complex values with the right distribution at each
% frequency, then inverse FFT.
% noise SD seems to go as root window length?
% so since I want to cover my original time domain
targetLength = length(tVals);
% and I want to get a noise SD of 22.6 with a 1024-element window
noiseSD = 22.6 * sqrt(targetLength / 1024);
% generate appropriately noisy data that are the fft of a real signal i.e.
% Hermitian, imaginary parts of the DC and (if an even number of points)
% Nyquist points are zero.  Also constrain that the real part of the DC
% point is zero because our data should have a mean of zero.
isOdd = mod(targetLength, 2);
halfLength = (targetLength - isOdd) / 2;
fRs = randn(halfLength, 1) * noiseSD;
fIs = randn(halfLength, 1) * noiseSD;
fIs(end) = fIs(end) * isOdd;
fR = zeros(targetLength, 1);
fI = zeros(targetLength, 1);
fR(2:halfLength + 1) = fRs;
fI(2:halfLength + 1) = fIs;
fR(halfLength + 2:end) = fRs((end + isOdd - 1):-1:1);
fI(halfLength+2:end) = -fIs((end + isOdd - 1):-1:1);
TimeData = ifft(complex(fR, fI));

%% Coloured noise
% No-one said the noise SD had to be scalar and that's how we apply
% frequency-dependent noise.
targetLength = length(tVals);
noiseSD = 22.6 * sqrt(targetLength / 1024);
isOdd = mod(targetLength, 2);
halfLength = (targetLength - isOdd) / 2;
%noiseScale = polyval([-7.96/(halfLength^2), 7.96/halfLength, 0.01], 1:halfLength)';
noiseScale = ones(halfLength, 1);
noiseScale(floor(halfLength/2):end) = 0.5;
fRs = randn(halfLength, 1) * noiseSD .* noiseScale;
fIs = randn(halfLength, 1) * noiseSD .* noiseScale;
fIs(end) = fIs(end) * isOdd;
fR = zeros(targetLength, 1);
fI = zeros(targetLength, 1);
fR(2:halfLength + 1) = fRs;
fI(2:halfLength + 1) = fIs;
fR(halfLength + 2:end) = fRs((end + isOdd - 1):-1:1);
fI(halfLength+2:end) = -fIs((end + isOdd - 1):-1:1);
TimeData = ifft(complex(fR, fI));