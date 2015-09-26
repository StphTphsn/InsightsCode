function handles = egm_Batch_event_detect(handles)
% ElectroGui macro
% Batch event detection for faster analysis
% Uses current event detection algorithms
% Only works for segmentation based on sound amplitude

answer = inputdlg({'File range'},'File range',1,{['1:' num2str(handles.TotalFileNumber)]});
if isempty(answer)
    return
end

fls = eval(answer{1});
for c = 1:length(handles.menu_Segmenter)
    if strcmp(get(handles.menu_Segmenter(c),'checked'),'on')
        alg = get(handles.menu_Segmenter(c),'label');
    end
end

subplot(handles.axes_Sonogram);
txt = text(mean(xlim),mean(ylim),'Detecting events... Click to quit.','horizontalalignment','center','fontsize',14,'color','r','backgroundcolor','w');
set(txt,'ButtonDownFcn','set(gco,''color'',''g''); drawnow;');
for j = 1:length(fls)
    cnt = j;
    if sum(get(txt,'color')==[0 1 0])==3
        cnt = cnt-1;
        break
    end

    handles.FileLength(fls(j)) = 0;
    for axnum = 1:2
        val = get(handles.(['popup_Channel',num2str(axnum)]),'value');
        str = get(handles.(['popup_Channel',num2str(axnum)]),'string');
        nums = [];
        for c = 1:length(handles.EventTimes);
            nums(c) = size(handles.EventTimes{c},1);
        end
        if val <= length(str)-sum(nums) & val > 1
            if length(str{val})>4 & strcmp(str{val}(1:5),'Sound')
                [chan fs dt lab props] = eval(['egl_' handles.sound_loader '([''' handles.path_name '\' handles.sound_files(fls(j)).name '''],1)']);
            else
                chan = str2num(str{val}(9:end));
                [chan fs dt lab props] = eval(['egl_' handles.chan_loader{chan} '([''' handles.path_name '\' handles.chan_files{chan}(fls(j)).name '''],1)']);
            end
            handles.FileLength(fls(j)) = length(chan);
            handles.DatesAndTimes(fls(j)) = dt;
            if get(handles.(['popup_Function',num2str(axnum)]),'value') > 1
                str = get(handles.(['popup_Function',num2str(axnum)]),'string');
                str = str{get(handles.(['popup_Function',num2str(axnum)]),'value')};
                f = findstr(str,' - ');
                if isempty(f) % regular function
                    [chan lab] = eval(['egf_' str '(chan,handles.fs,handles.FunctionParams' num2str(axnum) ')']);
                else % multiple-value function
                    [chan lab] = eval(['egf_' str(1:f-1) '(chan,handles.fs,handles.FunctionParams' num2str(axnum) ')']);
                end
            end

            str = get(handles.(['popup_EventDetector' num2str(axnum)]),'string');
            dtr = str{get(handles.(['popup_EventDetector' num2str(axnum)]),'value')};
            if ~strcmp(dtr,'(None)')
                indx = handles.EventCurrentIndex(axnum);
                thres = handles.EventCurrentThresholds(indx);
                [events labels] = eval(['ege_' dtr '(chan,handles.fs,thres,handles.EventParams' num2str(axnum) ')']);
                
                for c = 1:length(events)
                    handles.EventThresholds(indx,fls(j)) = thres;
                    handles.EventTimes{indx}{c,fls(j)} = events{c};
                    handles.EventSelected{indx}{c,fls(j)} = ones(1,length(events{c}));
                end
            end
        else
            % no events for the given plot number
        end
    end
    
    

    set(txt,'string',['Detected events in file ' num2str(fls(j)) ' (' num2str(j) '/' num2str(length(fls)) '). Click to quit.']);
    drawnow;
end

delete(txt);

msgbox(['Detected events in ' num2str(cnt) ' files.'],'Detection complete');