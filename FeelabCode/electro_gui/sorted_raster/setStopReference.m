function setStopReference(h, str)
handles = guidata(h);
val = popupLookup(handles.popup_StopReference, str);
if isempty(val)
    error('Invalid Stop Reference: ''%s''', str)
end
set(handles.popup_StopReference, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_StopReference_Callback', ...
    handles.popup_StartReference, [], handles)