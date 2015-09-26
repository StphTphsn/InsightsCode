function [amp label] = ega_AP_amplitude(a,fs,ev,indx,xlm)
% ElectroGui event feature algorithm
% Returns the amplitude of an action potential

ev = ev{indx};
prev = [1; ev(1:end-1)];
next = [ev(2:end); length(a)];
amp = zeros(size(ev));
for c = 1:length(ev)
    mn = max([ev(c)-xlm(1) prev(c)]);
    mx = min([ev(c)+xlm(2) next(c)]);
    amp(c) = max(a(mn:mx))-min(a(mn:mx));
end

label = 'Spike amplitude (mV)';

