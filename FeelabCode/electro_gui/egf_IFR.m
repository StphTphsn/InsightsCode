function [IFR label] = egf_IFR(a,fs,params)
% ElectroGui function algorithm
% Inverts data

label = 'Firing rate (Hz)';
if isstr(a) & strcmp(a,'params')
    IFR.Names = {};
    IFR.Values = {};
    return
end

IFR = zeros(size(a));
f = find(a);
for c = 1:length(f)-1
    IFR(f(c):f(c+1)) = fs/(f(c+1)-f(c));
end
