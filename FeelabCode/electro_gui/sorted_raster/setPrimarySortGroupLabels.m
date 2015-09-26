function setPrimarySortGroupLabels(h, val)
handles = guidata(h);
set(handles.check_GroupLabels, 'Value', val)
egm_Sorted_rasters('check_GroupLabels_Callback', ...
    handles.check_GroupLabels, [], handles)