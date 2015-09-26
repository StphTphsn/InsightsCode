function [y label] = egf_Gaussian_smooth(a,fs,params)

label = 'Smoothed data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Smoothing window (ms)'};
    y.Values = {'1'};
    return
end


num = str2num(params.Values{1});
num = round(num/1000*fs);
y = smooth(a.^2,num);