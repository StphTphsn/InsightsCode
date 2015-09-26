function setRadioGroup(hPanel, str)
%SETRADIOGROUP Sets a radio group and invokes its callback
%
%Syntax:
%    SETRADIOGROUP(HPANEL, STR)
%
%Input:
%    HPANEL    is a handle to a uipanel object that contains the radio
%              button group.
%    STR       is a string that matches one of the strings of the radio
%              buttons that are children of HPANEL. The value of this radio
%              button object is set to 1 and its callback is invoked. For
%              all other radio button children of HPANEL, their value is
%              set to 0.
%
%See also: GETSELECTEDSTRING

assert(strcmpi('uipanel', get(hPanel, 'Type')), ...
    'Object must be a uipanel.')

radiobuttons = findobj('Parent', hPanel, 'Style', 'radiobutton');

assert(~isempty(radiobuttons), ...
    'There are no radio buttons that are children of that panel.')

radiostrings = get(radiobuttons, 'String');
sel = strcmpi(str, radiostrings);

% Error if string doesn't match one of the radio buttons
if ~any(sel)
    valid = sprintf('''%s'', ', radiostrings{:});
    valid = valid(1:end - 2); % remove trailing comma and space
    msg = sprintf('No radio buttons match desired string ''%s''.\n', str);
    msg = [msg, sprintf('Valid options are: %s', valid)];
    error(msg)
end


hObject = radiobuttons(sel);
set(hObject, 'Value', 1)
set(radiobuttons(~sel), 'Value', 0)
cb = get(hObject, 'Callback');
cb(hObject, [])