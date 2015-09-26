function setRasterXLimAuto(h, val)
%SETRASTERXLIMAUTO Sets Auto limits checkbox in egm_Sorted_rasters GUI
% 
%Corresponds to the 'Auto limits' checkbox in the 'Raster' panel on the
%right side of the GUI. NOTE: Calling setRasterXLim() will override this
%function, so call this function afterwards.
%
%Syntax:
%    SETRASTERXLIMAUTO(H, VAL)
%
%Input:
%    H      is a handle to the egm_Sorted_rasters GUI
%    VAL    is the value for the checkbox (1 for checked, 0 for unchecked)
%
%See also: SORTED_RASTERS

handles = guidata(h);
set(handles.check_CopyWindow, 'Value', val)