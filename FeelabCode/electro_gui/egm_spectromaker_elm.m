function handles = egm_spectromaker_elm(handles)
shg;
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
FS = 8; % labels
FS_axes = 8; % axis labels
%h = subplot(2,1,1)
fs = handles.fs;
lims = get(handles.axes_Sonogram, 'xlim');
if lims(1) < 1/fs;
    lims(1) = 1/fs;
end
if lims(2)*fs > numel(handles.sound)
    lims(2) = numel(handles.sound)/fs
end
ind_time = lims(1):1/fs:lims(2);
song = handles.sound(round(ind_time*fs));
%units = handles.chan1(round(ind_time*fs));
time = 0:1/fs:(lims(2)-lims(1));
SegmentTimes = handles.dbase.SegmentTimes{filenum}/handles.fs-lims(1);
SelectedSyls = handles.dbase.SegmentIsSelected{filenum};
SegmentNames = handles.dbase.SegmentTitles{filenum};

for si = 1:size(SegmentTimes,1)
    if length(SegmentNames{si})==0
        SegmentNames{si} = '';
    end
    if SegmentTimes(si,1) < 0 | SegmentTimes(si,2)>diff(lims)
        SelectedSyls(si) = 0;
    end
end

%% using chronux. It is prettier this way, but the figures are huge.
% Thres = -95; % threshold for being in black background
%
% params.Fs = fs;
% params.fpass = [0 8000];
% winsize = .015;
% winstep = winsize/10;
% T = winsize;
% W = 150; % frequency bandwidth
% K = 1; %number of tapers
% params.tapers = [T*W K];
% movingwin = [winsize winstep];
% [S,t,f]=mtspecgramc(song,movingwin,params);
% Pow = 10*log10(S)';
% Pow(Pow<Thres) = Thres;
% cmap = jet;
% cmap(1,:) = zeros(1,3); % background = black
% colormap(cmap);
% surf(t, f/1000, Pow,'edgecolor','none'); axis tight;
% view(0,90);
% ylabel('Frequency (kHz)')
% %imagesc(t, f, 10*log10(S)');shg
% %set(gca, 'Ydir', 'normal')
%% using displayspecgramquick
%set(gca, 'xtick', [])
%displaySpecgramQuick(song,fs);
temp = get(handles.axes_Sonogram, 'Children');
cdata = get(temp, 'Cdata');
fdata = get(temp, 'ydata');
tdata = get(temp, 'xdata'); tdata = time;
fig = figure;
%h = subplot(2,1,1);
%tmp = suptitle([handles.path_name ' #' num2str(filenum)])
%set(tmp, 'fontsize', FS);
%Thres = -16.2;
cdata(cdata<handles.SonogramClim(1)) = handles.SonogramClim(1);
cdata(cdata>handles.SonogramClim(2)) = handles.SonogramClim(2);
imagesc(cdata, 'xdata', tdata, 'ydata', fdata/1000); set(gca, 'ydir', 'normal', 'ytick', 2:2:6)
colormap jet
%surf(tdata, fdata, cdata, 'edgecolor', 'none'); axis tight; view(0,90)
%ylabel('Frequency (kHz)','fontsize',FS)
%xlabel('Time (s)','fontsize',FS)
%set(gca, 'xtick', [], 'xticklabel', '');
%set(gca, 'ytick', [], 'ticklabel', '');

cmap = jet;
cmap(1,:) = zeros(1,3); % background = black
colormap(cmap);


%% adding patches for syllables
Syls = unique(SegmentNames);
sColors = [.5 .5 .5; hsv(length(Syls)-1)];
hold on
for si = 1:size(SegmentTimes,1)
    sylID = find(strncmp(SegmentNames{si}, Syls,2));
    if SelectedSyls(si)
        patch(SegmentTimes(si,[1 2 2 1 1]), 8+.5*[0 0 1 1 0], sColors(sylID,:), 'Edgecolor','none')
        text(mean(SegmentTimes(si,:)), 8.5, SegmentNames{si}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','fontsize',FS_axes)
    end
end
set(gca, 'color', 'none')
ylim([min(fdata/1000) 8.5])
box off
set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
set(gca,'fontsize',FS_axes)


%% using MATLAB spectrogram function

% NFFT = 1025;
% windowSize = round(512/25);
% NoiseFloor = -90;
% [S,F,T, P] = spectrogram(song, windowSize, windowSize/2, NFFT, fs);
% Pow = 10*log10(P);
% Pow(Pow<NoiseFloor) = NoiseFloor;
% surf(T,F,Pow,'edgecolor','none'); axis tight;
% cmap = jet;
% cmap(1,:) = zeros(1,3);
% colormap(cmap)
% view(0,90);
% ylabel('Frequency (Hz)');
% ylim([0 8000])
% set(gca, 'xtick', [])
%%
% subplot(3,1,2)
% plot((1:size(handles.sound))/handles.fs, handles.amplitude)
% g = subplot(2,1,2)
% set(gca, 'box', 'off', 'ColorOrder', [0 0 0], 'NextPlot', 'replacechildren')
% plot(time,units, 'linewidth', 1.5); %mini_max_plot(time, units, 'ax', g)
% xlabel('Time(s)','fontsize',FS);
% ylabel(get(get(handles.axes_Channel1, 'ylabel'), 'string'),'fontsize',FS);
% axis tight
% set(gca, 'ytick', [0 .2], 'yticklabel', {'0', '0.2'})
%
% box off
%
% set(gca,'color','none','tickdir','out','ticklength',[0.025 0.025])
% set(gca,'fontsize',FS_axes)
%
% linkaxes([h g],'x')
% %xlim([lims(1) lims(2)])
% %% in order to make no space between plots
% ShrinkBy = 4;
% p = get(h, 'pos');
% q = get(g, 'pos');
% m = mean([p(2) q(2)+q(4)])
% gap = p(2) - (q(2)+q(4));
% p(2) = m + gap/(2*ShrinkBy);
% q(4) = m-q(2)-  gap/(2*ShrinkBy);
% set(h, 'pos', p)
% set(g, 'pos', q)
%%

set(gcf, 'Color', [1 1 1], 'PaperSize', [4 1.5], 'PaperPosition', [0 0 4 1.5])%, 'PaperPositionMode', 'manual', 'InvertHardCopy', 'off');
%print fig -dmeta -r300