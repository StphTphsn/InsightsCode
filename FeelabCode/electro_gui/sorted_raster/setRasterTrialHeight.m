function setRasterTrialHeight(h, val, units)
%SETRASTERTRIALHEIGHT Sets trial height in egm_Sorted_rasters GUI
%
%This corresponds to the 'Trial height' button and the 'Trial height units'
%radio buttons in the 'Raster' panel on the right side of the GUI.
%
%Syntax:
%    SETRASTERTRIALHEIGHT(H, VAL, UNITS)
%
%Input:
%    H        is a handle to the egm_Sorted_rasters GUI
%    VAL      is value for the height. This is what you would enter in the
%             dialog that appears after clicking the 'Trial height' button.
%    UNITS    is a string. It must match one of the radio buttons in
%             'Trial height units' in the GUI. The options are 'Trials',
%             'Seconds', 'Inches', and 'Percent'.
%
%If you set the units to 'Inches', there is another parameter that can be
%set. If the Y Axis is 'Trial #', call setRasterInchesPerSec(). If the Y
%Axis is 'Time', call setRasterTrialOverlap().
%
%See also: SETRASTERINCHESPERSEC, SETRASTERTRIALOVERLAP, SORTED_RASTERS

handles = guidata(h);

% Set radio buttons for units
radiohandles = findobj('Parent', handles.panel_TickUnits, 'Style', 'radiobutton');
options = get(radiohandles, 'String');
sel = strcmpi(units, options);
if ~any(sel)
    error('Invalid trial height units: %s\nValid units are: %s', ...
        units, strjoin(options, ', '))
end
set(radiohandles( sel), 'Value', 1)
set(radiohandles(~sel), 'Value', 0)

% Next we will invoke the callback for the 'Trial height' button. As an
% argument, we will give the answer to the dialog box that usually pops up.
% In most cases, the answer is just the value for the height
answer{1} = num2str(val);

% If units are inches, there is another value in the dialog! Value should
% remain unchanged by this function, so get the current value and give that
% as the answer.
if strcmpi(units, 'Inches')
    switch getSelectedString(handles.panel_YAxis)
        case 'Trial #'
            answer{2} = num2str(handles.PlotOverlap);
        case 'Time'
            answer{2} = num2str(handles.PlotInPerSec);
        otherwise
            error('Unrecognized Y axis')
    end
end

% Invoke the Trial height button callback to change the GUI
egm_Sorted_rasters('push_TickHeight_Callback', handles.push_TickHeight, [], handles, answer{:}) 