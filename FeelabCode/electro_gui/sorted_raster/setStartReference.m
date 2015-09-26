function setStartReference(h, str)
handles = guidata(h);
val = popupLookup(handles.popup_StartReference, str);
if isempty(val)
    error('Invalid Start Reference: ''%s''', str)
end
set(handles.popup_StartReference, 'Value', val)

% Explicitly invoke callback because it does not happen when you change the
% value of a GUI control with set()
egm_Sorted_rasters('popup_StartReference_Callback', ...
    handles.popup_StartReference, [], handles)