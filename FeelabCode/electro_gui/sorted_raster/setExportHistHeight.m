function setExportHistHeight(h, val)
handles = guidata(h);
handles.ExportHistHeight = val;
guidata(h, handles)