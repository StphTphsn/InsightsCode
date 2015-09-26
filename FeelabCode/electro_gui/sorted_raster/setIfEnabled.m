function setIfEnabled(obj, varargin)

if strcmp(get(obj, 'Enable'), 'on')
    set(obj, varargin{:})
else
    error('Object is not enabled!')
end
