function [y label] = egf_filtered_multiunit_plot(a,fs,params)

label = 'Multiunit activity 500Hz+';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Rectification exponent (e.g. 2 for squared signal)','Filter order','Cutoff fequency (Hz)'};
    y.Values = {'2','80','500'};
    return
end

rec = str2num(params.Values{1});
order = str2num(params.Values{2});
cutoff = str2num(params.Values{3});
highPassFilt = fir1(order, cutoff/(fs/2), 'high');
highBand = filtfilt(highPassFilt, 1, a);
y = abs(highBand.^rec);