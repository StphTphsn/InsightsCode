function [times label] = ega_Time(a,fs,ev,indx,xlm)
% ElectroGui event feature algorithm
% Returns the time of the event

ev = ev{indx};
times = ev/fs;
label = 'Event time';