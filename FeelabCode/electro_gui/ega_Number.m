function [num label] = ega_Number(a,fs,ev,indx,xlm)
% ElectroGui event feature algorithm
% Returns the event number

ev = ev{indx};
num = 1:length(ev);
label = 'Event number';