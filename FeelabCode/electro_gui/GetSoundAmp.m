function [m_amplitude] = GetSoundAmp(a);

%ms will equal the sig of the gaussian filter
ms=5;
fs=40000;
%[wv fs]=wavread(filename);
    %Get amplitude, motherfucker!
    load('bp800_8000');
    wvfilt = filter(bp800_8000, 1, a); %bandpass raw wv file
    wvfilt2=wvfilt.^2;
    wvfilt2=nonzeros(wvfilt2);%i moved the nonzeros action to the raw wv
    %file in get spec
    %wvfilt2=wvfilt2+eps;%to rid of log zero problem
    [gsfilt] = gauss(ms, fs);
    m_amplitude=log(conv(gsfilt,wvfilt2));
