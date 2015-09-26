function handles = egm_Firing_rate(handles)
% ElectroGui macro
% Displays event rates for the current file

filenum = str2num(get(handles.edit_FileNumber,'string'));

cnt = 1;
str = get(handles.popup_EventList,'string');
fprintf('\nEvent rates (Hz)\n\n');

for c = 1:length(handles.EventTimes)
    for d = 1:size(handles.EventTimes{c},1)
        cnt = cnt+1;
        
        xd = get(handles.xlimbox,'xdata'); % time axis limits
        xd = xd(1:2)*handles.fs;
        
        tm = handles.EventTimes{c}{d,filenum}; % event times
        tm = tm(find(handles.EventSelected{c}{d,filenum}==1)); % only non-deleted events
        tm = find(tm>=xd(1) & tm<=xd(2)); % only events within time limits
        
        rate = length(tm)/(xd(2)-xd(1))*handles.fs;
        
        fprintf([str{cnt} char(9) num2str(rate) '\n']);
    end
end