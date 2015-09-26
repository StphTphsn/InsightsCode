function [events labels] = ege_Pulse_trains(data,fs,thres,params)
% ElectroGui event detector
% Finds spikes in data

labels = {'On','Off'};
if isstr(data) & strcmp(data,'params')
    events.Names = {'Pulse interval threshold (ms)'};
    events.Values = {'3'};
    return
end

pint = str2num(params.Values{1})/1000*fs;

if thres >= 0
    evon = find(data(1:end-1)<thres & data(2:end)>=thres); % point where data goes from below to above threshold
    evoff = find(data(1:end-1)>=thres & data(2:end)<thres); % point where data goes from above to below threshold
else
    evon = find(data(1:end-1)>thres & data(2:end)<=thres);
    evoff = find(data(1:end-1)<=thres & data(2:end)>thres);
end

if isempty(evon) || isempty(evoff)
    events{1} = evon;
    events{2} = evoff;
    return
end

if evoff(1) < evon(1) % If the first thing that happens is an OFF event
    evoff = evoff(2:end); % discard it
end

if evon(end) > evoff(end) % if the last thing that happens is an ON event
    evon = evon(1:end-1); % discard it
end

assert(all(evoff > evon))
intrvl = evon(2:end) - evoff(1:end-1);
keep = find(intrvl > pint);

events{1} = evon([1; keep+1]);
events{2} = evoff([keep; length(evoff)]);




