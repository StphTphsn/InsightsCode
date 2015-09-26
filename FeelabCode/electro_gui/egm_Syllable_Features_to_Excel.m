function handles = egm_Syllable_Features_to_Excel(handles)

if ~isfield(handles,'ExcelFile')
    handles.ExcelFile = actxserver('Excel.Application');
    set(handles.ExcelFile,'Visible',1);
    invoke(handles.ExcelFile.Workbooks,'Add');
end
if isempty(handles.ExcelFile.Activesheet)
    handles.ExcelFile = actxserver('Excel.Application');
    set(handles.ExcelFile,'Visible',1);
    invoke(handles.ExcelFile.Workbooks,'Add');
end

op = handles.ExcelFile;
sheet = op.Activesheet;

row = 0;
str = 'dummy';
while ~isempty(str)
    row = row+1;
    rng = get(sheet,'Range',['A' num2str(row)]);
    str = get(rng,'Text');
end

chan = cell(1,2); % actual values of the feature
lab = cell(1,2); % label of the feature
for axnum = 1:2 % channel 1,2
    if strcmp(get(handles.(['axes_Channel' num2str(axnum)]),'visible'),'on') % currently displayed channel
        v = get(handles.(['popup_Function' num2str(axnum)]),'value');
        str = get(handles.(['popup_Function' num2str(axnum)]),'string'); % e,g, (Raw),(SAPfeatures - Entropy)
        str = str{v};
        if isempty(findstr(str,' - ')) % no hyphen in function name -> normal function, just get the values
            chan{axnum}{1} = handles.(['chan' num2str(axnum)]);
            lab{axnum}{1} = str;
        else % SAPfeature
            chan{axnum} = handles.BackupChan{axnum}; % same thing for chan{1} and chan{2}
            lab{axnum} = handles.BackupLabel{axnum};
        end
    end
end

if row == 1 % attach data label
    set(get(sheet,'Range','A1'),'Value','File #');
    set(get(sheet,'Range','B1'),'Value','Syllable #');
    set(get(sheet,'Range','C1'),'Value','Start (s)');
    set(get(sheet,'Range','D1'),'Value','End (s)');
    set(get(sheet,'Range','E1'),'Value','Label');
    
    col = 5;
    for axnum = 1:2
        for j = 1:length(lab{axnum})
                col = col + 1;
                vl = dec2base(col-1,26);
                str = [];
                for c = 1:length(vl);
                    str = [str char(base2dec(vl(c),26)+64+(c==length(vl)))];
                end
                set(get(sheet,'Range',[str '1']),'Value',lab{axnum}{j});            
        end
    end
    row = row+1;
end

filenum = str2num(get(handles.edit_FileNumber,'string')); % get file number
f = find(handles.SegmentSelection{filenum}==1); % index of selected syllables
for c = 1:length(f)
    set(get(sheet,'Range',['A' num2str(row)]),'Value',filenum); % file number
    set(get(sheet,'Range',['B' num2str(row)]),'Value',c); % syllable number
    set(get(sheet,'Range',['C' num2str(row)]),'Value',handles.SegmentTimes{filenum}(f(c),1)/handles.fs); % syllable onset [s]
    set(get(sheet,'Range',['D' num2str(row)]),'Value',handles.SegmentTimes{filenum}(f(c),2)/handles.fs); % syllable offset [s]
    set(get(sheet,'Range',['E' num2str(row)]),'Value',handles.SegmentTitles{filenum}{f(c)}); % syllable number
        
    col = 5;
    for axnum = 1:2
        for j = 1:length(lab{axnum})
            col = col + 1; % column number
            vl = dec2base(col-1,26); % converting number to alphabet number
            str = [];
            for d = 1:length(vl);
                str = [str char(base2dec(vl(d),26)+64+(d==length(vl)))]; % converting alphabet number to alphabet using char
            end
            t1 = max([1 round(handles.SegmentTimes{filenum}(f(c),1)*length(chan{axnum}{j})/length(handles.sound))]); % syllable onset time in SAPfeature index
            t2 = min([length(chan{axnum}{j}) round(handles.SegmentTimes{filenum}(f(c),2)*length(chan{axnum}{j})/length(handles.sound))]); % syllable offset time in SAPfeature index 
            set(get(sheet,'Range',[str num2str(row)]),'Value',mean(chan{axnum}{j}(t1:t2))); % mean value during the syllable
        end
    end
    
    row = row+1; % go to the next row
end