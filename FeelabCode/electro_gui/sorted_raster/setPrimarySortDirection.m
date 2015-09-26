function setPrimarySortDirection(h, str)
handles = guidata(h);
switch str
    case 'ascending'
        val = 0;
    case 'descending'
        val = 1;
    otherwise
        error('Primary sort direction must be ''ascending'' or ''descending''')
end
set(handles.check_PrimaryDescending, 'Value', val)
egm_Sorted_rasters('check_PrimaryDescending_Callback', ...
    handles.check_PrimaryDescending, [], handles)