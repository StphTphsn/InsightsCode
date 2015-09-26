function [snd lab] = egf_FIRBandPass_1_4_Khz(a,fs,params)
% ElectroGui filter

lab = 'Band-pass filtered';
if isstr(a) & strcmp(a,'params')
    snd.Names = {'Lower frequency','Higher frequency','Order'};
    snd.Values = {'1000','4000','80'};
    return
end

freq1 = str2num(params.Values{1});
freq2 = str2num(params.Values{2});
ord = str2num(params.Values{3});

b = fir1(ord,[freq1 freq2]/(fs/2));
snd = filtfilt(b, 1, a);