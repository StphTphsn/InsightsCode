function setAlignment(h, str)
handles = guidata(h);
val = popupLookup(handles.popup_TriggerAlignment, str);
if isempty(val)
    error('Invalid alignment')
end
set(handles.popup_TriggerAlignment, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_TriggerAlignment_Callback', ...
    handles.popup_TriggerAlignment, [], handles)