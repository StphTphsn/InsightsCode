function [events labels] = ege_Spikes(data,fs,thres,params)
% ElectroGui event detector
% Finds spikes in data

labels = {'Spikes'};
if isstr(data) & strcmp(data,'params')
    events.Names = {'Refractory period (ms)'};
    events.Values = {'1'};
    return
end
    
rp = str2num(params.Values{1})/1000;

if thres >= 0
    events{1} = find(data(1:end-1)<thres & data(2:end)>=thres);
else
    events{1} = find(data(1:end-1)>thres & data(2:end)<=thres);
end

f = find(events{1}(2:end)-events{1}(1:end-1)<rp*fs);
events{1}(f+1) = [];