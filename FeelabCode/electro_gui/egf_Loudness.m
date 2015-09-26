function [y label] = egf_Loudness(a,fs, params)
label = 'Loudness'; 
if ischar(a) & strcmp(a,'params')
    y.Names = {'Rectification exponent (e.g. 2 for squared signal)', 'Gaussian half-width sigma (ms)'};
    y.Values = {'2','10'};
    return
end
halfwidth = str2double(params.Values{2})/1000;
wind = round(halfwidth*fs);
amp = smooth(10*log10(a.^str2double(params.Values{1})+eps),wind);
amp = amp-min(amp(wind:length(amp)-wind));
amp(amp<0)=0;
y = amp; 