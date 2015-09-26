function [events labels] = ege_Fricatives(a,fs,thres,params)
% ElectroGui function algorithm
% Inverts data

labels = {'Onsets','Offsets'};
if isstr(a) & strcmp(a,'params')
    events.Names = {'Threshold','Max distance'};
    events.Values = {'0','0.2'};
    return
end

if isempty(a)
    events = {[],[]};
    return
end

maxdist = str2num(params.Values{2})*fs;

th = str2num(params.Values{1});
[segs th] = DA_segmenter_full(a,fs,th);

gapon = [1; segs(:,2)];
gapoff = [segs(:,1); length(a)];

bpfilt = fir1(200,[5000 19500]/(fs/2));
a = filtfilt(bpfilt, 1, a);% band-pass between 5 and 19.5 kHz
wind = round(0.005*fs); % smooth with a 5ms window
a = 10*(log10(smooth(a.^2,wind))); % convert to decibels
a = a-prctile(a,5); % subtract baseline

breaths = cell(length(gapon),1);
for g = 1:length(gapon)
    gapdata = a(gapon(g):gapoff(g));
    gapdata([1 end]) = 0;
    f1 = find(gapdata(1:end-1)<thres & gapdata(2:end)>=thres);
    f2 = find(gapdata(1:end-1)>=thres & gapdata(2:end)<thres);
    
    f = find(f1>maxdist & f2<(gapoff(g)-gapon(g))-maxdist);
    f1(f) = [];
    f2(f) = [];
    
    breaths{g} = [f1 f2]+gapon(g);
    if isempty(f1)
        breaths{g} = zeros(0,2);
    end
end

minbreath = 0.007*fs;
for c = 1:length(breaths)
    f = find(breaths{c}(2:end,1)-breaths{c}(1:end-1,2)<minbreath);
    for d = length(f):-1:1
        breaths{c}(f(d),2) = breaths{c}(f(d)+1,2);
        breaths{c}(f(d)+1,:) = [];
    end
    f = find(breaths{c}(:,2)-breaths{c}(:,1)<minbreath);
    breaths{c}(f,:) = [];
end

breaths = cell2mat(breaths);

events{1} = breaths(:,1);
events{2} = breaths(:,2);


function [segs th] = DA_segmenter_full(a,fs,th)

params.Values = {'1000','4000','100'};
snd = egf_FIRBandPass(a,fs,params);
smooth_window = 0.0025;
wind = round(smooth_window*fs);
amp = smooth(10*log10(snd.^2+eps),wind);

% CHANGED HERE FOR DIFFERENT AMPLITUDE OFFSETS!!!!
% amp = amp-prctile(amp(wind:length(amp)-wind),5);
amp = amp-min(amp(wind:length(amp)-wind));

amp(find(amp<0))=0;
if th==0
    th = eg_AutoThreshold(amp);
end


params.Values = {'7', '7','7','0'};
params.IsSplit = 0;

segs = DA_segmenter(amp,fs,th,params);


function threshold = eg_AutoThreshold(amp)

if mean(amp)<0
    amp = -amp;
    isneg=1;
else
    isneg=0;
end
if range(amp)==0
    threshold = inf;
    return;
end

try
    % Code from Aaron Andalman
    [noiseEst, soundEst, noiseStd, soundStd] = eg_estimateTwoMeans(amp);
    if(noiseEst>soundEst)
        disc = max(amp)+eps;
    else
        %Compute the optimal classifier between the two gaussians...
        p(1) = 1/(2*soundStd^2+eps) - 1/(2*noiseStd^2);
        p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2+eps);
        p(3) = (soundEst^2)/(2*soundStd^2+eps) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd+eps);
        disc = roots(p);
        disc = disc(find(disc>noiseEst & disc<soundEst));
        if(length(disc)==0)
            disc = max(amp)+eps;
        else
            disc = disc(1);
            disc = soundEst - 0.5 * (soundEst - disc);
        end
    end
    threshold = disc;

    if ~isreal(threshold)
        threshold = max(amp)*1.1;
    end
catch
    threshold = max(amp)*1.1;
end

if isneg
    threshold = -threshold;
end



% by Aaron Andalman
function [uNoise, uSound, sdNoise, sdSound] = eg_estimateTwoMeans(audioLogPow)

%Run EM algorithm on mixture of two gaussian model:

%set initial conditions
l = length(audioLogPow);
len = 1/l;
m = sort(audioLogPow);
uNoise = median(m(fix(1:length(m)/2)));
uSound = median(m(fix(length(m)/2:length(m))));
sdNoise = 5;
sdSound = 20;

%compute estimated log likelihood given these initial conditions...
prob = zeros(2,l);
prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
[estProb, class] = max(prob);
warning off
logEstLike = sum(log(estProb)) * len;
warning on
logOldEstLike = -Inf;

%maximize using Estimation Maximization
while(abs(logEstLike-logOldEstLike) > .005)
    logOldEstLike = logEstLike;

    %Which samples are noise and which are sound.
    nndx = find(class==1);
    sndx = find(class==2);

    %Maximize based on this classification.
    uNoise = mean(audioLogPow(nndx));
    sdNoise = std(audioLogPow(nndx));
    if ~isempty(sndx)
        uSound = mean(audioLogPow(sndx));
        sdSound = std(audioLogPow(sndx));
    else
        uSound = max(audioLogPow);
        sdSound = 0;
    end

    %Given new parameters, recompute log likelihood.
    prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2+eps)))./(sdNoise+eps);
    prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2+eps)))./(sdSound+eps)+eps;
    [estProb, class] = max(prob);
    logEstLike = sum(log(estProb+eps)) * len;
end


function snd = egf_FIRBandPass(a,fs,params)
% ElectroGui filter

freq1 = str2num(params.Values{1});
freq2 = str2num(params.Values{2});
ord = str2num(params.Values{3});

b = fir1(ord,[freq1 freq2]/(fs/2));
snd = filtfilt(b, 1, a);


function segs = DA_segmenter(a,fs,th,params)
% ElectroGui segmenter

if isstr(a) & strcmp(a,'params')
    segs.Names = {'Minimum duration (ms)','Minimum interval (ms)','Mininum duration for splitting (ms)','Minimum interval for splitting (ms)'};
    segs.Values = {'7', '7','7','0'};
    return
end

min_dur = str2num(params.Values{1})/1000;
min_stop = str2num(params.Values{2})/1000;

if params.IsSplit == 1
    min_dur = str2num(params.Values{3})/1000;
    min_stop = str2num(params.Values{4})/1000;
end

if th < 0
    a = -a;
    th = -th;
end
th = th-min(a);
a = a-min(a);

% Find threshold crossing points
f = [];
a = [0; a; 0];
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1;
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1;
a = a(2:end-1);

% Eliminate VERY short syllables
i = find(f(:,2)-f(:,1)>min_dur/2*fs);
f = f(i,:);

% Extend syllables to a lower threshold
if params.IsSplit == 0
    warning off
    mn = mean(a(find(a<th)));
    st = std(a(find(a<th)));
    warning on
    thnew = min([th mn+1*st]);
    for c=1:size(f,1)
        f(c,1)=max([1; find(a(1:f(c,1)-1)<thnew)]);
        f(c,2)=min([length(a); f(c,2)+find(a(f(c,2)+1:end)<th/2)]);
    end
end

% Eliminate short syllables
i = find(f(:,2)-f(:,1)>min_dur*fs);
f = f(i,:);

if isempty(f)
    segs = zeros(0,2);
    return
end

% Eliminate short intervals
if size(f,1)>1
    i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
    f = [f([1; i(1:end-1)+1],1) f(i,2)];
end

segs = f;