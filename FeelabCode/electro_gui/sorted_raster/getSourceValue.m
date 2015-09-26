function val = getSourceValue(src, handles)

if ischar(src) && strcmp(src, 'Sound')
    val = 1;
elseif isnumeric(src) && isscalar(src) && src > 0 && src <= length(handles.egh.EventSources) && mod(src, 1) == 0
    val = src + 1;
else
    error('Invalid source')
end