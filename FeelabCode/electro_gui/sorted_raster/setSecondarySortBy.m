function setSecondarySortBy(h, str)
handles = guidata(h);
val = popupLookup(handles.popup_SecondarySort, str);
if isempty(val)
    error('Invalid Secondary Sort parameter: ''%s''', str)
end
set(handles.popup_SecondarySort, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_SecondarySort_Callback', ...
    handles.popup_SecondarySort, [], handles)