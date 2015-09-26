function handles = egm_rhythm_Phasegram_elm(handles)
% ElectroGui macro

%GUI asks for options
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'smoothwin (s)', 'winsize (s)', 'winstep (s)', '#Phases', 'frequency to test (Hz)'},...
    'SoundAutocorrelation',1,...
    {'.1', '2', '.2', '25', '3'}); % input dialog box
if isempty(answer)
    return
end

% Get parameters
fs = handles.fs;
smoothwin = str2num(answer{1}); % window to smooth gaussian
winsize = str2num(answer{2}); 
winstep = str2num(answer{3}); 
nPhases = str2num(answer{4}); 
PeakFreq = str2num(answer{5}); 

% Get raw sound data with correct time limits from sonogram plot
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

% Calculate Phasegram: dot product with sine waves at different phases
totalTime = numel(P)/fs; 
winstarti = 1:winstep*fs:totalTime*fs;
winendi = winstarti+winsize*fs; 
winstarti = winstarti(winendi<=totalTime*fs);
winendi = winendi(winendi<=totalTime*fs);
nChunks = numel(winendi);
Coh = zeros(nChunks, nPhases);
for phasei = 1:nPhases
    Sine = sin(2*pi*PeakFreq/fs*(1:totalTime*fs)+ phasei*2*pi/nPhases);
    for chunki = 1:nChunks
        tempP = P(winstarti(chunki):winendi(chunki))';
        tempSine = Sine(winstarti(chunki):winendi(chunki));
        Coh(chunki, phasei) = sum(tempP.*tempSine); 
    end
end

% Plot
figure; 
m = subplot(2,1,1); % Phasegram
surf((winstarti+winendi)/fs/2, (1:nPhases)*2*pi/nPhases, Coh','edgecolor','none'); 
view(0,90);
ylabel('Phase (radians)');
set(gca, 'ytick', [0 pi 2*pi], 'yticklabel', {'0', 'pi', '2pi'});
xlabel('');
title('');
box off
axis tight
set(gca, 'xtick', []);
box off
axis tight
k = subplot(2,1,2); % Loudness 
plot((1:size(song,1))/fs, P, 'k');
xlabel('Time (s)');
ylabel('Loudness (au)');
box off
axis tight
set(gca, 'xtick', []);
linkaxes([k m], 'x') % Link axes
set(gcf, 'Color', [1 1 1], 'papersize', [9 3], 'paperposition', [0 0 9 3]) % set size