function handles = egm_rhythm_LoundnessSpectrogram_elm(handles)
% ElectroGui macro

%GUI asks for options
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'smoothwin (s)', 'fpass (Hz)', 'winsize (s)', 'winstep (s)', 'freq bandwidth (Hz)', '#tapers'},...
    'SoundAutocorrelation',1,...
    {'.1', '[0 10]', '3', '.5', '.4', '2'}); % input dialog box
if isempty(answer)
    return
end

% Get parameters
fs = handles.fs;
params.Fs = fs; 
smoothwin = str2num(answer{1}); % window to smooth gaussian
params.fpass = str2num(answer{2}); 
T = str2num(answer{3}); 
movingwin = [str2num(answer{3}) str2num(answer{4})]; 
W = str2num(answer{5}); 
K = str2num(answer{6}); 
params.tapers = [T*W K];


% Get time limits from sonogram plot
lims = get(handles.axes_Sonogram, 'xlim');
if lims(1) < 1/fs;
    lims(1) = 1/fs;
end
if lims(2)*fs > numel(handles.sound)
    lims(2) = numel(handles.sound)/fs;
end
ind_time = lims(1):1/fs:lims(2);
song = handles.sound(round(ind_time*fs));
time = 0:1/fs:(lims(2)-lims(1));

% Calculate loudness
P = log(1+conv((song.^2), gausswin(smoothwin*fs), 'same'));

% Compute spectrogram (using chronux function)
[S,t,f]=mtspecgramc(P,movingwin,params);
Pow = 10*log10(abs(S))';

% plot
figure; 
h = subplot(2,3,1:2); %spectrogram of loudness
plot_matrix(S,t,f);
ylabel('Frequency (Hz)')
xlabel('');
title('');
colorbar off
box off
axis tight
set(gca, 'xtick', []);
subplot(2,3,3); %time average of spectrogram
plot(mean(Pow,2), f, 'k');
ylabel('Frequency (Hz)');
xlabel('Power (au)');
box off
axis tight
set(gca, 'xtick', [])
g = subplot(2,3,4:5); %loudness 
plot((1:size(song,1))/fs, P, 'k');
xlabel('Time (s)');
ylabel('Loudness (au)');
box off
axis tight
linkaxes([h g], 'x'); %link axes
set(gcf, 'Color', [1 1 1], 'papersize', [6 3], 'paperposition', [0 0 6 3]); %set size, color

% estimate peak frequency, print to command line
M = max(sum(Pow(f>1,:),2));
ind = find(sum(Pow,2)==M);
PeakFreq = f(ind)


