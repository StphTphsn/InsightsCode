function setHistROI(h, whichHist, lims)
% To remove ROI, set lims to [-Inf, Inf]

setActiveHistogram(h, whichHist)
handles = guidata(h);

% Set ROI with the Options button callback, which also can change the bin
% size, smoothing, and y limits. Use default (current) values for
% everything except ROI.
answers = getHistOptionDefaults(h, whichHist);
if strcmpi(whichHist, 'psth')
    error('ROI not allowed for PSTH!')
elseif strcmpi(whichHist, 'vert')
    answers{3} = num2str(lims(1)); % roi start
    answers{4} = num2str(lims(2)); % roi end
end
egm_Sorted_rasters('push_PSTHBinSize_Callback', ...
    handles.push_PSTHBinSize, [], handles, answers)
