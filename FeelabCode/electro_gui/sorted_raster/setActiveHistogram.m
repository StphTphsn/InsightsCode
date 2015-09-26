function setActiveHistogram(h, whichHist)
% Push 'PSTH' or 'Vert.' button 
handles = guidata(h);
switch lower(whichHist)
    case 'psth'
        egm_Sorted_rasters('push_HistHoriz_Callback', ...
            handles.push_HistHoriz, [], handles)
    case 'vert'
        egm_Sorted_rasters('push_HistVert_Callback', ...
            handles.push_HistVert, [], handles)
    otherwise
        error('Invalid choice for histogram: ''%s''\nMust be either ''psth'' or ''vert''', whichHist)
end
