function setHistYUnits(h, whichHist, str)
setActiveHistogram(h, whichHist)
handles = guidata(h);
if strcmpi(whichHist, 'psth')
    obj = handles.popup_PSTHUnits;
    cbname = 'popup_PSTHUnits_Callback';
elseif strcmpi(whichHist, 'vert')
    obj = handles.popup_HistUnits;
    cbname = 'popup_HistUnits_Callback';
end
setPopupWithCallback(obj, cbname, str)
