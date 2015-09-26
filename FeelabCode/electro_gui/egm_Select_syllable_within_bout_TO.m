function handles = egm_Select_syllable_within_bout_TO(handles)
% electro_gui macro that plots bout aligned MUA

% Tatsuo Okubo
% 2009/07/13


%% detect bout onset & offset

%filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Max inter-syllable interval (s)','Min Bout duration (s)'},'Bout detection',1,...
    {['1:' num2str(length(handles.FileLength))],'0.3','0.5'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
MaxInterval = str2num(answer{2}); % maximum  inter-syllable interval (s)
MinBoutDuration = str2num(answer{3}); % minimum bout duration (s)

durs = zeros(0,2);
MUA = cell(length(fls),1);
MUA_stack = [];

clear BoutTimes
for m = 1:length(fls) % array of files to be analyzed
    c = fls(m);
    
    f = find(handles.SegmentSelection{c} == 1); % segment numbers that are selected
    
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
    
    for k = 1:size(handles.SegmentTimes{c},1)
        SyllableOnset = handles.SegmentTimes{c}(k,1);
        SyllableOffset = handles.SegmentTimes{c}(k,2);
        if sum(SyllableOnset>=BoutTimes{c}(:,1) & SyllableOffset <= BoutTimes{c}(:,2))==0 % segment is not within bout
            handles.SegmentSelection{c}(k) = 0;
        end
    end    
end
msgbox('Complete!','Process done','modal')