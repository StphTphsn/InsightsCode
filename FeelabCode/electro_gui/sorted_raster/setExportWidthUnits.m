function setExportWidthUnits(h, str)
handles = guidata(h);
options = findobj('Parent', handles.panel_ExportWidth);
chosen = findobj(options, 'String', str); % find option that matches input str

if length(chosen) ~= 1
    error('Invalid string for Export Width Units: ''%s''', str)
end

set(options, 'Value', 0) % deselect all options
set(chosen, 'Value', 1)