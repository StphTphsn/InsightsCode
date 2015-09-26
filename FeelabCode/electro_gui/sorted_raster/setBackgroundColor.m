function setBackgroundColor(h, colorr)
handles = guidata(h);
handles.BackgroundColor = colorr;
set(handles.axes_PSTH,'color',handles.BackgroundColor);
set(handles.axes_Hist,'color',handles.BackgroundColor);
set(handles.axes_Raster,'color',handles.BackgroundColor);
guidata(h, handles);