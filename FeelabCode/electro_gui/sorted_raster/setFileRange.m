function setFileRange(h, fileRange)
handles = guidata(h);
numFiles = length(handles.egh.sound_files);
isFileNumber = @(x) isnumeric(x) & 1 <= x & x <= numFiles & mod(x, 1) == 0;
assert(all(isFileNumber(fileRange)), 'Invalid file number in file range')
handles.FileRange = fileRange;
guidata(h, handles)