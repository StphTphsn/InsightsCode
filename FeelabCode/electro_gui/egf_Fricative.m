function [snd lab] = ege_FricativeDetector(a,fs,params)
% ElectroGui filter

lab = 'Band-pass filtered';
if isstr(a) & strcmp(a,'params')
    snd.Names = {'Lower frequency','Higher frequency','Order'};
    snd.Values = {'400','9000','80'};
    return
end


%below is from da segmenter

min_dur = 7;%str2num(params.Values{1})/1000;
min_stop = 7;%str2num(params.Values{1})/1000;


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
    thnew = min([th mn+2*st]);
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
















fs=40000;thres=-25;ms=5;ord=80;
sig=a;
c = fir1(ord,[800 8000]/(fs/2));
sig = filtfilt(c, 1, sig);
sig=sig.^2;
%sig=nonzeros(sig);%i moved the nonzeros action to the raw wv
%file in get spec
%wvfilt2=wvfilt2+eps;%to rid of log zero problem
sig=smooth(sig,.005*40000);sig=sig';
sig=10*log10(sig);
sig(1)=thres-1;sig(end)=thres-1;
onsetndx = find(sig(1:end-1)<thres & sig(2:end)>=thres);
offsetndx = find(sig(1:end-1)>thres & sig(2:end)<=thres);



b = fir1(ord,[500 19500]/(fs/2));
snd = filtfilt(b, 1, a);
snd=snd.^2;
snd=smooth(snd,.005*fs);snd=snd';
snd=10*log10(snd);
snd(onsetndx:offsetndx)=0;
