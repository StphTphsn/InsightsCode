function str = getSelectedString(obj)
% Returns the string of the selected item in a popup menu or radio panel

typ = get(obj, 'Type');
if strcmp(typ, 'uipanel')
    % this is a radio panel
    radios = findobj('Parent', obj, 'Style', 'radiobutton'); % handles to radio buttons in this panel
    if isempty(radios)
        error('No children who are radio buttons in this panel')
    end
    options = get(radios, 'String');
    val = get(radios, 'Value'); % cell array of ones and zeros
    isSelected = cellfun(@(x) x == 1, val); % vector of true and false
    if sum(isSelected) ~= 1
        error('There are %g radio options selected in this panel, but I expected only one.', sum(isSelected))
    end
    str = options{isSelected};
elseif strcmp(typ, 'uicontrol') && strcmp('popupmenu', get(obj, 'Style'))
    % this is a popup menu
    options = get(obj, 'String');
    str = options{get(obj, 'Value')};
else
    error('Object must be a radio panel or popup menu')
end