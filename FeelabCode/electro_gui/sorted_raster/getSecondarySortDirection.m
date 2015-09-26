function str = getSecondarySortDirection(h)
handles = guidata(h);
if get(handles.check_SecondaryDescending, 'Value') == 1
    str = 'descending';
else
    str = 'ascending';
end
