function setExcludePartialWindows(h, val)
handles = guidata(h);
set(handles.check_ExcludeIncomplete, 'Value', val)
egm_Sorted_rasters('check_ExcludeIncomplete_Callback', ...
    handles.check_ExcludeIncomplete, [], handles)