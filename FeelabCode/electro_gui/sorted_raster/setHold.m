function setHold(h, onoff)
handles = guidata(h);
switch onoff
    case 'on'
        set(handles.check_HoldOn, 'Value', 1)
        egm_Sorted_rasters('check_HoldOn_Callback', ...
            handles.check_HoldOn, [], handles)
    case 'off'
        set(handles.check_HoldOn, 'Value', 0)
        egm_Sorted_rasters('check_HoldOn_Callback', ...
            handles.check_HoldOn, [], handles)
    otherwise
        error('Invalid input to setHold(). Second argument must be ''on'' or ''off''')
end
