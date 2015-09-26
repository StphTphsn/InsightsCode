addpath(genpath('chronux_2_10'))
load('sound_0001_001')
s = rec.Data;
fs = rec.Fs;


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
figure('position',[0 0 800 400]);
%h = subplot(2,1,1);
hold on;
% plotting stuff
cmap = jet;
% to make black background, set everything below threshold to threshold, then cmap(1,:) = zeros(1,3); % background = black
colormap(cmap);

surf(t,1:size(Pow,1),Pow,'edgecolor','none'); axis tight;
view(0,90);
ylabel('Frequency (kHz)'); xlabel('Time (s)')

pitch = fun_pitch(s, fs);
figure; hold on;
plot(s)

pitch_under = pitch(mod(1:length(pitch),200)==0);
pitch_under = pitch_under(1+4:end-5);
plot(pitch_under/19.5122,'b','linewidth',3)
surf(1:905,1:410,Pow,'edgecolor','none'); axis tight;

pitch_goodness = zeros(size(pitch_under));
for t = 1:length(pitch_under)
    F0 = pitch_under(t)/19.5122;
    if (F0>100)
        pitch_goodness(t) = 0;
    else
        bin = Pow(:,t)/sum(Pow(:,t));
        tmp =  mean(bin'.*exp(2*pi*1i/F0*((1:length(bin))))/F0);
        pitch_goodness(t) = abs(mean(tmp));
    end
end

[grav,dev] = fun_gravity(Pow);
%%
plot(10000000*smooth(pitch_goodness,10)./dev','k','linewidth',3)


