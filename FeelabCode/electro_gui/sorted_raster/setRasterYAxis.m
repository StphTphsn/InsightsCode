function setRasterYAxis(h, str)
%SETRASTERYAXIS Sets Y axis units in egm_Sorted_rasters GUI
%
%This function corresponds to the 'Y axis' radio buttons in the 'Raster'
%panel on the right side of the GUI.
%
%Syntax:
%    SETRASTERYAXIS(H, STR)
%
%Input:
%    H      is a handle to the egm_Sorted_rasters GUI figure.
%    STR    is a string representing the y axis units. It must match the 
%           String property of one of the radio buttons. Valid strings are
%           'Trial #' and 'Time'.
%
%See also: SORTED_RASTERS

handles = guidata(h);
setRadioGroup(handles.panel_YAxis, str)