function handles = egm_unselect_cutoff_syllables(handles)

leeway = .01*handles.fs; 
for c = 1:handles.TotalFileNumber
    if ~isempty(handles.SegmentTimes{c})
        if handles.SegmentTimes{c}(1,1) < leeway
            handles.SegmentSelection{c}(1) = 0;
        end
        if handles.FileLength(c) - handles.SegmentTimes{c}(end,end) <leeway
            handles.SegmentSelection{c}(end) = 0; 
        end
    end
end
handles = electro_gui('eg_RestartProperties',handles);
handles = electro_gui('eg_LoadProperties',handles);