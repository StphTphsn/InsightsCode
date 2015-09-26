function setExportResolution(h, val)
handles = guidata(h);
handles.ExportResolution = val;
guidata(h, handles)