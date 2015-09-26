function [snd lab] = egf_FIRBandPass1000to4000(a,fs,params)
% ElectroGui filter

lab = 'Band-pass filtered from 1-4kHz';
if isstr(a) & strcmp(a,'params')
    snd.Names = {'Lower frequency','Higher frequency','Order'};
    snd.Values = {'1000','4000','80'};
    return
end

freq1 = 1000;
freq2 = 4000;
ord = 130;

b = fir1(ord,[freq1 freq2]/(fs/2));
snd = filtfilt(b, 1, a);