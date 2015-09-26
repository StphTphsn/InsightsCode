function setHistSmoothing(h, whichHist, val)
setActiveHistogram(h, whichHist)
answers = getHistOptionDefaults(h, whichHist);

answers{2} = num2str(val); % smoothing window

handles = guidata(h);
egm_Sorted_rasters('push_PSTHBinSize_Callback', ...
    handles.push_PSTHBinSize, [], handles, answers)