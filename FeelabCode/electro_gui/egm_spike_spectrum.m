function handles = spike_spectrum(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files

% user dialog to select data (added by Maya):
str=[] ; 
ind = ones(1,2) ; 
for c = 1:length(handles.EventTimes)
    [param labels] = eval(['ege_' handles.EventDetectors{c} '(''params'')']);
    for d = 1:length(labels)
        str{end+1} = [handles.EventSources{c} ' - ' handles.EventFunctions{c} ' - ' labels{d}];
        ind(length(str),1) = c;
        ind(length(str),2) = d;
    end
end

[iSelect,OK] = listdlg('PromptString','Please select spike source','ListString',str, 'ListSize',[300 300],'SelectionMode','single' ) ;

if ~OK % if user pushes the 'cancel'button' 
    return
end

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'File','[winsize winstep]', '[minfreq maxfreq]'},'in seconds...',1,{[num2str(filenum)],'[1.5 .1]', '[2 25]'}); % input dialog box
if isempty(answer)
    return
end
fFiles = eval(answer{1}); % array of files to be analyzed, convert from string to number

movingwin = str2num(answer{2});
fpass = str2num(answer{3});
fs = handles.fs;
figure; hold all

%smoothing_window = .020; 
% spiketimes1 =handles.EventTimes{EventInd}{1, file};% in samples
spiketimes1 = handles.EventTimes{ind(iSelect,1)}{ind(iSelect,2),fFiles}; % % in samples % User-selected spike source % maya
ss =handles.EventSelected{ind(iSelect,1)}{ind(iSelect,2),fFiles}; % check for unselected events % Maya
spiketimes1 = spiketimes1(logical(ss)) ;  % remove unselected events % maya

spiketimes = spiketimes1/fs; % convert to spike time in sec
spiketrain = zeros(1, numel(handles.sound));
spiketrain(spiketimes1) = 1; % a binary vector of spikes (ones and zeros)
%filter = normpdf(-6*smoothing_window:1/fs:6*smoothing_window, 0, smoothing_window);
%smooth_spiketimes = conv(spiketrain, filter);
%sound(spiketrain, fs);
time = (1:numel(handles.sound))/fs;% in sec
%params.tapers = [.1 6];
params.Fs = fs; 
params.fpass = fpass;
%params.pad = -1;
data(1).times = spiketimes;
%winsize = 1;
%winstep = .1;
%movingwin = [winsize winstep];
[S,t,f] = mtspecgrampt(data, movingwin, params); % Multi-taper time-frequency spectrum - point process times
%[S1,t1,f1] = mtspecgramc(smooth_spiketimes, movingwin, params);
h = subplot(2,1,1);
imagesc((S'), 'Xdata', t, 'Ydata', f)
set(gca, 'ydir', 'normal')
colormap hot
ylabel('frequency (Hz)')
xlabel('time (s)')
% f = subplot(3,1,2)
% imagesc(S1, 'Xdata', t1, 'Ydata', f1)
% colormap hot
% ylabel('frequency (Hz)')
g = subplot(2,1,2);
plot(time,spiketrain, 'k')
linkaxes([h g], 'x')
subplot(g)
xlabel('time (s)')
ylim([-1 2]); 
figure; 
[S,f] = mtspectrumpt(data, params);
plot(f,S)
xlabel('frequency (Hz)')
axis tight



