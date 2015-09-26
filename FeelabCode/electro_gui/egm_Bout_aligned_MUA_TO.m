function handles = egm_Bout_aligned_MUA_TO(handles)
% electro_gui macro that plots bout aligned MUA

% Tatsuo Okubo
% 2009/07/13

dbase = handles.dbase; % get dbase

MUA_ch = 2; % channel number for MUA
BeforeOffset = round(1.0*dbase.Fs); % [samples]
AfterOffset = round(1.0*dbase.Fs); % [samples]

%% detect bout onset & offset

%filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Max inter-syllable interval (s)','Min Bout duration (s)'},'Bout detection',1,{['1:' num2str(length(dbase.FileLength))],'0.3','0.5'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
MaxInterval = str2num(answer{2}); % maximum  inter-syllable interval (s)
MinBoutDuration = str2num(answer{3}); % minimum bout duration (s)

durs = zeros(0,2);
MUA = cell(length(fls),1);
MUA_stack = [];

%h_waitbar = waitbar(0,'Please wait...','Name','Analyzing files','CreateCancelBtn','setappdata(gcbf,''canceling'',1)' );
clear BoutTimes
for n = 1:length(fls) % array of files to be analyzed
    c = fls(n);
    
%     if dbase.Properties.Values{c}{1} % discard
%         continue
%     end
    
    f = find(handles.SegmentSelection{c} == 1); % segment numbers that are selected
    
%     waitbar(n/length(fls),h_waitbar,[num2str(n), ' / ',num2str(length(fls))]);
%     if getappdata(h_waitbar,'canceling') 
%         display(['Imported files from 1:' num2str(c-1)]);
%         break
%     end
    
    if isempty(f) % no segments
        BoutTimes{c} = [];
        continue
    else
        TempBoutTimes = [handles.SegmentTimes{c}(f(1),1),0]; % bout onset

        for n = 1:length(f)-1
            Interval = (handles.SegmentTimes{c}(f(n+1),1)-handles.SegmentTimes{c}(f(n),2))/handles.fs; % Inter-syllable interval (ms)
            if Interval > MaxInterval
                TempBoutTimes(end,2) = handles.SegmentTimes{c}(f(n),2); % bout offset
                TempBoutTimes(end+1,1) = handles.SegmentTimes{c}(f(n+1),1); % bout onset   
            end
        end
        TempBoutTimes(end,2) = handles.SegmentTimes{c}(f(end),2);
    end
    BoutDuration = (TempBoutTimes(:,2)-TempBoutTimes(:,1))/handles.fs; % 
    BoutDurationNdx = find(BoutDuration>MinBoutDuration); % index of bouts that are longer than MinBoutDuration
    BoutTimes{c} = TempBoutTimes(BoutDurationNdx,:);

    % load sound
    soundName = [dbase.PathName '\' dbase.SoundFiles(c).name]; %%% Note: structure array instead of cell array
    [data fs dateandtime label props] = egl_AA_daq(soundName, 1); %%% load data that are in AA format
    Sound = data;
    
    % load MUA
    fileName = [dbase.PathName '\' dbase.ChannelFiles{MUA_ch}(c).name];
    [data fs dateandtime label props] = egl_AA_daq(fileName, 1); %%% load data that are in AA format
    
     Fs = round(dbase.Fs); % sampling frequency [Hz]      
     New_Fs = Fs/10; % resampling frequency [Hz]
%     Time = ((0:length(data)-1)')./dbase.Fs; 
%     New_Time = resample(Time,New_Fs,Fs);
%     MUA = resample(data,New_Fs,Fs);
    
%     figure
%     s1 = subplot(211)
%     plot(Time,data)
%     s2 = subplot(212)
%     plot(New_Time,MUA)
%     linkaxes([s1,s2],'xy')    
    
    for b=1:size(BoutTimes{c},1) % number of bouts in the file
        StartNdx = BoutTimes{c}(b,2)-BeforeOffset; % start index for plotting
        EndNdx = BoutTimes{c}(b,2)+AfterOffset; % end index for plotting
        if StartNdx < 1 | EndNdx > length(data)
            continue
        end
        temp_sound = Sound(StartNdx:EndNdx);
        temp_MUA = data(StartNdx:EndNdx);
        %Bout{c}{b} = resample(temp_sound,New_Fs,Fs); % don't resample
        %audio
        MUA{c}{b} = resample(temp_MUA,New_Fs,Fs);
        MUA_stack = [MUA_stack, temp_MUA];
        
        figure(121)
        hold on
        s1 = subplot(211);
        %plot(Bout{c}{b});
        displaySpecgramQuick(temp_sound,Fs);
        h1 = line([1 1],ylim);
        set(h1,'color','w','linewidth',3);
        s2 = subplot(212);
        plot((0:length(temp_MUA)-1)/Fs,temp_MUA)
        h2 = line([1 1],ylim);
        set(h2,'color','w','linewidth',3);
        pause(0.5)
        linkaxes([s1,s2],'x');
        hold off
    end
end

%delete(h_waitbar)
display('Bout detecton done')

figure(242)
set(242,'Name','Raster')
MUA_stack = MUA_stack';

imagesc(MUA_stack)
axis xy % chronological order from bottom to up
colorbar

handles.BoutTimes = BoutTimes;
handles.MUA = MUA;