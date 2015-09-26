function callbackIfEnabled(fcnname, obj, varargin)
%CALLBACKIFENDABLED Callback from egm_Sorted_rasters if obj is enabled
%
%If the object is not enabled, an error is thrown.
%
%Usage:
%    CALLBACKIFENABLED(FCNNAME, OBJ, ARG1, ...)
%    
%    FCNNAME is the name of the callback function
%    OBJ     is a handle to the object. The callback is only executed if
%            this object is enabled. This object is also passed as the
%            first argument to the callback.
%    ARG1    Any further arguments are passed to the callback.

if strcmp('on', get(obj, 'Enable'))
    egm_Sorted_rasters(fcnname, obj, varargin{:})
else
    error('Object not enabled')
end
