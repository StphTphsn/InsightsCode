function [y label] = egf_lowpass_500(a,fs,params)

label = 'Lowpassed Data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Filter order','Cutoff fequency (Hz)'};
    y.Values = {'80','500'};
    return
end

order = str2num(params.Values{1});
cutoff = str2num(params.Values{2});
lowPassFilt = fir1(order, cutoff/(fs/2));
y = filtfilt(lowPassFilt, 1, a);