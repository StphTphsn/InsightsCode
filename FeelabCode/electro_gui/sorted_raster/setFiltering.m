function setFiltering(h, filterName, filterLims)
handles = guidata(h);
val = popupLookup(handles.list_Filter, filterName);
if isempty(val)
    error('Invalid filter name: %s', filterName)
end
set(handles.list_Filter, 'Value', val)
egm_Sorted_rasters('list_Filter_Callback', handles.list_Filter, [], handles)
handles = guidata(h); % updated handles. possibly changed by callback above
set(handles.edit_FilterFrom, 'String', num2str(filterLims(1)))
egm_Sorted_rasters('edit_FilterFrom_Callback', ...
    handles.edit_FilterFrom, [], handles)
handles = guidata(h); % updated handles. possibly changed by callback above
set(handles.edit_FilterTo, 'String', num2str(filterLims(2)))
egm_Sorted_rasters('edit_FilterTo_Callback', ...
    handles.edit_FilterTo, [], handles)