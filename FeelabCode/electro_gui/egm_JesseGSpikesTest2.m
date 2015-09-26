function handles = egm_JesseGSpikes(handles)

% Get the dbase structure
dbase = handles.dbase;

% Get information about which functions are currently displayed in ElectroGui
axs = [];
if get(handles.popup_Channel1,'value') > 1
    axs = 1;
end
if get(handles.popup_Channel2,'value') > 1
    axs = [axs 2];
end
if isempty(axs)
    errordlg('No function currently displayed!','Error');
    return
end

% Ask user which channel and function to obtain kernels from
if length(axs) > 1
    button = questdlg('Obtain kernels from','Kernels','Top plot','Bottom plot','Top plot');
    switch button
        case ''
            return
        case 'Top plot'
            axs = 1;
        case 'Bottom plot'
            axs = 2;
    end
end
param.axs = axs;

% Ask user which events to use as starting kernels
str = [];
for c = 1:length(dbase.EventSources)
    str{c} = [dbase.EventSources{c} ' - ' dbase.EventFunctions{c} ' - ' dbase.EventDetectors{c}];
end
[indx,ok] = listdlg('ListString',str,'InitialValue',[],'ListSize',[300 450],'Name','Select events','PromptString','Choose one or two event types');
if ok == 0
    return
end
if length(indx)<1 | length(indx)>2
    errordlg('Must select one or two event types!','Error');
    return
end
param.ev_indx = indx;


% Get parameters from the user
if length(param.ev_indx) == 1
    %%%%%%%%%%%%%%%%%%%%%%%%
else
    str = {'Files','Data interpolation factor','Max kernel extent (ms)','Kernel cutoff (% of max)','Kernel buffer (ms)','Template lag step (ms)','Template max value threshold (%)','Min ISI for first event type (ms)','Min ISI for second event type (ms)','Error threshold (fraction of mean)'};
    def = {['1:' num2str(length(dbase.Times))],'1','3','10','0.15','0.025','50','1','1','0.25'};
    answer = inputdlg(str,'Parameters',1,def);
    if isempty(answer)
        return
    end
    param.filerange = eval(answer{1});
    param.interpol = str2num(answer{2});
    param.kernel_range = [-str2num(answer{3}) str2num(answer{3})]/1000;
    param.cutoff = str2num(answer{4});
    param.buffer = str2num(answer{5})/1000;
    param.template_step = str2num(answer{6})/1000;
    param.template_thres = str2num(answer{7});
    param.ISItop = str2num(answer{8})/1000;
    param.ISIbottom = str2num(answer{9})/1000;
    param.threshold = str2num(answer{10});
end

log_txt = inf;
log_but = inf;
log_str = '';


% Run the algorithm
isfirst = 1;
cont = 0;
ii = 1;
rep = 0;
while ii <= length(param.filerange)
    i = param.filerange(ii);
    if rep == 1
        log_str{end+1} = [datestr(now) ' Redoing file ' num2str(i)];
        [log_txt log_but] = UpdateLog(log_txt,log_but,log_str);
    else

        log_str{end+1} = [datestr(now) ' Running file ' num2str(i)];

        [kernel tm interpdata param] = getKernel(dbase,handles,param,i);
        if ii > 1
            log_str{end+1} = 'Using kernel from previous file';
            kernel = kernel;
            tm = old_tm;
        end
        kernel = kernel;
        old_tm = tm;

        % Obtain templates
        log_str{end+1} = 'Calculating templates using two kernels';
        [templates rel_times] = dbaseSpikelet(handles,kernel,tm,param);

        % Determine which templates need to be eliminated due to destructive interference
        if isfirst == 1
            isfirst = 0;
            max_val = [];
            mn = [];
            mx = [];
            mnx = [];
            mxx = [];
            for c = 1:length(templates)
                max_val(c) = max(abs(templates{c}));
                mn(c) = min(templates{c});
                mx(c) = max(templates{c});
                mnx(c) = -round(rel_times(c)*handles.fs*param.interpol);
                mxx(c) = length(templates{c}) - round(rel_times(c)*handles.fs*param.interpol) - 1;
            end
            eliminate = (max_val < max(max_val)*param.template_thres/100);
            eliminate(find(mxx-mnx>max([length(kernel{1}) length(kernel{2})])+min([param.ISItop param.ISIbottom])/2*handles.fs*param.interpol))=1;


            % Plot templates and allow user to select them
            hg=round(sqrt((length(templates)+1)/1.5));
            wd=ceil((length(templates)+1)/hg);
            fig = figure('name','Templates');
            for c = 1:length(templates)
                subplot('position',[mod(c-1,wd)/wd (hg-fix((c-1)/wd))/hg-1/hg 1/wd 1/hg]);
                h(c) = plot(mnx(c):mxx(c),templates{c},'color',[1 0 0]);
                ylim([min(mn) max(mx)]);
                xlim([min(mnx) max(mxx)]);
                box on
                set(gca,'xtick',[],'ytick',[]);
                if eliminate(c)==1
                    set(h(c),'color',[.5 .5 .5]);
                end
                set(h(c),'buttondownfcn','col=get(gco,''color''); if col(1)==1; set(gco,''color'',[.5 .5 .5]); else; set(gco,''color'',[1 0 0]); end');
                set(gca,'buttondownfcn','obj=get(gca,''children''); col=get(obj,''color''); if col(1)==1; set(obj,''color'',[.5 .5 .5]); else; set(obj,''color'',[1 0 0]); end');
            end
            subplot('position',[(wd-1)/wd 0 1/wd 1/hg]);
            txt = text(0,0,'OK');
            set(txt,'horizontalalignment','center');
            xlim([-1 1]);
            ylim([-1 1]);
            axis off
            set(txt,'buttondownfcn','set(gco,''color'',''r'')');
            col = [0 0 0];
            while col(1) == 0
                try
                    col = get(txt,'color');
                catch
                    return
                end
                pause(0.1);
            end
            for c = 1:length(templates)
                col = get(h(c),'color');
                eliminate(c) = (col(1)<1);
            end
            delete(fig);
            drawnow;
        end

        % Eliminate unwanted templates
        templates(find(eliminate==1)) = [];
        rel_times(find(eliminate==1),:) = [];

        % Add individual kernels as two additional templates
        templates{end+1} = kernel{1}; rel_times(end+1,:) = [tm(1) inf];
        %yoyo i moved the kernel{2} to the end so that end-3 is the first terminal
        %template

        % Add .75 and 1/.75 times the kernel to be more robust for single
        % spike detection yoyo
        %templates{end+1} = .75*kernel{1}; rel_times(end+1,:) = [tm(1) inf];
        templates{end+1} = kernel{1}/.75; rel_times(end+1,:) = [tm(1) inf];
        templates{end+1} = kernel{2}; rel_times(end+1,:) = [inf tm(2)];
        %templates{end+1} = .75*kernel{2}; rel_times(end+1,:) = [inf tm(2)];
        templates{end+1} = kernel{2}/.75; rel_times(end+1,:) = [inf tm(2)];

    end

    % Get error traces for each of the templates
    for c = 1:length(templates)
        if ishandle(log_but)
            col = get(log_but,'foregroundcolor');
            if sum(col==[1 0 0])==3
                ii = inf;
                break
            end
        end
        log_str{end+1} = ['     Calculating error for template ' num2str(c) ' of ' num2str(length(templates))];
        [log_txt log_but] = UpdateLog(log_txt,log_but,log_str);
        %yoyoenerg = mean(templates{c}.^2);%calculates the energy in the current template
        if c<length(templates)-1 & c>length(templates)-3%~thres for dlms
            energ=mean(kernel{1}.^2);
        elseif c>length(templates)-2%~thresh for term
            energ=.5*mean(kernel{2}.^2);
        else %~threshold for dlm-term spike pairs
            energ=.75*mean(kernel{1}.^2);
        end
        %energ=1;%yoyo testing
        if c == 1
            errs = dbaseLSQ(templates{c},interpdata)/energ;%errs value is nlized by energy of the kernel
            ident = ones(size(errs));
        else
            nerrs = dbaseLSQ(templates{c},interpdata)/energ;
            lg = min([length(errs) length(nerrs)]);
            errs = errs(1:lg);
            nerrs = nerrs(1:lg);
            ident = ident(1:lg);
            f = find(nerrs<errs);
            errs(f) = nerrs(f);%errs gets redefined by nerrs based on length(interpData)? yoyo not sure why?
            ident(f) = c;
        end
    end

    if ii > length(param.filerange)
        break
    end

    if cont > -1
        cont = 0;
    else
        [tm1 tm2] = detectTwoEvents(interpdata,rel_times,handles,errs,ident,param);
    end
    fig = inf;
    delete(get(log_txt,'parent'));
    rep = 0;
    while cont == 0
        [tm1 tm2] = detectTwoEvents(interpdata,rel_times,handles,errs,ident,param);
        while ishandle(fig)
            pause(0.1);
        end
        lst = {'Display events','Change threshold','Run next file','Run all remaining files','Quit'};
        [val,ok] = listdlg('ListString',lst,'Name','Action','PromptString','Error trace calculated. Select action.','ListSize',[300 450],'SelectionMode','single','InitialValue',1);
        if ok == 0
            return;
        end
        switch val
            case 1
                fig = figure;
                plot(interpdata)
                hold on
                plot(tm1,interpdata(tm1),'ro');
                plot(tm2,interpdata(tm2),'kx');
            case 2
                answer = inputdlg({'Error threshold (fraction of mean)'},'Threshold',1,{num2str(param.threshold)});
                if ~isempty(answer)
                    param.threshold = str2num(answer{1});
                    cont = 1;
                    rep = 1;
                end
            case 3
                cont = 1;
            case 4
                cont = -1;
            case 5
                ii = length(param.filerange);
                cont = -1;
        end
    end

    if rep == 0
        tm1 = round(tm1/param.interpol);
        tm1(find(tm1<1 | tm1>length(interpdata)/param.interpol)) = [];
        tm2 = round(tm2/param.interpol);
        tm2(find(tm2<1 | tm2>length(interpdata)/param.interpol)) = [];

        handles.EventThresholds(param.ev_indx(1),i) = 0;
        handles.EventThresholds(param.ev_indx(2),i) = 0;

        for jj = 1:size(handles.EventTimes{param.ev_indx(1)},1)
            handles.EventTimes{param.ev_indx(1)}{jj,i} = tm1';
            handles.EventSelected{param.ev_indx(1)}{jj,i} = ones(size(tm1'));
        end
        for jj = 1:size(handles.EventTimes{param.ev_indx(2)},1)
            handles.EventTimes{param.ev_indx(2)}{jj,i} = tm2';
            handles.EventSelected{param.ev_indx(2)}{jj,i} = ones(size(tm2'));
        end

        ii = ii + 1;

        % Update kernels
        log_str{end+1} = 'Updating kernels';
        [log_txt log_but] = UpdateLog(log_txt,log_but,log_str);
        dbase.EventTimes = handles.EventTimes;
        dbase.EventIsSelected = handles.EventSelected;
        %yoyo[kernel2 old_tm dummy_interpdata dummy_param] = getKernel(dbase,handles,param,i);
%         for c = 1:length(kernel2)
%             if length(kernel2{c})>length(kernel{c})
%                 kernel2{c} = kernel2{c}(1:length(kernel{c}));
%             end
%             if length(kernel2{c})<length(kernel{c})
%                 kernel2{c}(end+1:length(kernel{c})) = 0;
%             end
%         end
        kernel2 = kernel;
    end
end

log_str{end+1} = 'Refreshing ElectroGui';
[log_txt log_but] = UpdateLog(log_txt,log_but,log_str);

figure(handles.figure_Main);
handles = electro_gui('eg_LoadFile',handles);

log_str{end+1} = 'Event detection completed!';


function [log_txt log_but] = UpdateLog(log_txt,log_but,log_str)

if ~ishandle(log_txt)
    fig = figure;
    set(fig,'visible','on');
    set(fig,'Name','Log','NumberTitle','off','MenuBar','none','doublebuffer','on','units','normalized','resize','off');
    log_txt = uicontrol('Style','listbox','units','normalized','string',log_str,...
        'position',[0.1 0.2 0.8 0.75],'FontSize',10,'backgroundcolor',[1 1 1]);
    log_but = uicontrol('Style','pushbutton','units','normalized','string','Quit',...
        'position',[0.7 0.05 0.2 0.1],'FontSize',10,'Callback','set(gco,''foregroundcolor'',[1 0 0]); drawnow;');
end
set(log_txt,'string',log_str);
set(log_txt,'value',length(log_str));
drawnow;


function [tm1 tm2] = detectTwoEvents(interpdata,rel_times,handles,errs,ident,param);
% Detect two events from an error trace

errs = errs/param.threshold; %divide by params.threshold b/c <1 and >1 below

% Find error minima and determine times of individual events
f = find(errs(2:end-1)<1 & errs(2:end-1)<errs(1:end-2) & errs(2:end-1)<errs(3:end))+1;
tm1 = f+round(rel_times(ident(f),1)'*handles.fs*param.interpol)+1;
tm2 = f+round(rel_times(ident(f),2)'*handles.fs*param.interpol)+1;
tm1 = tm1(find(tm1<inf));
tm2 = tm2(find(tm2<inf));

% Get rid of events too close to each other
tokeep = ones(size(tm1));
for c = 1:length(tm1)
    f = find(abs(tm1-tm1(c))<param.ISItop*handles.fs*param.interpol);
    if length(f)>1
        [mx pos] = max(abs(interpdata(tm1(f))));
        tokeep(f) = 0;
        tokeep(f(pos)) = 1;
    end
end
tm1(find(tokeep==0)) = [];

tokeep = ones(size(tm2));
for c = 1:length(tm2)
    f = find(abs(tm2-tm2(c))<param.ISItop*handles.fs*param.interpol);
    if length(f)>1
        [mx pos] = max(abs(interpdata(tm2(f))));
        tokeep(f) = 0;
        tokeep(f(pos)) = 1;
    end
end
tm2(find(tokeep==0)) = [];


function errs = dbaseLSQ(template,interpdata)
% Returns the mean squared difference between the data and the template at
% each point in the data
% Trims the data to a number of points that is a multiple of the template
% length

% Calculate errors
errs = [];
for c = 1:length(template)
    indx = c:length(template):length(interpdata)-length(template)+1;
    rdata = reshape(interpdata(c:indx(end)+length(template)-1),length(template),length(indx));
    rdata = rdata - repmat(template,1,size(rdata,2));
    rdata = mean(rdata.^2,1);
    errs(indx) = rdata;
end


function [kernel tm interpdata param] = getKernel(dbase,handles,param,filenum)
% Gets kernel from the data in file filenum
% kernel is a cell array containing average event waveforms
% kernels are only obtained for the first file in the filerange
% tm are the event times within the two individual kernels

% Get data and apply a function (such as a filter) to it
data = getContinuousFunction(handles,filenum,param.axs);

% Interpolate data
if param.interpol > 1
    t = 1/handles.fs:1/handles.fs:length(data)/handles.fs;
    t_interp = 1/(param.interpol*handles.fs):1/(param.interpol*handles.fs):length(data)/handles.fs;
    interpdata = interp1(t,data,t_interp,'spline');
else
    interpdata = data;
end

% Make sure data is oriented vertically
if size(interpdata,2)>size(interpdata,1)
    interpdata = interpdata';
end

% Obtain kernel, if necessary
for c = 1:length(param.ev_indx)
    % Get event times
    indx = param.ev_indx(c);
    ev_select = handles.EventSelected{indx}{1,filenum};
    for d = 2:size(handles.EventSelected{indx},1)
        ev_select = ev_select .* handles.EventSelected{indx}{d,filenum};
    end

    if size(handles.EventTimes{indx},1) == 1
        ev_times = handles.EventTimes{indx}{1,filenum} * param.interpol;
    else
        ev_times = handles.EventTimes{indx}(:,filenum);
        for d = 1:length(ev_times)
            ev_times{d} = ev_times{d}(find(ev_select==1));
            ev_times{d} = ev_times{d} * param.interpol;
        end

        % Determine which event component to use
        mx_val = 0;
        ev_indx = 1;
        for d = 2:length(ev_times)
            if mean(abs(interpdata(ev_times{d}))) > mx_val
                ev_indx = d;
                mx_val = mean(abs(interpdata(ev_times{d})));
            end
        end
        ev_times = ev_times{ev_indx};
    end

    % Kernel time limits, in number interpolated points
    win = round(param.kernel_range * handles.fs * param.interpol);
    ev_times = ev_times(find(ev_times+win(1)>0 & ev_times+win(2)<=length(interpdata)));

    % Obtain kernel
    if length(ev_times)>0%yoyo this if statement added.
        kernel{c} = zeros(win(2)-win(1)+1,1);
        for d = 1:length(ev_times)
            kernel{c} = kernel{c}+interpdata(ev_times(d)+win(1):ev_times(d)+win(2));
        end
        kernel{c} = kernel{c}/length(ev_times);
    end

    % Extract only the "energetic" part of the kernel
    win = round(param.kernel_range * handles.fs * param.interpol);
    f = find(abs(kernel{c})>param.cutoff/100*max(abs(kernel{c})));
    mn = min(f);
    mx = max(f);
    mn = max([1 mn-round(param.buffer*handles.fs*param.interpol)]);
    mx = min([length(kernel{c}) mx+round(param.buffer*handles.fs*param.interpol)]);
    kernel{c} = kernel{c}(mn:mx);
    tm(c) = -(mn+win(1))/(handles.fs*param.interpol);
end


function [templates rel_times] = dbaseSpikelet(handles,kernel,tm,param)
% Returns templates generated from two kernels
% rel_times are the relative times of the two kernels with respect to the
% start of the template


% Generate a list of lags for one kernel with respect to another
num_templates = ceil((length(kernel{1})+length(kernel{2}))/(handles.fs*param.interpol)/param.template_step)+1;
lags = unique(round(linspace(-length(kernel{1}),length(kernel{2}),num_templates)));

% Generate templates by shifting one kernel over the other
templates = {};
rel_times = zeros(0,2);
for c = 1:length(lags)
    if lags(c) <= 0
        tmp = kernel{1};
        tmp(end+1:length(kernel{2})-lags(c)) = 0;
        tmp(-lags(c)+1:length(kernel{2})-lags(c)) = tmp(-lags(c)+1:length(kernel{2})-lags(c)) + kernel{2};
        rel_times(end+1,:) = [tm(1) -lags(c)/(handles.fs*param.interpol)+tm(2)];
    else
        tmp = kernel{2};
        tmp(end+1:length(kernel{1})+lags(c)) = 0;
        tmp(lags(c)+1:length(kernel{1})+lags(c)) = tmp(lags(c)+1:length(kernel{1})+lags(c)) + kernel{1};
        rel_times(end+1,:) = [lags(c)/(handles.fs*param.interpol)+tm(1) tm(2)];
    end
    templates{end+1} = tmp;
end


function funct = getContinuousFunction(handles,filenum,axnum)
% Reads data from file #filenum
% Applies the function currently displayed in ElectroGui to the data
% axnum = 1 for top plot, 2 for bottom plot


% Read data from the file
val = get(handles.(['popup_Channel',num2str(axnum)]),'value');
str = get(handles.(['popup_Channel',num2str(axnum)]),'string');
chan = str2num(str{val}(9:end));
if length(str{val})>4 & strcmp(str{val}(1:5),'Sound')
    [funct fs dt lab props] = eval(['egl_' handles.sound_loader '([''' handles.path_name '\' handles.sound_files(filenum).name '''],1)']);
else
    [funct fs dt lab props] = eval(['egl_' handles.chan_loader{chan} '([''' handles.path_name '\' handles.chan_files{chan}(filenum).name '''],1)']);
end

% Run currently displayed function on the data
if get(handles.(['popup_Function',num2str(axnum)]),'value') > 1
    str = get(handles.(['popup_Function',num2str(axnum)]),'string');
    str = str{get(handles.(['popup_Function',num2str(axnum)]),'value')};
    f = findstr(str,' - ');
    if isempty(f) % regular function
        [funct lab] = eval(['egf_' str '(funct,handles.fs,handles.FunctionParams' num2str(axnum) ')']);
    else % multi-channel function
        strall = get(handles.(['popup_Function',num2str(axnum)]),'string');
        count = 0;
        for c = 1:get(handles.(['popup_Function',num2str(axnum)]),'value')
            count = count + strcmp(strall{c}(1:min([f-1 length(strall{c})])),str(1:f-1));
        end
        [funct lab] = eval(['egf_' str(1:f-1) '(funct,handles.fs,handles.FunctionParams' num2str(axnum) ')']);
        funct = funct{count};
    end
end

if isempty(funct)
    return
end

% Sample function output at the same frequency as the data
if length(funct) < handles.FileLength(filenum)
    indx = round(linspace(1,length(funct),handles.FileLength(filenum)));
    funct = funct(indx);
end

if size(funct,1)>size(funct,2)
    funct = funct';
end
