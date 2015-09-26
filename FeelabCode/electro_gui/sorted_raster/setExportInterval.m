function setExportInterval(h, val)
handles = guidata(h);
handles.ExportInterval = val;
guidata(h, handles)