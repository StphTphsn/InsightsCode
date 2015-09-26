function setLockLimitsToTrigger(h, val)
handles = guidata(h);
set(handles.check_LockLimits, 'Value', val)
egm_Sorted_rasters('check_LockLimits_Callback', ...
    handles.check_LockLimits, [], handles)