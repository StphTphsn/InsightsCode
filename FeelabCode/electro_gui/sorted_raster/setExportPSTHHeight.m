function setExportPSTHHeight(h, val)
handles = guidata(h);
handles.ExportPSTHHeight = val;
guidata(h, handles)