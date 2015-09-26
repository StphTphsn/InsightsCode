function setHistCount(h, whichHist, str)
setActiveHistogram(h, whichHist)
handles = guidata(h);
if strcmpi(whichHist, 'psth')
    obj = handles.popup_PSTHCount;
    cbname = 'popup_PSTHCount_Callback';
elseif strcmpi(whichHist, 'vert')
    obj = handles.popup_HistCount;
    cbname = 'popup_HistCount_Callback';
end
setPopupWithCallback(obj, cbname, str)