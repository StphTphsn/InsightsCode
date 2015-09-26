function elem = getRasterElement(h, num)
handles = guidata(h);

html = get(handles.list_Plot, 'String');
elem.Name = html{num}(26:end-14);

elem.Include = handles.PlotInclude(num);

elem.Continuous = handles.PlotContinuous(num);

elem.Color = handles.PlotColor(num,:);

% select this element
set(handles.list_Plot, 'Value', num)
egm_Sorted_rasters('list_Plot_Callback', handles.list_Plot, [], handles)
if strcmp(get(handles.push_PlotWidth,'string'),'Width')
    elem.Param = handles.PlotLineWidth(num);
else
    elem.Param = handles.PlotAlpha(num);
end