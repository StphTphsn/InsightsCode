function handles = egm_Mark_files_with_song(handles)

answer = inputdlg({'Sequences of syllable labels to consider','Maximum syllable separation (sec)','Boolean property name'},'Mark files',1,{'{}','0.2','hasSong'});
if isempty(answer)
    return
end
motifSequences = eval(answer{1});
motifInterval = str2num(answer{2});
propname = answer{3};

for c = 1:handles.TotalFileNumber
    if ~isempty(handles.SegmentTimes{c})
        f = find(handles.SegmentSelection{c}==1); % syllables that are selected
        son = handles.SegmentTimes{c}(f,1); % syllable onset
        soff = handles.SegmentTimes{c}(f,2); % syllable offset
        titl = handles.SegmentTitles{c}(f); % syllable title e.g.) 'a'
        stitl = '';
        for j = 1:length(titl)
            if strcmp(titl{j},'') | isempty(titl{j});
                stitl = [stitl char(1)];
            else
                stitl = [stitl titl{j}];
            end
        end
        for mot = 1:length(motifSequences)
            pos = 1;
            st = [];
            en = [];
            while pos <= length(stitl)
                [st_p en_p] = regexp(stitl(pos:end),motifSequences{mot},'start','end');
                if isempty(st_p)
                    pos = length(stitl) + 1;
                else
                    st = [st st_p(1)+pos-1];
                    en = [en en_p(1)+pos-1];
                    pos = st_p(1)+pos;
                end
            end
            for j = length(st):-1:1
                if max(son(st(j)+1:en(j))-soff(st(j):en(j)-1)) > handles.fs*motifInterval
                    st(j) = [];
                    en(j) = [];
                end
            end
            if ~isempty(st)
                should_mark = 1;
            else
                should_mark = 0;
            end
        end
    end
    
    handles.Properties.Names{c}{end+1} = propname;
    handles.Properties.Values{c}{end+1} = should_mark;
    handles.Properties.Types{c}(end+1) = 2;
end

handles = electro_gui('eg_RestartProperties',handles);
handles = electro_gui('eg_LoadProperties',handles);