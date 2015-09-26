function handles = egm_Mark_files_with_spikes(handles)


[source,ok] = listdlg('ListString',handles.dbase.EventSources,'InitialValue',1,'Name','Choice','PromptString','Select choice','SelectionMode','single');
[fnctn,ok]=listdlg('ListString',handles.dbase.EventFunctions,'InitialValue',1,'Name','Choice','PromptString','Select choice','SelectionMode','single');
[detector,ok]=listdlg('ListString',handles.dbase.EventDetectors,'InitialValue',1,'Name','Choice','PromptString','Select choice','SelectionMode','single');

for i=1:length(handles.dbase.EventSources)
    if strcmp(handles.dbase.EventSources{i},handles.dbase.EventSources(source)) & strcmp(handles.dbase.EventDetectors{i},handles.dbase.EventDetectors(detector)) & strcmp(handles.dbase.EventFunctions{i},handles.dbase.EventFunctions(fnctn))
        indx=i;
    end
end

propname = 'hasSpikes';

for c = 1:handles.TotalFileNumber
    if isempty(handles.dbase.EventTimes{1,indx}{1,c})
        should_mark=0;
    else
        should_mark=1;
    end
    handles.Properties.Names{c}{end+1} = propname;
    handles.Properties.Values{c}{end+1} = should_mark;
    handles.Properties.Types{c}(end+1) = 2;
end

handles = electro_gui('eg_RestartProperties',handles);
handles = electro_gui('eg_LoadProperties',handles);