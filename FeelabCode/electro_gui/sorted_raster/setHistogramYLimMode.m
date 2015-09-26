function setHistogramYLimMode(h, str)
handles = guidata(h);

switch lower(str)
    case 'auto'
        set(handles.radio_PSTHAuto,   'Value', 1)
        set(handles.radio_PSTHManual, 'Value', 0)
    case 'manual'
        set(handles.radio_PSTHAuto,   'Value', 0)
        set(handles.radio_PSTHManual, 'Value', 1)
    otherwise
        error('Mode must be ''auto'' or ''manual''')
end