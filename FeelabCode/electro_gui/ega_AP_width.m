function [width label] = ega_AP_width(a,fs,ev,indx,xlm)
% ElectroGui event feature algorithm
% Returns the amplitude of an action potential

ev = ev{indx};
prev = [1; ev(1:end-1)];
next = [ev(2:end); length(a)];
width = zeros(size(ev));
for c = 1:length(ev)
    mn = max([ev(c)-xlm(1) prev(c)]);
    mx = min([ev(c)+xlm(2) next(c)]);
    [dm i] = min(a(mn:mx));
    [dm j] = max(a(mn:mx));
    width(c) = max([abs(j(1)-i(end)) abs(j(end)-i(1))])/fs*1000;
end

label = 'Spike width (ms)';