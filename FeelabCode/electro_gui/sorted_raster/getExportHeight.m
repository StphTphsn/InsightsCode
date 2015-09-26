function height = getExportHeight(h)
handles = guidata(h);
ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);
height = handles.ExportHeight(ih);