% % test YIN
% clear all;
% 
% %yin 'clarinet.au'
% load('sound_0001_001')
% s = rec.Data;
% fs = rec.Fs;
% 
% 
% R = yin(s,fs);


%%

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
[S,t,f]=mtspecgramc(s,movingwin,params);
Pow = 10*log10(S)';

%%

figure('position',[0 0 800 800]); 
g = subplot(2,1,1);
hold on;

F0 = interp1(R.hop*(0:length(R.f0)-1),R.f0,(0:length(s)-1));
ap = interp1(R.hop*(0:length(R.f0)-1),smooth(R.ap,30),(0:length(s)-1));
pwr = interp1(fs*winstep*(0:size(Pow,2)-1),sum(Pow),(0:length(s)-1));

pwr2 = (pwr-min(pwr))/10000;


ts = 1/fs*(0:length(s)-1);
%plot(ts,s);
plot(ts,F0,'r');
plot(ts,1./ap/10,'g');
plot(ts,pwr2,'k');
plot(ts,pwr2.*1./ap/10,'b')

xlim([ts(1) ts(end)])


h = subplot(2,1,2);
hold on;
% plotting stuff
cmap = jet; 
% to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
colormap(cmap);
surf(t, f/1000, Pow,'edgecolor','none'); axis tight; 
view(0,90);
ylabel('Frequency (kHz)'); xlabel('Time (s)')
linkaxes([h g],'x');
shg
%imagesc(t, f, 10*log10(S)');shg
%set(gca, 'Ydir', 'normal')




