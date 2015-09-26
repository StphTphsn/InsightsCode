function str = getPopupSelectedString(obj)
error('Deprecated. Use getSelectedString() instead.')
options = get(obj, 'String');
str = options{get(obj, 'Value')};