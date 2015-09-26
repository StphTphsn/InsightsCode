function [isi label] = ega_Preceding_logISI(a,fs,ev,indx,xlm)

% ElectroGui event feature algorithm
% Returns the event number

ev = ev{indx};
if ~isempty(ev)
    isi = log10([inf; (ev(2:end)-ev(1:end-1))/fs]);
else
    isi = [];
end
label = 'Preceding log-ISI (sec)';