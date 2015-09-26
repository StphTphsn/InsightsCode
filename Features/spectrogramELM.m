function [S,Time,F] = spectrogramELM(song,fs,specDT, makePlot)

if nargin < 4; makePlot = 0; end
if nargin < 3; specDT = .005; end

if specDT*fs ~= round(specDT*fs)
    error('Must choose winstep with integer number of bins')
end

winstep =specDT; 
winsize = .02; % some overlap makes it look nice
Time = (winstep:winstep:(length(song)/fs))-winstep; 

% parameters for chronux spectrogram
params.Fs = fs;
params.fpass = [500 6000];
T = winsize; 
W = 150; % frequency bandwidth product
K = 1; %number of tapers
params.tapers = [T*W K];
movingwin = [winsize winstep]; 

% zeropad song by 1 windowsize so we can keep the spectrogram the right length
zpSong = [zeros(round(winsize*fs),1); song(:); zeros(round(winsize*fs),1)]; 

% calculate spectrogram using chronux function
[Szp,tzp,F]=mtspecgramc(zpSong,movingwin,params);

% recover part of spectrogram corresponding to original signal
tind_start = find(abs(tzp-winsize)<=winstep/2); 
tind = tind_start + Time/winstep;
tind = round(tind/10/winstep)*10*winstep; % to get rid of rounding from weird machine-precision errors
S = Szp(tind,:)'; 


% plotting stuff
if makePlot
    cmap = jet; 
    % to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
    colormap(cmap);
    Plot = 10*log10(S);
    surf(Time, F/1000, Plot,'edgecolor','none'); axis tight; 
    view(0,90);
    ylabel('Frequency (kHz)'); xlabel('Time (s)')
    shg
end