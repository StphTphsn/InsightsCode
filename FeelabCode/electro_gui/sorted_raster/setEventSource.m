function setEventSource(h, src)
handles = guidata(h);
val = getSourceValue(src, handles);
set(handles.popup_EventSource, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_EventSource_Callback', ...
    handles.popup_EventSource, [], handles)