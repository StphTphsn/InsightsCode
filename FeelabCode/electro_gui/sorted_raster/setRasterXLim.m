function setRasterXLim(h, lims)
%SETRASTERXLIM Set time limits for raster in egm_Sorted_rasters GUI
%
%This corresponds to pushing the 'Time limits' button in the 'Rasters'
%panel on the right side of the GUI.
%
%Syntax:
%    SETRASTERXLIM(H, LIMS)
%    
%Input:
%    H       is a handle to the egm_Sorted_rasters GUI
%    LIMS    is a two-element vector containing the limits for the time
%            axis, in seconds. LIMS(1) is the minimum and LIMS(2) is the
%            maximum.
%
%See also: SORTED_RASTERS

handles = guidata(h);
% Convert axes limits to strings to mimic input dialog
tmin = num2str(lims(1));
tmax = num2str(lims(2));

egm_Sorted_rasters('push_TimeLimits_Callback', ...
    handles.push_TimeLimits, [], handles, tmin, tmax)