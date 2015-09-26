function segs = egg_DA_segmenter_old(a,fs,th,params)
% ElectroGui segmenter

if isstr(a) & strcmp(a,'params')
    segs.Names = {'Minimum duration (ms)','Minimum interval (ms)','Buffer (ms)'};
    segs.Values = {'7', '7','0'};
    return
end

min_stop = str2num(params.Values{1})/1000;
min_dur = str2num(params.Values{2})/1000;
buff = str2num(params.Values{3})/1000;

% Find threshold crossing points
f = [];
a = [0; a; 0];
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1;
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1;
a = a(2:end-1);

% Eliminate VERY short syllables
i = find(f(:,2)-f(:,1)>min_dur/2*fs);
f = f(i,:);

% Add buffer
f(:,1) = f(:,1) - buff*fs;
f(find(f(:,1)<1)) = 1;
f(:,2) = f(:,2) + buff*fs;
f(find(f(:,2)>length(a))) = length(a);

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


segs = round(f);