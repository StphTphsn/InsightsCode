
function handles = egm_Sort_syllables_TO(handles)
% electro_gui macro that sorts the prelabeled syllables into stim and
% masked trials

% Tatsuo Okubo
% 2009/12/02

%% detect bout onset & offset
for m = 1:length(handles.FileLength) % all the file
    Size = size(handles.SegmentSelection{m});
    handles.SegmentSelection{m} = zeros(Size); % deselect all the syllables
end
%filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Syllable label','Event number'},...
    'Syllable sorting',1,{['1:' num2str(length(handles.FileLength))],'a','1'}); % input dialog box
EventNum = eval(answer{3});
if isempty(answer)
    return
end

fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
Label = answer{2};
Ch = eval(answer{3}); % channel number that contains the event

% TO DO; pull down to choose events


for m = 1:length(fls) % array of files to be analyzed
    c = fls(m);
    
    List = find(strcmp(handles.SegmentTitles{c},Label)); % find syllables that has the specified label
    
    for i = 1:length(List) % for all the syllables within a file
        Seg = List(i);
        Start = handles.SegmentTimes{c}(Seg,1); % syllable onset
        End = handles.SegmentTimes{c}(Seg,2); % syllable offset
        Event = cell2mat(handles.EventTimes{EventNum}(1,c)); %%%% get all events in the file
        IsEvent = sum((Start < Event) & (Event < End)); % did event happen within syllable onset and offset?
        if IsEvent~=0
            handles.SegmentSelection{c}(Seg) = 1; % select the syllable
            handles.Properties.Values{c} = {[1]}; % select the syllable
        end
    end 
end

% TO DO, save the results in a different file
msgbox('Complete!','Process done','modal')