function width = getExportWidth(h)
handles = guidata(h);
switch getSelectedString(handles.panel_ExportWidth)
    case 'Absolute'
        width = handles.ExportWidth(1);
    case 'Per time'
        width = handles.ExportWidth(2);
    otherwise
        error('Unrecognized export width units: ''%s''', ...
            getSelectedString(handles.panel_ExportWidth))
end
