function setHistBinSize(h, whichHist, val)

setActiveHistogram(h, whichHist)
answers = getHistOptionDefaults(h, whichHist);

answers{1} = num2str(val); % bin size

handles = guidata(h);
egm_Sorted_rasters('push_PSTHBinSize_Callback', ...
    handles.push_PSTHBinSize, [], handles, answers)
