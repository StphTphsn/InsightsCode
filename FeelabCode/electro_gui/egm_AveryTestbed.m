function handles = egm_AveryTestbed(handles)
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
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
chan1 = handles.chan1(round(ind_time*fs));

figure(2); plot(chan1); shg

figure(1)


%DisplaySpecgramQuick(song,fs); 