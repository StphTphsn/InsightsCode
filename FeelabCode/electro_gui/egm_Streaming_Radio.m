function handles = egm_Streaming_Radio(handles)
% ElectroGui macro
% Media player for streaming internet radio or local playlists
% Pauses (for playlists) or mutes (for internet radio) during sound
% playback in ElectroGui

if exist('handles') & isstr(handles)
    switch handles
        case 'start'
            ud = get(gco,'userdata');
            mp = ud.mp;
            ud.im = get(mp.settings,'mute');
            set(gco,'userdata',ud);
            set(mp.settings,'mute',1);
            if ud.if
                mp.controls.pause;
            end
        case 'end'
            ud = get(gco,'userdata');
            mp = ud.mp;
            xd = get(ud.xb,'xlim');
            xd = xd(2)-xd(1);
            pause(xd+0.5);
            set(mp.settings,'mute',ud.im);
            if ud.if
                mp.controls.play;
            end
    end
    return
end

fig = figure('Name','Radio','NumberTitle','off','MenuBar','none','doublebuffer','on','resize','off','CloseRequestFcn',@RadioClose);
ps = get(gcf,'position');
ps(4) = ps(4)/3.5;
set(gcf,'position',ps);

wbur = 'http://www.wbur.org/listen/feed/shoutcast.asx';

uicontrol('Style','text','units','normalized','string','URL or playlist','HorizontalAlignment','Left',...
    'position',[0.05 0.75 0.45 0.2],'FontSize',12,'BackgroundColor',[.8 .8 .8]);
edit_time = uicontrol('Style','text','units','normalized','string','','HorizontalAlignment','Right',...
    'position',[0.5 0.75 0.45 0.2],'FontSize',12,'BackgroundColor',[.8 .8 .8]);
edit_URL = uicontrol('Style','edit','units','normalized','string',wbur,'HorizontalAlignment','Left',...
    'position',[0.05 0.5 0.7 0.25],'FontSize',10,'BackgroundColor',[1 1 1]);
push_Browse = uicontrol('Style','pushbutton','units','normalized','string','Browse...',...
    'FontSize',12,'position',[0.75 0.5 0.2 0.25],'Callback',@RadioBrowse);
push_play = uicontrol('Style','pushbutton','units','normalized','string','>',...
    'FontSize',14,'FontWeight','Bold','position',[0.05 0.1 0.1 0.3],'Callback',@RadioPlay);
push_stop = uicontrol('Style','pushbutton','units','normalized','string','',...
    'FontSize',14,'FontWeight','Bold','position',[0.175 0.1 0.1 0.3],'Callback',@RadioStop);
push_prev = uicontrol('Style','pushbutton','units','normalized','string','|<',...
    'FontSize',14,'FontWeight','Bold','position',[0.3 0.1 0.1 0.3],'Callback',@RadioPrev);
push_next = uicontrol('Style','pushbutton','units','normalized','string','>|',...
    'FontSize',14,'FontWeight','Bold','position',[0.425 0.1 0.1 0.3],'Callback',@RadioNext);
slide_volume = uicontrol('Style','slider','units','normalized','position',[0.55 0.1 0.4 0.15],...
    'Min',0,'Max',100,'SliderStep',[0.01 0.1],'Value',25,'callback',@RadioVolume);
subplot('position',[0.6 0.25 0.3 0.15]);
bar(1:10)
axis tight
axis off

mp = actxcontrol('WMPlayer.OCX',[0 0 0.01 0.01]);
set(mp,'uiMode','none');
assignin('base','MovieControl',mp);
set(mp.settings,'autoStart',0);

IsStopped = 1;
IsFile = 0;

tm = timer('TimerFcn', {@RadioTimer}, 'ExecutionMode', 'FixedSpacing', 'Period', 1);
start(tm)

if exist('handles')
    backup = get(handles.push_Play,'Callback');
    ud.mp = mp;
    ud.xb = handles.axes_Sonogram;
    ud.if = IsFile;
    set(handles.push_Play,'userdata',ud);
    str = ['egm_Streaming_Radio(''start'');' backup '; egm_Streaming_Radio(''end'');'];
    set(handles.push_Play,'Callback',str);
end


    function RadioTimer(hObject, eventdata)
        st = mp.status;
        if ~isempty(st)
            set(fig,'Name',['Radio - ' mp.status]);
        end
        set(edit_time,'String',get(mp.controls,'currentPositionString'));
    end

    function RadioPlay(hObject, eventdata)
        switch get(push_play,'string')
            case '>'
                set(push_play,'string','| |');
                if IsStopped
                    URL = get(edit_URL,'string');
                    IsFile = 1;
                    try
                        finfo(URL);
                    catch
                        IsFile = 0;
                    end
                    if isempty(URL)
                        return
                    end
                    mp.URL = URL;
                    mp.controls.play;
                    IsStopped = 0;
                elseif IsFile
                    mp.controls.play;
                end
                if exist('handles')
                    ud = get(handles.push_Play,'userdata');
                    ud.if = IsFile;
                    set(handles.push_Play,'userdata',ud);
                end
                set(mp.settings,'mute',0);
                set(mp.settings,'volume',round(get(slide_volume,'value')));
            case '| |'
                set(push_play,'string','>');
                set(mp.settings,'mute',1);
                if IsFile
                    mp.controls.pause;
                end
        end
    end

    function RadioVolume(hObject, eventdata)
        set(mp.settings,'volume',round(get(slide_volume,'value')));
    end

    function RadioStop(hObject, eventdata)
        mp.controls.stop;
        set(push_play,'string','>');
        IsStopped = 1;
    end

    function RadioClose(hObject, eventdata)
        stop(tm)
        delete(fig)
        if exist('handles')
            set(handles.push_Play,'Callback',backup);
        end
    end

    function RadioPrev(hObject, eventdata)
        mp.controls.previous;
    end

    function RadioNext(hObject, eventdata)
        mp.controls.next;
    end

    function RadioBrowse(hObject, eventdata)
       [filename, pathname, dummy] = uigetfile('*.*', 'Playlist file');
       if ~isstr(filename)
           return
       end
       set(edit_URL,'string',[pathname filename]);
    end
end