function [snd lab] = egf_HanningHighPass(a,fs,params)
% ElectroGui filter
% Code from Aaron Andalman

lab = 'High-pass filtered';
if isstr(a) & strcmp(a,'params')
    snd.Names = {'Cutoff frequency (Hz)','Order'};
    snd.Values = {'750','80'};
    return
end

cutoff = str2num(params.Values{1});
ord = str2num(params.Values{2});

prstFilt3.order = ord; %80 sufficient for 44100Hz of lower
prstFilt3.win = hann(prstFilt3.order+1);
prstFilt3.cutoff = cutoff; %Hz
prstFilt3.fs = 44100;
prstFilt3.hpf = fir1(prstFilt3.order, prstFilt3.cutoff/(prstFilt3.fs/2), 'high', prstFilt3.win);
snd = filtfilt(prstFilt3.hpf, 1, a);