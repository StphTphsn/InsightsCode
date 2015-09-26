function setTriggerType(h, typ)

handles = guidata(h);
val = popupLookup(handles.popup_TriggerType, typ);
if isempty(val)
    src = getPopupSelectedString(handles.popup_TriggerSource);
    error('Invalid Trigger Type ''%s'' for source ''%s''', typ, src)
end
set(handles.popup_TriggerType, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_TriggerType_Callback', ...
    handles.popup_TriggerType, [], handles)
