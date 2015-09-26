function setHistShow(h, psthOrVert, val)

% Push 'PSTH' or 'Vert.' button 
setActiveHistogram(h, psthOrVert)

% Check 'Show' box
handles = guidata(h);
set(handles.check_HistShow, 'Value', val)
egm_Sorted_rasters('check_HistShow_Callback', ...
    handles.check_HistShow, [], handles)
