function answers = getHistOptionDefaults(h, whichHist)
handles = guidata(h);
if strcmpi(whichHist, 'psth')
    val = get(handles.popup_PSTHUnits,'value');
    if strcmp(get(handles.popup_EventType,'enable'),'off')
        val = val + 3;
    end
    answers{1} = num2str(handles.PSTHBinSize);
    answers{2} = num2str(handles.PSTHSmoothingWindow);
    answers{3} = num2str(handles.PSTHYLim(val,1));
    answers{4} = num2str(handles.PSTHYLim(val,2));
elseif strcmpi(whichHist, 'vert')
    if get(handles.radio_YTrial,'value')==1
        val = 1;
    else
        val = 2;
    end
    answers{1} = num2str(handles.HistBinSize(val));
    answers{2} = num2str(handles.HistSmoothingWindow);
    answers{3} = num2str(handles.ROILim(1));
    answers{4} = num2str(handles.ROILim(2));
    answers{5} = num2str(handles.HistYLim(val,1));
    answers{6} = num2str(handles.HistYLim(val,2));
else
    error('Second argument must be ''psth'' or ''vert''')
end
