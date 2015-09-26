function segs = egg_DA_segmenter(a,fs,th,params)
% ElectroGui segmenter

if isstr(a) & strcmp(a,'params')
    segs.Names = {'Minimum duration (ms)','Minimum interval (ms)','Mininum duration for splitting (ms)','Minimum interval for splitting (ms)'};
    segs.Values = {'7', '7','7','0'};
    return
end

%%% Added by Maya
if ~isfield(params,'IsSplit')
   params = setfield (params,'IsSplit',0) ; 
end

if params.IsSplit == 1
    min_dur = str2num(params.Values{3})/1000; % minimum duration for splitting (ms)
    min_stop = str2num(params.Values{4})/1000; % minimum interval for splitting (ms)
else
    min_dur = str2num(params.Values{1})/1000; % minimum duration (ms)
    min_stop = str2num(params.Values{2})/1000; % minimum interval (ms)
end

if th < 0
    a = -a;
    th = -th;
end
th = th-min(a);
a = a-min(a);

% Find threshold crossing points
f = [];
a = [0; a; 0]; % add 0 in the beginning in the end to avoid miss
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1; % positive threshold crossing
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1; % negative threshold crossing
a = a(2:end-1); % remove the extra zeros added

% Eliminate VERY short syllables
i = find(f(:,2)-f(:,1)>min_dur/2*fs); % 'VERY short' = min_dur / 2
f = f(i,:);

% Extend syllables to a lower threshold
if params.IsSplit == 0
    warning off
    mn = mean(a(find(a<th)));
    st = std(a(find(a<th)));
    warning on
    thnew = min([th mn+2*st]); % mean + 2*std
    for c=1:size(f,1)
        f(c,1)=max([1; find(a(1:f(c,1)-1)<thnew)]);
        f(c,2)=min([length(a); f(c,2)+find(a(f(c,2)+1:end)<thnew)]); %Apparent bug fixed, now consistent with Aronov & Fee 2011
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