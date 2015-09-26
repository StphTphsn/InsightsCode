function str = getPrimarySortDirection(h)
handles = guidata(h);
if get(handles.check_PrimaryDescending, 'Value') == 1
    str = 'descending';
else
    str = 'ascending';
end
