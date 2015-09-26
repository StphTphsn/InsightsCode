function setHistYLim(h, whichHist, lims)
% Arguments:
%   whichHist = 'psth' or 'vert' to change the limits of the peristimulus
%               time histogram or the vertical histogram
%   lims = 'Auto' or a two-element vector of [ymin ymax] for manual axis
%          limits

setActiveHistogram(h, whichHist)
handles = guidata(h);

if ischar(lims) && strcmpi(lims, 'Auto')
    set(handles.radio_PSTHManual, 'Value', 0)
    set(handles.radio_PSTHAuto,   'Value', 1)
    % As far as I can tell, there is no Callback for these radio buttons
elseif isnumeric(lims) && isvector(lims) && length(lims) == 2
    % Manual axis limits
    set(handles.radio_PSTHAuto,   'Value', 0)
    set(handles.radio_PSTHManual, 'Value', 1)
    % Set limits with the Options button callback, which also can change
    % the bin size, smoothing, and ROI. Use default (current) values for
    % everything except y limits.
    answers = getHistOptionDefaults(h, whichHist);
    if strcmpi(whichHist, 'psth')
        answers{3} = num2str(lims(1)); % ymin
        answers{4} = num2str(lims(2)); % ymax
    elseif strcmpi(whichHist, 'vert')
        answers{5} = num2str(lims(1)); % ymin
        answers{6} = num2str(lims(2)); % ymax
    end
    egm_Sorted_rasters('push_PSTHBinSize_Callback', ...
        handles.push_PSTHBinSize, [], handles, answers)
else
    error('Y limits must either be ''Auto'' or a 2-element vector of [ymin ymax]')
end

