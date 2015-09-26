function setWindowLimits(h, lim)
handles = guidata(h);
handles.P.preStartRef = lim(1);
handles.P.postStopRef = lim(2);
guidata(h, handles);