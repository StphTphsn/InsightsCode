function [y label] = egf_Gaussian_smooth(a,fs,params)

label = 'Gaussian-smoothed data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Gaussian half-width sigma (ms)','Kernel half-length in stdev'};
    y.Values = {'5','3'};
    return
end


sig = str2num(params.Values{1})/1000;
num = str2num(params.Values{2});

t = -round(sig*num*fs):round(sig*num*fs);
t = t/fs;
k = exp(-t.^2/sig.^2)';

[y c] = xcorr(a,k);
y = y(find(c>=-round(sig*num*fs) & c<length(a)-round(sig*num*fs)));
