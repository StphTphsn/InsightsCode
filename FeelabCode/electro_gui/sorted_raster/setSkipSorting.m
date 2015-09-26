function setSkipSorting(h, tf)
handles = guidata(h);
set(handles.check_SkipSorting, 'Value', tf)
egm_Sorted_rasters('check_SkipSorting_Callback', ...
    handles.check_SkipSorting, [], handles)