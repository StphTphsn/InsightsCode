function val = popupLookup(obj, str)
options = get(obj, 'String');
val = find(strcmp(str, options));