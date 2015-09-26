function handles = egm_FB_analysis_TO(handles)
% ElectroGui macro
% Find out the onset and offset of FB during bout

% Run after events are detected in MUA
% threshold channel

% Tatsuo Okubo
% 2009/06/22

dbase = handles.dbase; % get the dbase

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Max inter-syllable interval (s)','Min Bout duration (s)'},'Bout detection',1,{['1:' num2str(filenum)],'0.3','0.5'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
MaxInterval = str2num(answer{2}); % maximum  inter-syllable interval (s)
MinBoutDuration = str2num(answer{3}); % minimum bout duration (s)

durs = zeros(0,2);

clear BoutTimes
for c = fls % array of files to be analyzed
    f = find(handles.SegmentSelection{c} == 1); % segment numbers that are selected
    
    if isempty(f) % no segments
        BoutTimes{c} = [];        
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
end

display('Bout detecton done')

handles.BoutTimes = BoutTimes;

FB_ratio_stack = [];
FB_count_stack = [];

for c = fls % array of files to be analyzed
    Date = dbase.Times(c);
    BoutTimes = handles.BoutTimes{c};
        
    FB_onset = dbase.EventTimes{1}(1,c); % onsets
    FB_onset = FB_onset{1}; % converting cell array to array
    FB_offset = dbase.EventTimes{1}(2,c); % offsets
    FB_offset = FB_offset{1}; % offset
    FB_duration = FB_offset - FB_onset;
    
    for n = 1:size(BoutTimes,1) % number of bouts in the file
        Bout_onset = BoutTimes(n,1);
        Bout_offset = BoutTimes(n,2);
        Bout_duration = Bout_offset - Bout_onset;
        
        FB_Index = find((Bout_onset <=  FB_onset) & (FB_offset <= Bout_offset)); % Only consider FBs during the bout
        FB_ratio_temp(n,1) = sum(FB_duration(FB_Index))/Bout_duration; % ratio of (FB_duration)/(Bout_duration)
        FB_count_temp(n,1) = size(FB_Index,1)/(Bout_duration./handles.fs); % probablity of having a FB event during 1 s of singing
        FB_ratio_stack = [FB_ratio_stack; [Date,FB_ratio_temp(n,1)]];
        FB_count_stack = [FB_count_stack; [Date,FB_count_temp(n,1)]];
    end
    
    FB_ratio{c} = FB_ratio_temp;
    FB_count{c} = FB_count_temp;
end

answer2 = inputdlg({'Year','Month','Date','Hour','Minute'},'Start of FB',1,{'2009','','','',''});

if isempty(answer2)
    error('No input!')
end

Year = eval(answer2{1});
Month = eval(answer2{2});
Date = eval(answer2{3});
Hour = eval(answer2{4});
Minute = eval(answer2{5});
Second = 0;

FB_start = datenum([Year, Month, Date, Hour, Minute, Second]);

figure(200)
%[haxes,hline1,hline2] = plotyy(FB_ratio_stack(:,1),FB_ratio_stack(:,2),FB_ratio_stack(:,1),FB_count_stack(:,1))
subplot(211)
hold on
plot(FB_ratio_stack(:,1),FB_ratio_stack(:,2),'go')
h1 = line([FB_start,FB_start],ylim);
set(h1,'linewidth',3,'color','k');
hold off
datetick('x',13); % convert x-axis to timescale
xlim([min(FB_ratio_stack(:,1)),max(FB_ratio_stack(:,1))])
set(gca,'fontsize',12)
ylabel('FB ratio','fontsize',14)
title('FB ratio','fontsize',20)
box on

subplot(212)
hold on
plot(FB_count_stack(:,1),FB_count_stack(:,2),'ro')
h2 = line([FB_start,FB_start],ylim);
set(h2,'linewidth',3,'color','k');
datetick('x',13); % convert x-axis to timescale
xlim([min(FB_ratio_stack(:,1)),max(FB_ratio_stack(:,1))])
set(gca,'fontsize',12)
ylabel('FB count','fontsize',14)
title('FB count','fontsize',20)
box on