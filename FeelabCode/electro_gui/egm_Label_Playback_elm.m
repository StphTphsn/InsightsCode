function handles = egm_Label_Playback_elm(handles)

filenum = str2num(get(handles.edit_FileNumber,'string')); % get file number
answer = inputdlg({'Motif'},'Playback',1,{'abcd'}); % input dialog box
if isempty(answer)
    error('No motif specified.')
    return
end
motif = answer{1}; 

s = 1; 
for syli = find(handles.SegmentSelection{filenum})
    handles.SegmentTitles{filenum}{syli} = motif(s);
    s = 1+ mod(s, numel(motif));
end

return