function [isi label] = ega_Preceding_ISI(a,fs,ev,indx,xlm)
% ElectroGui event feature algorithm
% Returns the event number

ev = ev{indx};
if ~isempty(ev)
    isi = [inf; (ev(2:end)-ev(1:end-1))/fs];
else
    isi = [];
end
label = 'Preceding ISI (ms)';