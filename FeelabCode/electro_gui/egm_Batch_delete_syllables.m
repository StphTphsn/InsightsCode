function handles = egm_Batch_delete_syllables(handles)

filenum = str2num(get(handles.edit_FileNumber,'string'));
answer = inputdlg({'Delete syllables in files'},'Delete files',1,{[num2str(filenum+1) ':' num2str(handles.TotalFileNumber)]});
if isempty(answer)
    return
end
fls = eval(answer{1});

for c = fls
    handles.SegmentSelection{c} = 0*handles.SegmentSelection{c};
end