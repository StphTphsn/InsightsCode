function varargout = eg_Template_Editor(varargin)
% EG_TEMPLATE_EDITOR M-file for eg_Template_Editor.fig
%      EG_TEMPLATE_EDITOR, by itself, creates a new EG_TEMPLATE_EDITOR or raises the existing
%      singleton*.
%
%      H = EG_TEMPLATE_EDITOR returns the handle to a new EG_TEMPLATE_EDITOR or the handle to
%      the existing singleton*.
%
%      EG_TEMPLATE_EDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EG_TEMPLATE_EDITOR.M with the given input arguments.
%
%      EG_TEMPLATE_EDITOR('Property','Value',...) creates a new EG_TEMPLATE_EDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before eg_Template_Editor_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to eg_Template_Editor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help eg_Template_Editor

% Last Modified by GUIDE v2.5 09-Mar-2008 03:17:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @eg_Template_Editor_OpeningFcn, ...
                   'gui_OutputFcn',  @eg_Template_Editor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before eg_Template_Editor is made visible.
function eg_Template_Editor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to eg_Template_Editor (see VARARGIN)

handles.template = varargin{1};
handles.CurrentTemplate = get(handles.template,'userdata');

% Make template editor's directory the current directory
[pathstr, name, ext] = fileparts(mfilename('fullpath')); % changed from: ...
% [pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
cd(pathstr);

mt = dir('egt_*.m');
handles.TemplateTitles = {};
handles.Templates = {};
for c = 1:length(mt)
    handles.TemplateTitles{c} = mt(c).name(5:end-2);
    handles.Templates{c} = eval(['egt_' handles.TemplateTitles{c}]);
end

str = ['(Current ElectroGui template)',handles.TemplateTitles];
set(handles.list_saved,'string',str);

handles.Width = 5;
handles.Index = 1;

handles = DrawTemplate(handles);


% Choose default command line output for eg_Template_Editor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes eg_Template_Editor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function handles = DrawTemplate(handles)

subplot(handles.axes_Main);
cla

handles.TextHandles = [];
handles.RectHandles = [];
hold on
for c = 1:length(handles.CurrentTemplate.Plot)
    ytop = sum(handles.CurrentTemplate.Height(1:c-1)+handles.CurrentTemplate.Interval(1:c-1));
    ybottom = ytop+handles.CurrentTemplate.Height(c);
    handles.RectHandles(c) = plot([0 handles.Width handles.Width 0 0],[ytop ytop ybottom ybottom ytop],'k');
end
for c = 1:length(handles.CurrentTemplate.Plot)
    ytop = sum(handles.CurrentTemplate.Height(1:c-1)+handles.CurrentTemplate.Interval(1:c-1));
    ybottom = ytop+handles.CurrentTemplate.Height(c);
    handles.TextHandles(c) = text(handles.Width/2,(ytop+ybottom)/2,handles.CurrentTemplate.Plot{c});
    set(handles.TextHandles(c),'horizontalalignment','center','verticalalignment','middle');
    set(handles.TextHandles(c),'backgroundcolor','w','fontsize',8);
    set(handles.TextHandles(c),'buttondownfcn','eg_Template_Editor(''click_text'',gcbo,[],guidata(gcbo))');
end

maxh = sum(handles.CurrentTemplate.Height+handles.CurrentTemplate.Interval); 
plot([handles.Width-0.5 handles.Width],[maxh maxh],'k','linewidth',2);

set(gca,'ydir','reverse');
axis equal;
axis tight;
axis off

handles = SelectObject(handles);


function handles = SelectObject(handles)

set(handles.RectHandles,'color','k','linewidth',1);
set(handles.TextHandles,'color','k','backgroundcolor','w');

subplot(handles.axes_Main);

c = handles.Index;
delete(handles.RectHandles(c));
delete(handles.TextHandles(c));

hold on
ytop = sum(handles.CurrentTemplate.Height(1:c-1)+handles.CurrentTemplate.Interval(1:c-1));
ybottom = ytop+handles.CurrentTemplate.Height(c);
handles.RectHandles(c) = plot([0 handles.Width handles.Width 0 0],[ytop ytop ybottom ybottom ytop],'r','linewidth',2);
handles.TextHandles(c) = text(handles.Width/2,(ytop+ybottom)/2,handles.CurrentTemplate.Plot{c});
set(handles.TextHandles(c),'horizontalalignment','center','verticalalignment','middle');
set(handles.TextHandles(c),'color','r','backgroundcolor','w','fontsize',8)
set(handles.TextHandles(c),'buttondownfcn','eg_Template_Editor(''click_text'',gcbo,[],guidata(gcbo))');
axis equal;
axis tight;
axis off

pos = [];
for c = 1:length(handles.TextHandles)
    pos(c,:) = get(handles.TextHandles(c),'position');
end
repos = zeros(1,length(handles.TextHandles));
for c = 1:length(handles.TextHandles)
    if repos(c)==0
        hg = get(handles.TextHandles(c),'extent');
        f = find(abs(pos(:,2)-pos(c,2))<hg(4));
        if length(f)>1
            xs = linspace(0,handles.Width,2*length(f)+1);
            xs = xs(2:2:end);
            for j = 1:length(f)
                ps = pos(f(j),:);
                ps(1) = xs(j);
                set(handles.TextHandles(f(j)),'position',ps);
            end
        end
    end
end

str = get(handles.popup_Plot,'string');
for c = 1:length(str)
    if strcmp(str{c},handles.CurrentTemplate.Plot{handles.Index})
        set(handles.popup_Plot,'value',c);
    end
end

set(handles.edit_Height,'string',num2str(handles.CurrentTemplate.Height(handles.Index)));
set(handles.edit_FromTop,'string',num2str(handles.CurrentTemplate.Height(handles.Index)+handles.CurrentTemplate.Interval(handles.Index)));
set(handles.edit_FromBottom,'string',num2str(handles.CurrentTemplate.Interval(handles.Index)));

set(handles.check_AutoLimits,'value',handles.CurrentTemplate.AutoYLimits(handles.Index));

set(handles.(['radio_YScale' num2str(handles.CurrentTemplate.YScaleType(handles.Index))]),'value',1);
switch str{get(handles.popup_Plot,'value')}
    case {'Segments','Segment labels'}
        val = 'off';
    otherwise
        val = 'on';
end

for c = 0:2
    set(handles.(['radio_YScale' num2str(c)]),'enable',val);
end

switch str{get(handles.popup_Plot,'value')}
    case {'Segments','Segment labels','Sonogram','Sound wave'}
        val = 'off';
    otherwise
        val = 'on';
end
set(handles.check_AutoLimits,'enable',val);
            


function click_text(hObject, eventdata, handles)

handles.Index = find(hObject==handles.TextHandles);;

handles = SelectObject(handles);

guidata(gca, handles);


% --- Outputs from this function are returned to the command line.
function varargout = eg_Template_Editor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popup_Plot.
function popup_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to popup_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Plot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Plot

str = get(handles.popup_Plot,'string');
val = get(handles.popup_Plot,'value');

handles.CurrentTemplate.Plot{handles.Index} = str{val};

handles = DrawTemplate(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popup_Plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Height_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Height as text
%        str2double(get(hObject,'String')) returns contents of edit_Height as a double


handles.CurrentTemplate.Height(handles.Index) = str2num(get(handles.edit_Height,'string'));

handles = DrawTemplate(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_Height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FromTop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FromTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FromTop as text
%        str2double(get(hObject,'String')) returns contents of edit_FromTop as a double


handles.CurrentTemplate.Interval(handles.Index) = str2num(get(handles.edit_FromTop,'string'))-handles.CurrentTemplate.Height(handles.Index);

handles = DrawTemplate(handles);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function edit_FromTop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FromTop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FromBottom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FromBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FromBottom as text
%        str2double(get(hObject,'String')) returns contents of edit_FromBottom as a double

handles.CurrentTemplate.Interval(handles.Index) = str2num(get(handles.edit_FromBottom,'string'));

handles = DrawTemplate(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_FromBottom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FromBottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_Saveas.
function push_Saveas_Callback(hObject, eventdata, handles)
% hObject    handle to push_Saveas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Template title'},'Title',1,{''});
if isempty(answer)
    return
end

handles = SaveTemplateFile(handles,answer{1});

guidata(hObject, handles);


% --- Executes on button press in push_Ok.
function push_Ok_Callback(hObject, eventdata, handles)
% hObject    handle to push_Ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.template,'userdata',handles.CurrentTemplate);

delete(gcf)


% --- Executes on button press in push_Cancel.
function push_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to push_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(gcf);


% --- Executes on button press in push_Add.
function push_Add_Callback(hObject, eventdata, handles)
% hObject    handle to push_Add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


totnum = length(handles.CurrentTemplate.Plot);
fld = fieldnames(handles.CurrentTemplate);
for c = 1:length(fld)
    cfield = eval(['handles.CurrentTemplate.' fld{c}]);
    cfield(handles.Index+1:totnum+1) = cfield(handles.Index:totnum);
    eval(['handles.CurrentTemplate.' fld{c} '=cfield;']);
end

handles.Index = handles.Index+1;

handles = DrawTemplate(handles);

guidata(hObject, handles);


% --- Executes on button press in push_Delete.
function push_Delete_Callback(hObject, eventdata, handles)
% hObject    handle to push_Delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if length(handles.CurrentTemplate.Plot)==1
    return
end

fld = fieldnames(handles.CurrentTemplate);
for c = 1:length(fld)
    cfield = eval(['handles.CurrentTemplate.' fld{c}]);
    cfield(handles.Index) = [];
    eval(['handles.CurrentTemplate.' fld{c} '=cfield;']);
end

if handles.Index > length(handles.CurrentTemplate.Plot)
    handles.Index = length(handles.CurrentTemplate.Plot);
end

handles = DrawTemplate(handles);

guidata(hObject, handles);


% --- Executes on button press in push_Up.
function push_Up_Callback(hObject, eventdata, handles)
% hObject    handle to push_Up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Index == 1
    return
end

handles = SwitchObjects(handles,[handles.Index handles.Index-1]);
handles.Index = handles.Index - 1;

handles = DrawTemplate(handles);

guidata(hObject, handles);


% --- Executes on button press in push_Down.
function push_Down_Callback(hObject, eventdata, handles)
% hObject    handle to push_Down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.Index == length(handles.CurrentTemplate.Plot)
    return
end

handles = SwitchObjects(handles,[handles.Index handles.Index+1]);
handles.Index = handles.Index + 1;

handles = DrawTemplate(handles);

guidata(hObject, handles);


function handles = SwitchObjects(handles,sw)

fld = fieldnames(handles.CurrentTemplate);
for c = 1:length(fld)
    cfield = eval(['handles.CurrentTemplate.' fld{c}]);
    cfield(sw) = cfield(fliplr(sw));
    eval(['handles.CurrentTemplate.' fld{c} '=cfield;']);
end


% --- Executes on button press in push_Next.
function push_Next_Callback(hObject, eventdata, handles)
% hObject    handle to push_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Index = handles.Index + 1;
if handles.Index > length(handles.CurrentTemplate.Plot)
    handles.Index = length(handles.CurrentTemplate.Plot);
end

handles = SelectObject(handles);

guidata(hObject, handles);


% --- Executes on button press in push_Prev.
function push_Prev_Callback(hObject, eventdata, handles)
% hObject    handle to push_Prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Index = handles.Index - 1;
if handles.Index == 0
    handles.Index = 1;
end

handles = SelectObject(handles);

guidata(hObject, handles);


% --- Executes on button press in check_AutoLimits.
function check_AutoLimits_Callback(hObject, eventdata, handles)
% hObject    handle to check_AutoLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_AutoLimits

handles.CurrentTemplate.AutoYLimits(handles.Index) = get(handles.check_AutoLimits,'value');

guidata(hObject, handles);


% --- Executes on button press in push_delete.
function push_delete_Callback(hObject, eventdata, handles)
% hObject    handle to push_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if length(get(handles.list_saved,'string'))==1
    return
end
val = get(handles.list_saved,'value');
if val==1
    return
end
button = questdlg(['Delete ' handles.TemplateTitles{val-1} '?'],'Delete','Yes','No','No');
if strcmp(button,'No')
    return
end

delete(['egt_' handles.TemplateTitles{val-1} '.m']);

handles.TemplateTitles(val-1) = [];
handles.Templates(val-1) = [];

if val-1 > length(handles.Templates)
    set(handles.list_saved,'value',val-1);
end
set(handles.list_saved,'string',['(Current ElectroGui template)' handles.TemplateTitles]);

guidata(hObject, handles);


% --- Executes on selection change in list_saved.
function list_saved_Callback(hObject, eventdata, handles)
% hObject    handle to list_saved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_saved contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_saved

val = get(handles.list_saved,'value');
if val == 1
    handles.CurrentTemplate = get(handles.template,'userdata');
else
    handles.CurrentTemplate = handles.Templates{val-1};
end

handles.Index = 1;

handles = DrawTemplate(handles);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function list_saved_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_saved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_Save.
function push_Save_Callback(hObject, eventdata, handles)
% hObject    handle to push_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.list_saved,'value');
if val == 1
    answer = inputdlg({'Template title'},'Title',1,{''});
    if isempty(answer)
        return
    end
    name = answer{1};
else
    name = handles.TemplateTitles{val-1};
end
   
handles = SaveTemplateFile(handles,name);

guidata(hObject, handles);


function handles = SaveTemplateFile(handles,name)

f = findstr(name,' ');
name(f) = '_';
name = ['egt_' name '.m'];

if ~isempty(dir(name))
    button = questdlg(['Overwrite ' name(5:end-2) '?'],'Overwrite template','Yes','No','No');
    if ~strcmp(button,'Yes')
        return
    end
end
    
    
fid = fopen(name,'w');

fprintf(fid,['function template = ' name(1:end-2) '\n']);
fprintf(fid,'%% ElectroGui figure template\n\n');

fprintf(fid,'template.Plot = {');
for c = 1:length(handles.CurrentTemplate.Plot)
    fprintf(fid,['''' handles.CurrentTemplate.Plot{c} ''' ']);
end
fprintf(fid,'};\n');

fprintf(fid,['template.Height = [' num2str(handles.CurrentTemplate.Height) '];\n']);
fprintf(fid,['template.Interval = [' num2str(handles.CurrentTemplate.Interval) '];\n']);
fprintf(fid,['template.YScaleType = [' num2str(handles.CurrentTemplate.YScaleType) '];\n']);
fprintf(fid,['template.AutoYLimits = [' num2str(handles.CurrentTemplate.AutoYLimits) '];\n']);

fclose(fid);

mt = dir('egt_*.m');
bck_titles = handles.TemplateTitles;
bck_templates = handles.Templates;
handles.TemplateTitles = {};
handles.Templates = {};
for c = 1:length(mt)
    for d = 1:length(bck_titles)
        if strcmp(mt(c).name(5:end-2),bck_titles{d})
            handles.TemplateTitles{c} = bck_titles{d};
            handles.Templates{c} = bck_templates{d};
        end
    end
    if strcmp(mt(c).name,name)
        handles.TemplateTitles{c} = name(5:end-2);
        handles.Templates{c} = handles.CurrentTemplate;
        indx = c;
    end
end
            
str = ['(Current ElectroGui template)',handles.TemplateTitles];
set(handles.list_saved,'string',str,'value',indx+1);



function ClickRadio(hObject, eventdata, handles)

str = get(hObject,'Tag');
handles.CurrentTemplate.YScaleType(handles.Index) = str2num(str(end));
guidata(hObject, handles);