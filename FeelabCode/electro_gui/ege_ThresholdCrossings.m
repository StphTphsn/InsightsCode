function [events labels] = ege_ThresholdCrossings(data,fs,thres,params)
% ElectroGui event detector
% Finds threshold crossings

labels = {'Positive slope','Negative slope'};
if isstr(data) & strcmp(data,'params')
    events.Names = {'Baseline value'};
    events.Values = {'0'};
    return
end

data(1) = str2num(params.Values{1}); % set the first and last data to zero to avoid (# of onset) ~= (# of offset)
data(end) = str2num(params.Values{1});

events{1} = (find(data(1:end-1)<thres & data(2:end)>=thres)); % positive crossing
events{2} = (find(data(1:end-1)>thres & data(2:end)<=thres)); % negative crossing