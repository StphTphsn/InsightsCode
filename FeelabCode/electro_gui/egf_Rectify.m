function [y label] = egf_Rectify(a,fs,params)

label = 'Rectified data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Power (e.g. 1 for absolute value, 2 for squared value)'};
    y.Values = {'2'};
    return
end


num = str2num(params.Values{1});
y = abs(a).^num;