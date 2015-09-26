function setExcludePartialEvents(h, val)
handles = guidata(h);
set(handles.check_ExcludePartialEvents, 'Value', val)
egm_Sorted_rasters('check_ExcludePartialEvents_Callback', ...
    handles.check_ExcludePartialEvents, [], handles)