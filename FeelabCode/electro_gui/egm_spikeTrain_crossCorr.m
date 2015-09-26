
% code based on: egm_spiketrain_autocorrelation

function handles = egm_spikeTrain_crossCorr(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number

% get the list of available spike trains from the current file:
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


% user dialog to select which data to correlate:
chkSelect = 1 ; 
while chkSelect
    [selection,OK] = listdlg('PromptString','Please select up to two spike trains to correlate (selection of one channel will calculate autocorrelation','ListString',str, 'ListSize',[300 300] ) ;
    if ~OK % if user pushes the 'cancel'button'
        return
    end
    % check how many lines were chosen:
    if length(selection)<3 % make sure only one or two spike trains were selected     
        chkSelect = 0 ;
    end
end

% user dialog to select analysis parameters:
answer = inputdlg({'Files','smoothing window (ms)', 'max lag (ms)'},'correlation parameters',1,{[num2str(filenum)],'10', '2000'}); % input dialog box

if isempty(answer)% if user pushes the 'cancel'button'
    return
end

if length(selection)==1
    selection(2) = selection(1) ;
    ylab = 'Autocorrelation (normalized)';
else
    ylab = 'Cross-correlation (normalized)';
end

% code based on : egm_spiketrain_autocorrelation
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
smoothing_window = str2num(answer{2})/1000; % array of histogram bin edges (ms)
maxlag = str2num(answer{3}); % cross-correlation lag
fs = handles.fs; % sampling rate of the data
figure; hold all
xlabel('lag (s)');
ylabel(ylab) ;
idx = 1;
for ff = fls % array of files
    spiketimes1 = handles.EventTimes{ind(selection(1),1)}{ind(selection(1),2),ff};
    isSelect = handles.EventSelected{ind(selection(1),1)}{ind(selection(1),2),ff};
    spiketimes1 = spiketimes1(logical(isSelect)) ; % remove unselected events
    spiketimes2 =handles.EventTimes{ind(selection(2),1)}{ind(selection(2),2),ff};
    isSelect =handles.EventSelected{ind(selection(2),1)}{ind(selection(2),2),ff};
    spiketimes2 = spiketimes2(logical(isSelect)) ;
    spiketrain1 = zeros(1, handles.FileLength(ff)); % length of ceurrent file
    spiketrain2=spiketrain1;
    spiketrain1(spiketimes1) = 1;
    spiketrain2(spiketimes2) = 1;
    filter = normpdf(-6*smoothing_window:1/fs:6*smoothing_window, 0, smoothing_window);
    smooth_spiketimes1 = conv(spiketrain1, filter);
    smooth_spiketimes2 = conv(spiketrain2, filter);

    [ACF(idx,:), lags] = xcorr(smooth_spiketimes1,smooth_spiketimes2,  ceil(maxlag/1000*fs), 'coeff');
%     plot(lags/fs, ACF(idx,:)); shg; pause(1)
%     nfactor(idx) = mean(ACF(idx, find(lags/fs>smoothing_window|lags/fs<-smoothing_window)));
%     L{idx} = num2str(ff);
    idx = idx+1;
end

All = mean(ACF,1); 
%plot(lags/fs, ACF);
plot(lags/fs, All, 'k', 'linewidth', 2)
%     legend(L, 'mean')


xlim([-maxlag/1000 maxlag/1000])
shg % show graph window

%%%%%%% end code from : egm_spiketrain_autocorrelation