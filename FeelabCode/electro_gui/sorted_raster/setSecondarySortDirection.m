function setSecondarySortDirection(h, str)
handles = guidata(h);
switch str
    case 'ascending'
        val = 0;
    case 'descending'
        val = 1;
    otherwise
        error('Secondary sort direction must be ''ascending'' or ''descending''')
end
set(handles.check_SecondaryDescending, 'Value', val)
egm_Sorted_rasters('check_SecondaryDescending_Callback', ...
    handles.check_SecondaryDescending, [], handles)