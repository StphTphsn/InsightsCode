function setSourceOption(h, whichSource, name, val)
handles = guidata(h);

switch lower(whichSource)
    case 'trigger'
        opts = handles.P.trig;
    case 'event'
        opts = handles.P.event;
    otherwise
        error('Invalid source: %s\n Source can be ''trigger'' or ''events''', whichSource)
end

if ~isfield(opts, name)
    error('Invalid option name: %s\nValid names are: %s', ...
        name, strjoin(fieldnames(opts), ', '))
end

opts.(name) = val;

switch lower(whichSource)
    case 'trigger'
        handles.P.trig = opts;
        if get(handles.check_CopyTrigger, 'Value') == 1
            handles.P.event = handles.P.trig;
        end
    case 'event'
        handles.P.event = opts;
        if get(handles.check_CopyEvents, 'Value') == 1
            handles.P.trig = handles.P.event;
        end
end

guidata(h, handles)