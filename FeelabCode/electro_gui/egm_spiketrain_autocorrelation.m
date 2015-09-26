function handles = spiketrain_autocorrelation(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','smoothing window (ms)', 'max lag (ms)'},'ISI distribution',1,{[num2str(filenum)],'10', '2000'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
smoothing_window = str2num(answer{2})/1000; % array of histogram bin edges (ms)
maxlag = str2num(answer{3});
fs = handles.fs;
figure; hold all
xlabel('lag (s)');
ylabel('autocorr (normalized)'); 
idx = 1; 
for c = fls % array of files
    spiketimes = handles.EventTimes{1}{1,c}; % change to use input to select which event
    spiketrain = zeros(1, numel(handles.sound)); % change to use multiple files
    spiketrain(spiketimes) = 1;
    filter = normpdf(-6*smoothing_window:1/fs:6*smoothing_window, 0, smoothing_window);
    smooth_spiketimes = conv(spiketrain, filter);
    [ACF(idx,:), lags] = xcorr(smooth_spiketimes,  ceil(maxlag/1000*fs), 'coeff');
    plot(lags/fs, ACF(idx,:)); shg; pause(1)
    nfactor(idx) = mean(ACF(idx, find(lags/fs>smoothing_window|lags/fs<-smoothing_window)));
    L{idx} = num2str(c);
    idx = idx+1;
end


if size(ACF,1)>1
    All = mean(ACF,1);
    %plot(lags/fs, ACF); 
    plot(lags/fs, All, 'k', 'linewidth', 3)
    legend(L, 'mean')
end


xlim([-maxlag/1000 maxlag/1000])
shg