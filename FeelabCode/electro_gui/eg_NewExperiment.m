function [handles ischanged] = eg_NewExperiment(handles)

egfile = handles.egfile;

if handles.IsUpdating == 0
    if isfield(handles,'path_name')
        dr = handles.path_name;
    else
        dr = pwd;
    end

    path_name = uigetdir(dr,'Experiment Directory');
    if ~isstr(path_name)
        ischanged = 0;
        return
    end


    handles.path_name = path_name;

    num_chan = handles.DefaultChannelNumber;
    str = 'New experiment';
else
    num_chan = length(handles.chan_files);
    str = 'Update file list';
end


% Create dialog figure
screen_size = get(0,'screensize');
screen_size = get(0,'screensize');
fig_h = screen_size(4)*(0.05*(num_chan+2));
fig_w = screen_size(3)*.3;

fig = figure;
set(fig,'visible','on');
set(fig,'Name',str,'NumberTitle','off','MenuBar','none','doublebuffer','on','units','pixels','resize','off');
set(fig,'position',[(screen_size(3)-fig_w)/2 (screen_size(4)-fig_h)/2 fig_w fig_h]);
set(fig,'closerequestfcn',@CloseFig);


% Find all loader files
load_files = dir(egfile('egl_*.m'));
drop_str = {};
pop_str = {};
pop_val = 1;
for c = 1:length(load_files)
    pop_str{c} = load_files(c).name(5:end-2);
    if strcmp(pop_str{c},handles.DefaultFileLoader)
        pop_val = c;
    end
end

% Put objects into figure

for c = 1:num_chan+1
    fstr = handles.FileString;
    f = findstr(fstr,'#');
    fstr(f) = num2str(c-1);
    textlabel(c) = uicontrol('Style','text','units','normalized','string','',...
        'position',[0.05 (num_chan-c+2+0.5)/(num_chan+2) 0.5 0.3/(num_chan+2)],'FontSize',10,...
        'horizontalalignment','left','backgroundcolor',[.8 .8 .8]);
    textbox(c) = uicontrol('Style','edit','units','normalized','string',fstr,...
        'position',[0.05 (num_chan-c+2)/(num_chan+2) 0.5 0.4/(num_chan+2)],'FontSize',10,...
        'horizontalalignment','left','backgroundcolor',[1 1 1],'callback',@ChangeText);
    popup(c) = uicontrol('Style','popupmenu','units','normalized','string',pop_str,...
        'position',[0.6 (num_chan-c+2)/(num_chan+2) 0.35 0.4/(num_chan+2)],'FontSize',10,...
        'backgroundcolor',[1 1 1],'value',pop_val);
end

uicontrol('Style','pushbutton','units','normalized','string','OK',...
    'position',[.25 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@PushOK);
uicontrol('Style','pushbutton','units','normalized','string','Cancel',...
    'position',[.55 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@CloseFig);

ChangeText([], []);

ischanged = -1;
drawnow;
while ischanged == -1
    pause(0.01);
end

curr = pwd;
cd(handles.path_name);

handles.sound_files = dir(get(textbox(1),'string'));
handles.sound_loader = pop_str{get(popup(1),'value')};
handles.chan_files = {};
handles.chan_loader = {};
for c = 2:num_chan+1
    handles.chan_files{c-1} = dir(get(textbox(c),'string'));
    handles.chan_loader{c-1} = pop_str{get(popup(c),'value')};
end
delete(fig)
cd(curr);

    function PushOK(hObject, eventdata)
        ischanged = 1;
    end

    function CloseFig(hObject, eventdata)
        ischanged = 0;
        set(fig,'closerequestfcn','%');
    end

    function ChangeText(hObject, eventdata)
        curr = pwd;
        cd(handles.path_name);
        for c = 1:num_chan+1
            if c == 1
                str = 'Sound - ';
            else
                str = ['Channel ' num2str(c-1) ' - '];
            end
            mt = dir(get(textbox(c),'string'));
            set(textlabel(c),'string',[str num2str(length(mt)) ' files']);
        end
        cd(curr);
    end

end