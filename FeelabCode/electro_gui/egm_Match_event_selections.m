function handles = egm_Match_event_selections(handles)
%electro_gui macro for identifiying mismatched event selection pairs and
%then setting them to either be selected or deselected
%
%Written by Galen Lynch 6/24/2014
joinStr = ' - ';
nDetectors = length(handles.EventDetectors);
jnAr = cell(1, nDetectors);
for dtctrNo = 1:nDetectors
    jnAr{dtctrNo} = joinStr;
end
detectorStrings = strcat(handles.EventSources, jnAr, handles.EventFunctions, jnAr, handles.EventDetectors);
if ~iscell(detectorStrings) || length(detectorStrings)<1
    errordlg('Must have at least 1 event type!','Error');
else
    %Ask user for event detector
    dtctrNo = menu('Choose event detector', detectorStrings{:});
    assert(size(handles.EventSelected{dtctrNo},1) == 2, 'An unusual event! Only event pairs are implemented ATM')
    %Ask what the default behavior should be
    detectMismatch = menu('How do you want to match events?', 'Match one set of the pair', 'Detect mismatches')-1;
    if detectMismatch < 0
        return
    end
    if detectMismatch
        mismatchVal = menu('What should happen to mismatched event selections?', 'Deselect', 'Select')-1;
        if mismatchVal < 0
            return
        end
        for fileNo = 1:size(handles.EventSelected{dtctrNo},2)
            if ~isempty(handles.EventSelected{dtctrNo}{1,fileNo})
                mismatched = xor(handles.EventSelected{dtctrNo}{1,fileNo}, handles.EventSelected{dtctrNo}{2,fileNo});
                handles.EventSelected{dtctrNo}{1,fileNo}(mismatched) = mismatchVal;
                handles.EventSelected{dtctrNo}{2,fileNo}(mismatched) = mismatchVal;
            end
        end
    else
        eventStrings = get(handles.popup_EventList,'string');
        eventStrings = eventStrings(2:end);%Clip off 'none'
        eventStrings = eventStrings(2*dtctrNo-1:2*dtctrNo);%only get strings of selected detector
        pairChoice = menu('All pairs should match which selection set?', eventStrings{:});
        if pairChoice < 1
            return
        end
        otherChoice = mod(2-pairChoice,2)+1;
        for fileNo = 1:size(handles.EventSelected{dtctrNo},2)
            if ~isempty(handles.EventSelected{dtctrNo}{1,fileNo})
                handles.EventSelected{dtctrNo}{otherChoice,fileNo} = handles.EventSelected{dtctrNo}{pairChoice,fileNo};
            end
        end
    end
    handles = electro_gui('eg_LoadFile', handles);
end