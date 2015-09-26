function [y label] = egf_highpass_500(a,fs,params)

label = 'Highpassed Data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Filter order','Cutoff fequency (Hz)'};
    y.Values = {'80','500'};
    return
end

order = str2num(params.Values{1});
cutoff = str2num(params.Values{2});
highPassFilt = fir1(order, cutoff/(fs/2), 'high');
y = filtfilt(highPassFilt, 1, a);