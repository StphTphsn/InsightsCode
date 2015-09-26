function setEventType(h, typ)

handles = guidata(h);
val = popupLookup(handles.popup_EventType, typ);
if isempty(val)
    src = getSelectedString(handles.popup_EventSource);
    error('Invalid Event Type ''%s'' for source ''%s''', typ, src)
end
set(handles.popup_EventType, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_EventType_Callback', ...
    handles.popup_EventType, [], handles)
