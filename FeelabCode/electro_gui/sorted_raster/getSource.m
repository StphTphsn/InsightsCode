function src = getSource(obj)
str = getSelectedString(obj);
val = get(obj, 'Value');

if val == 1 && strcmp(str, 'Sound')
    src = 'Sound';
else
    src = val - 1;
end