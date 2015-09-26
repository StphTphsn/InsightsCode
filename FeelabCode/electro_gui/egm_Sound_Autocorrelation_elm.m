function handles = egm_Sound_Autocorrelation_elm(handles)
% ElectroGui macro

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Max lag (s)', 'smoothwin (s)'},'SoundAutocorrelation',1,{'3', '.1'}); % input dialog box
if isempty(answer)
    return
end
maxlag = str2num(answer{1}); % maximum corr. lag to display
smoothwin = str2num(answer{2}); % window to smooth gaussian

fs = handles.fs;
D = handles.sound; 
P = log(conv((D.^2), gausswin(smoothwin*fs), 'same'));%P = handles.amplitude;
figure; 
h = subplot(2,2, 1)
displaySpecgramQuick(D,fs);

title(handles.sound_files(filenum).name)
g = subplot(2,2,3)
plot((1:1:length(D))/fs, P);
ylabel('Loudness (au)'); xlabel('Time (s)');
linkaxes([h g], 'x')
subplot(2,2,[2 4]);
[A,lags] = xcorr(P-mean(P), 'coeff');
plot(lags/fs, A); xlim([-maxlag maxlag]);
ylabel('Correlation'); xlabel('Lag (s)'); shg
set(gcf, 'PaperPosition', [0 0 10 4], 'PaperSize', [10 4])
