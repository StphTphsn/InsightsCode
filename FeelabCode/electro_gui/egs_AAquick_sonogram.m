function ispower = egs_AAquick_sonogram(ax,wv,fs,params)
% ElectroGui spectrum algorithm
% Aaron Andalman's algorithm that accounts for screen resolution

if isstr(ax) & strcmp(ax,'params')
    ispower.Names = {};
    ispower.Values = {};
    return
end

bck = get(ax,'units');

NFFT = 512;
nCourse = 1;
windowSize = 512;
freqRange = get(ax,'ylim');

%determine size of axis relative to size of the signal,
%use this to adapt the window overlap and downsampling of the signal.
%no need to worry about size of fftwindow, this doesn't effect speed.
set(ax,'Units','pixels');
pixSize = get(ax,'Position');
numPixels = pixSize(3) / nCourse;
numWindows = length(wv) / windowSize;
if(numWindows < numPixels)
    %If we have more pixels than ffts, then increase the overlap
    %of fft windows accordingly.
    ratio = ceil(numPixels/numWindows);
    windowOverlap = min(.999, 1 - (1/ratio));
    windowOverlap = floor(windowOverlap*windowSize);
else
    %If we have more ffts then pixels, then we can do things, we can
    %downsample the signal, or we can skip signal between ffts.
    %Skipping signal mean we may miss bits of song altogether.
    %Decimating throws away high frequency information.
    ratio = floor(numWindows/numPixels);
    %windowOverlap = -1*ratio;
    %windowOverlap = floor(windowOverlap*windowSize);
    windowOverlap = 0;
    wv = decimate(wv, ratio);
    fs = fs / ratio;
end

%Compute the spectrogram
%[S,F,T,P] = spectrogram(sss,windowSize,windowOverlap,NFFT,Fs);
[S,F,t] = specgram(wv, NFFT, fs, windowSize, windowOverlap);

ndx = find((F>=freqRange(1)) & (F<=freqRange(2)));

%The spectrogram
p = 2*log(abs(S(ndx,:))+eps)+20;
f = linspace(freqRange(1),freqRange(2),size(p,1));

set(ax,'units',bck);

xl = xlim;
imagesc(linspace(xl(1),xl(2),size(p,2)),f,p);

ispower = 1;