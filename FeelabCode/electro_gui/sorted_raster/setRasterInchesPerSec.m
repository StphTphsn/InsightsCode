function setRasterInchesPerSec(h, val)
% This only has an effect if the Trial height units are inches and the Y
% axis is 'Time'

handles = guidata(h);

% Set height units to Inches (will go back to original units at the end)
unitsOriginal = getSelectedString(handles.panel_TickUnits);
setRadioGroup(handles.panel_TickUnits, 'Inches');

% Set Y axis to 'Time' (will go back to original axis at the end)
axisOriginal = getSelectedString(handles.panel_YAxis);
setRadioGroup(handles.panel_YAxis, 'Time');

% Invoke callback to change the inches per sec in the GUI
answer{1} = num2str(getTrialHeight(handles));
answer{2} = num2str(val);
egm_Sorted_rasters('push_TickHeight_Callback', ...
    handles.push_TickHeight, [], handles, answer{:})

% Return to original height units
setRadioGroup(handles.panel_TickUnits, unitsOriginal)

% Return Y axis to its original state
setRadioGroup(handles.panel_YAxis, axisOriginal);
