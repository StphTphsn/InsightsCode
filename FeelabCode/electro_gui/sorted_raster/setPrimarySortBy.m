function setPrimarySortBy(h, str)
handles = guidata(h);
val = popupLookup(handles.popup_PrimarySort, str);
if isempty(val)
    error('Invalid Primary Sort parameter: ''%s''', str)
end
set(handles.popup_PrimarySort, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_PrimarySort_Callback', ...
    handles.popup_PrimarySort, [], handles)