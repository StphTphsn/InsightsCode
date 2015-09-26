function [y label] = egf_Multiunit_plot(a,fs,params)

label = 'Gaussian-smoothed data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Rectification exponent (e.g. 2 for squared signal)','Gaussian half-width sigma (ms)','Kernel half-length in stdev'};
    y.Values = {'2','5','3'};
    return
end

rec = str2num(params.Values{1});
sig = str2num(params.Values{2})/1000;
num = str2num(params.Values{3});

a = abs(a.^rec);

t = -round(sig*num*fs):round(sig*num*fs);
t = t/fs;
k = exp(-t.^2/sig.^2)';

num_edges = ceil(length(a)/0.5e6)+1;
edges = round(linspace(0,length(a),num_edges));
y = [];

for j = 1:length(edges)-1
    [y_part c] = xcorr(a(edges(j)+1:edges(j+1)),k);
    y_part = y_part(find(c>=-round(sig*num*fs) & c<edges(j+1)-edges(j)-round(sig*num*fs)));
    y(end+1:end+length(y_part)) = y_part;
end