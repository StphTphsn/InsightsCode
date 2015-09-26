% set parameters
params.Fs = fs;
params.fpass = [0 8000];
winstep =.005; 
winsize = winstep*10; % some overlap makes it look nice
T = winsize; 
W = 150; % frequency bandwidth product
K = 1; %number of tapers
params.tapers = [T*W K];
movingwin = [winsize winstep]; 
[S,t,f]=mtspecgramc(song,movingwin,params);
Pow = 10*log10(S)';

% plotting stuff
cmap = jet; 
% to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
colormap(cmap);
surf(t, f/1000, Pow,'edgecolor','none'); axis tight; 
view(0,90);
ylabel('Frequency (kHz)'); xlabel('Time (s)')
shg
%imagesc(t, f, 10*log10(S)');shg
%set(gca, 'Ydir', 'normal')
