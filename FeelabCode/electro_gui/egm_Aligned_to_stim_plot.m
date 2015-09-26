function handles = egm_Aligned_to_stim_plot(handles)
fls = get(handles.list_Files,'string');
found = [];
for c = 1:handles.TotalFileNumber
    if strcmp(fls{c}(19),'F')
        found = [found c];
    end
end
if isempty(found)
    found = 1:handles.TotalFileNumber;
end



str = get(handles.popup_EventList,'string');
str = str(2:end);
mn = [];
for c = 1:length(str)
    mn = [mn ',''' str{c} ''''];
end
indx = eval(['menu(''Choose events''' mn ')']);

nums = [];
for c = 1:length(handles.EventTimes);
    nums(c) = size(handles.EventTimes{c},1);
end
cs = cumsum(nums);

f = length(find(cs<indx))+1;
if f>1
    g = indx-cs(f-1);
else
    g = indx;
end

evtimes = cell(1,handles.TotalFileNumber);
for c = found
    ev = handles.EventTimes{f}{g,c};
    isin = handles.EventSelected{f}{g,c};
    evtimes{c} = ev(find(isin==1));
end


mn = [];
f = [];
for c = 1:length(handles.chan_files)
    if ~isempty(handles.chan_files{c})
        f = [f c];
    end
end
for c = f
    mn = [mn ',''Channel ' num2str(c) ''''];
end
chan = eval(['menu(''Choose channel''' mn ')']);
chan = f(chan);


answer = inputdlg({'Min time (sec)','Max time (sec)','Min value','Max value','Spacing (%)'},'Options',1,{'-0.05','0.05','-0.4','0.4','-25'});
if isempty(answer)
    return
end
t1 = round(str2num(answer{1})*handles.fs);
t2 = round(str2num(answer{2})*handles.fs);
mn = str2num(answer{3});
mx = str2num(answer{4});
spc = (1+str2num(answer{5})/100)*(mx-mn);

offs = 0;
figure
for c = 1:handles.TotalFileNumber
    if ~isempty(evtimes{c})
        [data fs dt lab props] = eval(['egl_' handles.chan_loader{chan} '([''' handles.path_name '\' handles.chan_files{chan}(c).name '''],1)']);
        for d = 1:1:length(evtimes{c})
            if evtimes{c}(d)+t1>0 & evtimes{c}(d)+t2<=length(data)
                dt = data(evtimes{c}(d)+t1:evtimes{c}(d)+t2);
                dt(find(dt<mn)) = mn;
                dt(find(dt>mx)) = mx;
                plot((t1:t2)/fs*1000,offs+dt)
                hold on
                offs = offs + spc;
            end
        end
    end
end

axis tight;
ps = get(gcf,'position');
ps(2) = -400;
ps(4) = range(ylim)*40;
set(gcf,'position',ps);
set(gca,'ytick',[]);