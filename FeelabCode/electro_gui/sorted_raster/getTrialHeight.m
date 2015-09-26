function ht = getTrialHeight(handles)
%GETTRIALHEIGHT Trial height from egm_Sorted_rasters gui
%
%HT = GETTRIALHEIGHT(HANDLES)
%
%HT         is the height. It corresponds to the 'Trial height' button in 
%           the 'Raster' panel on the right side of the egm_Sorted_rasters 
%           GUI
%HANDLES    is the guidata from the egm_Sorted_rasters figure
%
%The height HT depends on the selected units in the GUI. To get the
%selected units do this:
%    handles = guidata(h);
%    units = getSelectedString(handles.panel_TickUnits);
% 
%See also: GETSORTEDRASTERPARAMETERS, SORTED_RASTERS

f = findobj('Parent', handles.panel_TickUnits, ...
            'Style',  'radiobutton', ...
            'Value',  1);

ch = get(handles.panel_TickUnits,'children');
f = 6-find(ch==f);
ht = handles.PlotTickSize(f);