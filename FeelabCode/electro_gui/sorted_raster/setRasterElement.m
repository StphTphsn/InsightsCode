function setRasterElement(h, elem)

% Select the raster element in the list
handles = guidata(h);
% In this list box, all of the entries have HTML tags to control the text
% color. Extract the text from the HTML and compare it to elem.Name
html = get(handles.list_Plot, 'String');
str = cell(size(html));
for ii = 1:length(html)
    str{ii} = html{ii}(26:end-14);
end
val = find(strcmp(elem.Name, str));
if isempty(val)
    error('Invalid raster element name: ''%s''', elem.Name)
end
set(handles.list_Plot, 'Value', val)
egm_Sorted_rasters('list_Plot_Callback', handles.list_Plot, [], handles)

% Include this object in the raster if elem.Include is true
handles = guidata(h);
if elem.Include == true
    set(handles.check_PlotInclude, 'Value', 1)
    egm_Sorted_rasters('check_PlotInclude_Callback', ...
        handles.check_PlotInclude, [], handles)
else
    set(handles.check_PlotInclude, 'Value', 0)
    egm_Sorted_rasters('check_PlotInclude_Callback', ...
        handles.check_PlotInclude, [], handles)
end

% Check the 'continuous' box if elem.Continuous is true
if elem.Continuous == true
    handles = guidata(h);
    set(handles.check_PlotContinuous, 'Value', 1)
    egm_Sorted_rasters('check_PlotContinuous_Callback', ...
        handles.check_PlotContinuous, [], handles)
end

% Set color
handles = guidata(h);
egm_Sorted_rasters('push_PlotColor_Callback', ...
    handles.push_PlotColor, [], handles, elem.Color)

% Set parameter (width or transparency)
handles = guidata(h);
egm_Sorted_rasters('push_PlotWidth_Callback', ...
    handles.push_PlotWidth, [], handles, elem.Param)
