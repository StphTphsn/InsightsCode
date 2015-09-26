function setExportWidth(h, val)
handles = guidata(h);

ch = get(handles.panel_ExportWidth,'children');
iw = findobj('parent',handles.panel_ExportWidth,'value',1);
iw = 3-find(ch==iw);

ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);

handles.ExportWidth(iw) = val;
guidata(h, handles)