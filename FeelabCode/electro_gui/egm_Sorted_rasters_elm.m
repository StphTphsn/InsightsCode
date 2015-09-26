

function varargout = egm_Sorted_rasters(varargin)
% EGM_SORTED_RASTERS M-file for egm_Sorted_rasters.fig
%      EGM_SORTED_RASTERS, by itself, creates a new EGM_SORTED_RASTERS or raises the existing
%      singleton*.
%
%      H = EGM_SORTED_RASTERS returns the handle to a new EGM_SORTED_RASTERS or the handle to
%      the existing singleton*.
%
%      EGM_SORTED_RASTERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EGM_SORTED_RASTERS.M with the given input arguments.
%
%      EGM_SORTED_RASTERS('Property','Value',...) creates a new EGM_SORTED_RASTERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before egm_Sorted_rasters_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to egm_Sorted_rasters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%      This function is a duplicate of egm_Sorted_rasters_elm.m with
%      default options setup for Emily. Perhaps we should figure out some
%      way to use an ini file for defaults to avoid code clutter?
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help egm_Sorted_rasters

% Last Modified by GUIDE v2.5 01-Oct-2009 20:34:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @egm_Sorted_rasters_OpeningFcn, ...
                   'gui_OutputFcn',  @egm_Sorted_rasters_OutputFcn, ...
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


% --- Executes just before egm_Sorted_rasters is made visible.
function egm_Sorted_rasters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to egm_Sorted_rasters (see VARARGIN)

set(handles.fig_Main,'position',[.025 .05 .95 .9]);

set(handles.popup_HistUnits,'position',get(handles.popup_PSTHUnits,'position'));
set(handles.popup_HistCount,'position',get(handles.popup_PSTHCount,'position'));
    
handles.BackupHandles = [];

if length(varargin)==1
    % Copy ElectroGui handles
    handles.egh = varargin{1};
    handles.BackupHandles = handles.egh;

    handles.egh.overlaptolerance = 0.0001;
    handles.egh = Fix_Overlap(handles.egh);
    
    
    handles.FileRange = 1:handles.egh.TotalFileNumber;
    
    set(handles.push_GenerateRaster,'enable','on');
    set(handles.push_FileRange,'enable','on');

    % Get event list
    str = {'Sound'};
    for c = 1:length(handles.egh.EventSources)
        str{end+1} = [handles.egh.EventDetectors{c} ' - ' handles.egh.EventSources{c} ' - ' handles.egh.EventFunctions{c}];
    end
    set(handles.popup_TriggerSource,'string',str);
    
    str_corr = {'(None)'};
    
    if get(handles.egh.popup_Channel1,'value')>1
        lst = get(handles.egh.popup_Channel1,'string');
        strs = lst{get(handles.egh.popup_Channel1,'value')};
        lst = get(handles.egh.popup_Function1,'string');
        strf = lst{get(handles.egh.popup_Function1,'value')};
        str{end+1} = [strf ' - ' strs];
        str_corr{end+1} = [strf ' - ' strs];
    end
    if get(handles.egh.popup_Channel2,'value')>1
        lst = get(handles.egh.popup_Channel2,'string');
        strs = lst{get(handles.egh.popup_Channel2,'value')};
        lst = get(handles.egh.popup_Function2,'string');
        strf = lst{get(handles.egh.popup_Function2,'value')};
        str{end+1} = [strf ' - ' strs];
        str_corr{end+1} = [strf ' - ' strs];
    end
    
    set(handles.popup_EventSource,'string',str);
    
    set(handles.popup_Correlation,'string',str_corr);
    
    % Get file list
    str = get(handles.egh.list_Files,'string');
    for c = 1:length(str)
        str{c} = str{c}(26:end-14);
    end
    handles.FileNames = str;

    set(handles.popup_Files,'string',{'All files in range','Only selected by search','Only unselected'});
else
    handles.egh = [];
    set(handles.popup_TriggerSource,'string',{'Sound'});
    set(handles.popup_EventSource,'string',{'Sound'});
    set(handles.popup_Correlation,'string',{'(None)'});
end

set(handles.list_WarpPoints,'string',{'(None)'});
handles.WarpPoints = {};

set(handles.popup_EventList,'string',{'(None)'});

colmaps = {'Default','HSV','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','Lines'};
for c = 1:length(colmaps)
    uimenu(handles.menu_Colormap,'label',colmaps{c},'callback',['colormap ' colmaps{c}]);
end

handles.SkippingSort = 0;

% Axis position
handles.AxisPosRaster = get(handles.axes_Raster,'position');
handles.AxisPosPSTH = get(handles.axes_PSTH,'position');
handles.AxisPosHist = get(handles.axes_Hist,'position');

handles.HistShow = [1 1];

% Events
handles.AllEventOnsets = {};
handles.AllEventOffsets = {};
handles.AllEventLabels = {};
handles.AllSelections = {};
handles.AllEventOptions = {};
handles.AllEventPlots = zeros(0,5);

% DEFAULT VALUES - feel free to edit

handles.P.trig.includeSyllList = '';
handles.P.trig.ignoreSyllList = '';
handles.P.trig.motifSequences = {};
handles.P.trig.motifInterval = 0.2;
handles.P.trig.boutInterval = 2;%0.5;
handles.P.trig.boutMinDuration = 0.2;
handles.P.trig.boutMinSyllables = 2;
handles.P.trig.burstFrequency = 100;
handles.P.trig.burstMinSpikes = 2;
handles.P.trig.pauseMinDuration = 0.05; 
handles.P.trig.contSmooth = 1;
handles.P.trig.contSubsample = 0.001;

handles.P.event = handles.P.trig; % duplicate options

handles.P.preStartRef = .2;
handles.P.postStopRef = .3;

handles.P.filter = repmat([-inf inf],length(get(handles.list_Filter,'string')),1);

handles.PlotHandles = cell(1,30);
for c = 10:12
    handles.PlotHandles{c} = {[]};
end
handles.PlotInclude = [0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 0 1 1 0 0 0 0 0 0 0 0 0 0];
handles.PlotContinuous = [1 1 -1 1 1 -1 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 -1 -1 1 1 -1 1 1 -1 -1 -1 -1];
handles.PlotColor = [1 0 0; 1 0 0; 1 1/2 1/8; 1 0 0; 1 0 0; 1 1/2 1/8; 1 0 0; 1 0 0; 1 1/2 1/8; ...
    0 0 0; 0 0 0; 230/255 230/255 128/255; ...
    0 0 0; 128/255 128/255 128/255; 1 0 0; 0 0 0; 128/255 128/255 128/255; 1 1 1; ...
    0 1 0; 0 1 0; 1 1 1; ...
    .75 0 .75; .75 0 .75; 1 .85 .85; ...
    0 0 1; 0 0 1; .8 .8 1; 0 0 1; 0 0 1; .8 .8 1;];
handles.PlotLineWidth = ones(1,30);
handles.PlotAlpha = ones(1,30);
handles.PlotAlpha(27) = 0.5;
handles.PlotAlpha(30) = 0.5;

handles.PlotAutoColors = [];

handles.PlotXLim = [-0.15 0.15];
handles.PlotTickSize = [1 0.25 0.01 0.5];
handles.PlotOverlap = 50;
handles.PlotInPerSec = 0.04;

handles.BackgroundColor = [1 1 1];

handles.PSTHBinSize = 0.005;
handles.PSTHSmoothingWindow = 1;
handles.PSTHYLim = [0 50; 0 100; 0 0.05; 0 1; 0 1];

handles.HistBinSize = [20 5];
handles.HistSmoothingWindow = 1;
handles.HistYLim = [0 50; 0 100; 0 20; 0 1; 0 1];
handles.ROILim = [-inf inf];

handles.ExportResolution = 300;
handles.ExportWidth = [6 20];
handles.ExportHeight = [4 0.01 0.04];
handles.ExportPSTHHeight = 2;
handles.ExportHistHeight = 2;
handles.ExportInterval = 0.25;

handles.corrMax = 0.1;

handles.WarpIntervalLim = [-1 1]; % Range of intervals whose durations have been specified. Intervals outside this range are assigned mean duration.
handles.WarpIntervalType = [1 1];
handles.WarpIntervalDuration = [.1 .1]; % Only meaningful for custom interval type
handles.WarpNumBefore = 1;
handles.WarpNumAfter = 1;


% Choose default command line output for egm_Sorted_rasters
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes egm_Sorted_rasters wait for user response (see UIRESUME)
% uiwait(handles.fig_Main);


% --- Outputs from this function are returned to the command line.
function varargout = egm_Sorted_rasters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.BackupHandles;


% --- Executes on selection change in popup_TriggerSource.
function popup_TriggerSource_Callback(hObject, eventdata, handles)
% hObject    handle to popup_TriggerSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_TriggerSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_TriggerSource

set(handles.popup_TriggerType,'value',1);
if get(handles.popup_TriggerSource,'value') == 1
    set(handles.popup_TriggerType,'string',{'Motifs','Syllables','Bouts'});
else
    set(handles.popup_TriggerType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popup_TriggerSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_TriggerSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_TriggerType.
function popup_TriggerType_Callback(hObject, eventdata, handles)
% hObject    handle to popup_TriggerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_TriggerType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_TriggerType


% --- Executes during object creation, after setting all properties.
function popup_TriggerType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_TriggerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_TriggerOptions.
function push_TriggerOptions_Callback(hObject, eventdata, handles)
% hObject    handle to push_TriggerOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.P.trig = edit_Options(handles.P.trig,handles.popup_TriggerType);

if get(handles.check_CopyTrigger,'value') == 1
    handles.P.event = handles.P.trig;
end

guidata(hObject, handles);


% --- Executes on selection change in popup_EventSource.
function popup_EventSource_Callback(hObject, eventdata, handles)
% hObject    handle to popup_EventSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_EventSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventSource

set(handles.popup_EventType,'value',1);
set(handles.popup_PSTHUnits,'value',1);
if get(handles.popup_EventSource,'value') == 1
    set(handles.popup_EventType,'string',{'Syllables','Motifs','Bouts'});
    set(handles.popup_EventType,'enable','on');
    set(handles.popup_PSTHUnits,'string',{'Rate (Hz)','Count per trial','Total count'});
    set(handles.popup_HistUnits,'string',{'Rate (Hz)','Count per trial','Total count','Fraction of time','Time per trial (sec)','Total time (sec)'});
    set(handles.popup_PSTHCount,'string',{'Onsets','Offsets','Full duration'});
    set(handles.popup_HistCount,'string',{'Onsets','Offsets','Events, including partial','Events, excluding partial'});
elseif get(handles.popup_EventSource,'value')-1 <= length(handles.egh.EventTimes)
    set(handles.popup_EventType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
    set(handles.popup_EventType,'enable','on');
    set(handles.popup_PSTHUnits,'string',{'Rate (Hz)','Count per trial','Total count'});
    set(handles.popup_HistUnits,'string',{'Rate (Hz)','Count per trial','Total count','Fraction of time','Time per trial (sec)','Total time (sec)'});
    set(handles.popup_PSTHCount,'string',{'Onsets','Offsets','Full duration'});
    set(handles.popup_HistCount,'string',{'Onsets','Offsets','Events, including partial','Events, excluding partial'});    
else
    set(handles.popup_EventType,'string',{'Continuous function'});
    set(handles.popup_EventType,'enable','off');
    set(handles.popup_PSTHUnits,'string',{'Average'});
    set(handles.popup_HistUnits,'string',{'Average'});
    set(handles.popup_PSTHCount,'string',{'All time points'});
    set(handles.popup_HistCount,'string',{'All time points'});
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popup_EventSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_EventSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_EventType.
function popup_EventType_Callback(hObject, eventdata, handles)
% hObject    handle to popup_EventType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_EventType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventType


% --- Executes during object creation, after setting all properties.
function popup_EventType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_EventType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_EventOptions.
function push_EventOptions_Callback(hObject, eventdata, handles)
% hObject    handle to push_EventOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.P.event = edit_Options(handles.P.event,handles.popup_EventType);

if get(handles.check_CopyEvents,'value') == 1
    handles.P.trig = handles.P.event;
end

guidata(hObject, handles);


% --- Executes on selection change in popup_StartReference.
function popup_StartReference_Callback(hObject, eventdata, handles)
% hObject    handle to popup_StartReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_StartReference contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_StartReference


% --- Executes during object creation, after setting all properties.
function popup_StartReference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_StartReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_StopReference.
function popup_StopReference_Callback(hObject, eventdata, handles)
% hObject    handle to popup_StopReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_StopReference contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_StopReference


% --- Executes during object creation, after setting all properties.
function popup_StopReference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_StopReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_WindowLimits.
function push_WindowLimits_Callback(hObject, eventdata, handles)
% hObject    handle to push_WindowLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Start prior to reference (sec)','Stop after reference (sec)'},'Window limits',1,{num2str(handles.P.preStartRef),num2str(handles.P.postStopRef)});
if isempty(answer)
    return
end
bckPre = handles.P.preStartRef;
bckPost = handles.P.postStopRef;
handles.P.preStartRef = str2num(answer{1});
handles.P.postStopRef = str2num(answer{2});

guidata(hObject, handles);


% --- Executes on button press in push_FileRange.
function push_FileRange_Callback(hObject, eventdata, handles)
% hObject    handle to push_FileRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = handles.FileNames;
for c = 1:length(str)
    str{c} = [num2str(c) '. ' str{c}];
end
[indx,ok] = listdlg('ListString',str,'InitialValue',handles.FileRange,'ListSize',[300 450],'Name','Select files','PromptString','Select file range');
if ok == 0
    return
end

handles.FileRange = indx;

guidata(hObject, handles);


% --- Executes on selection change in popup_PrimarySort.
function popup_PrimarySort_Callback(hObject, eventdata, handles)
% hObject    handle to popup_PrimarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_PrimarySort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_PrimarySort

handles = AutoInclude(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popup_PrimarySort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_PrimarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_SecondarySort.
function popup_SecondarySort_Callback(hObject, eventdata, handles)
% hObject    handle to popup_SecondarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_SecondarySort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_SecondarySort

handles = AutoInclude(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popup_SecondarySort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_SecondarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_PrimaryDescending.
function check_PrimaryDescending_Callback(hObject, eventdata, handles)
% hObject    handle to check_PrimaryDescending (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_PrimaryDescending


% --- Executes on button press in check_SecondaryDescending.
function check_SecondaryDescending_Callback(hObject, eventdata, handles)
% hObject    handle to check_SecondaryDescending (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_SecondaryDescending


% --- Executes on button press in check_CopyEvents.
function check_CopyEvents_Callback(hObject, eventdata, handles)
% hObject    handle to check_CopyEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_CopyEvents

if get(handles.check_CopyEvents,'value') == 1
    handles.P.trig = handles.P.event;
end

guidata(hObject, handles);

% --- Executes on button press in check_CopyTrigger.
function check_CopyTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to check_CopyTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_CopyTrigger


if get(handles.check_CopyTrigger,'value') == 1
    handles.P.event = handles.P.trig;
end

guidata(hObject, handles);



function opt = edit_Options(opt,obj);
% Edit trigger or event options

switch get(obj,'tag')
    case 'popup_TriggerType'
        label = 'Trigger options';
    case 'popup_EventType'
        label = 'Event options';
end

str = get(obj,'string');
val = get(obj,'value');

switch str{val}
    case 'Syllables'
        indx = 1:2;
    case 'Motifs'
        indx = 3:4;
    case 'Bouts'
        indx = [1:2 5:7];
    case 'Events'
        errordlg('Events do not require options!','Error');
        return
    case {'Bursts','Burst events','Single events'}
        indx = 8:9;
    case 'Pauses'
        indx = 10;
    case 'Continuous function';
        indx = 11:12;
end

query = {'List of included syllables ('''' for unlabeled). Leave empty to include all.','List of excluded syllables',...
    'Sequences of syllable labels to consider motifs','Maximum syllable separation (sec)','Maximum bout interval (sec)',...
    'Minimum bout duration (sec)','Minimum number of syllables in a bout','Minimum burst frequency (Hz)',...
    'Minimum number of events in a burst','Minimum pause duration (sec)','Smooth window (# points)','Subsample (sec)'};
motseq = '{';
for c = 1:length(opt.motifSequences)
    if c > 1
        motseq = [motseq ', '];
    end
    motseq = [motseq '''' opt.motifSequences{c} ''''];
end
motseq = [motseq '}'];
def = {opt.includeSyllList,opt.ignoreSyllList,motseq,num2str(opt.motifInterval),num2str(opt.boutInterval),num2str(opt.boutMinDuration),...
    num2str(opt.boutMinSyllables),num2str(opt.burstFrequency),num2str(opt.burstMinSpikes),num2str(opt.pauseMinDuration), ...
    num2str(opt.contSmooth),num2str(opt.contSubsample)};

answer = inputdlg(query(indx),label,1,def(indx));
if isempty(answer)
    return
end

switch str{val}
    case 'Syllables'
        opt.includeSyllList = answer{1};
        opt.ignoreSyllList = answer{2};
    case 'Motifs'
        opt.motifSequences = eval(answer{1}); %%% Tatsuo
        %opt.motifSequences = answer{1};
        opt.motifInterval = str2num(answer{2});
    case 'Bouts'
        opt.includeSyllList = answer{1};
        opt.ignoreSyllList = answer{2};
        opt.boutInterval = str2num(answer{3});
        opt.boutMinDuration = str2num(answer{4});
        opt.boutMinSyllables = str2num(answer{5});
    case 'Events'
        errordlg('Events do not require options!','Error');
        return
    case {'Bursts','Burst events','Single events'}
        opt.burstFrequency= str2num(answer{1});
        opt.burstMinSpikes = str2num(answer{2});
    case 'Pauses'
        opt.pauseMinDuration  = str2num(answer{1});
    case 'Continuous function'
        opt.contSmooth = str2num(answer{1});
        opt.contSubsample = str2num(answer{2});
end


% --- Executes on selection change in popup_Files.
function popup_Files_Callback(hObject, eventdata, handles)
% hObject    handle to popup_Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Files


% --- Executes during object creation, after setting all properties.
function popup_Files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
% --- Executes on button press in push_GenerateRaster.
function push_GenerateRaster_Callback(hObject, eventdata, handles)
% hObject    handle to push_GenerateRaster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_GenerateRaster,'foregroundcolor','r'); % change the color of the button
drawnow;

% Get trigger times
str = get(handles.popup_TriggerType,'string');
val = get(handles.popup_TriggerType,'value');
indx = get(handles.popup_TriggerSource,'value')-1;
[trig.on trig.off trig.info handles.FileList] = GetEventStructure(handles,indx,str{val},handles.P.trig);

% Get event times
str = get(handles.popup_EventType,'string');
val = get(handles.popup_EventType,'value');
indx = get(handles.popup_EventSource,'value')-1;
[event.on event.off event.info handles.FileList] = GetEventStructure(handles,indx,str{val},handles.P.event);

% Get warp point times
warp_points = cell(1,length(trig.on));
for c = 1:length(handles.WarpPoints)
    [ons offs info handles.FileList] = GetEventStructure(handles,handles.WarpPoints{c}.source,handles.WarpPoints{c}.type,handles.WarpPoints{c}.P);
    for d = 1:length(ons)
        switch handles.WarpPoints{c}.alignment
            case 'Onset'
                warp_points{d} = [warp_points{d}; ons{d}];
            case 'Offset'
                warp_points{d} = [warp_points{d}; offs{d}];
            case 'Midpoint'
                warp_points{d} = [warp_points{d}; (ons{d}+offs{d})/2];
        end
    end
end
for c = 1:length(warp_points)
    warp_points{c} = unique(handles.egh.DatesAndTimes(trig.info.filenum(c)) + warp_points{c}/(handles.egh.fs*24*60*60));
end

% Align events to triggers
if get(handles.check_HoldOn,'value')==0
    handles.EventFilters = [];
    str = get(handles.popup_EventType,'string');
    ev_str = str{get(handles.popup_EventType,'value')};
    str = get(handles.popup_EventSource,'string');
    ev_str = ['[' ev_str '] ' str{get(handles.popup_EventSource,'value')}];
    handles.filteredEvents.name = ev_str;
    handles.filteredEvents.options = handles.P.event;
end
[triggerInfo handles.EventFilters] = GetTriggerAlignedEvents(handles,trig,event,warp_points,handles.EventFilters);

% Error if there are no triggers
if isempty(triggerInfo)
    errordlg('No triggers found!','Error');
    set(handles.push_GenerateRaster,'foregroundcolor','k');
    return
end

% Align warp points to triggers
keepi = 1:length(triggerInfo.absTime);
warpTimes = zeros(length(triggerInfo.absTime),handles.WarpNumBefore+handles.WarpNumAfter+1);
if ~isempty(handles.WarpPoints)
    for c = 1:length(triggerInfo.absTime)
        filenum = triggerInfo.fileNum(c);
        f = find(warp_points{filenum}<triggerInfo.absTime(c));
        g = find(warp_points{filenum}>triggerInfo.absTime(c));
        if length(f) >= handles.WarpNumBefore & length(g) >= handles.WarpNumAfter
            warpTimes(c,:) = [warp_points{filenum}(f(end-handles.WarpNumBefore+1:end))' triggerInfo.absTime(c) warp_points{filenum}(g(1:handles.WarpNumAfter))'];
            warpTimes(c,:) = (warpTimes(c,:) - triggerInfo.absTime(c))*(24*60*60);
        else
            keepi(find(keepi==c)) = [];
        end
    end
    warpTimes = warpTimes(keepi,:);
end

% Keep only triggers with enough warp points
fields = fieldnames(triggerInfo);
for c = 1:length(fields)
    if ~strcmp(fields{c},'contLabel')
        fld = getfield(triggerInfo,fields{c});
        fld = fld(keepi);
        triggerInfo = setfield(triggerInfo,fields{c},fld);
    end
end

% Error if there are no triggers
if isempty(triggerInfo.absTime)
    errordlg('No triggers with requested parameters found!','Error');
    set(handles.push_GenerateRaster,'foregroundcolor','k');
    return
end


if get(handles.check_SkipSorting,'value')==1
    set(handles.push_GenerateRaster,'foregroundcolor','k');
    handles.SkippingSort = 1;
    cla(handles.axes_Raster);
    cla(handles.axes_PSTH);
    cla(handles.axes_Hist);
    subplot(handles.axes_Raster);
    tx = text(0,0,'Triggers extracted and filtered. Hold on to add events, sort, and plot.');
    set(tx,'HorizontalAlignment','Center','Color','r','Fontweight','bold');
    xlim([-1 1]);
    ylim([-1 1]);
    guidata(hObject, handles);
    return
end


% Sort triggers
if get(handles.check_HoldOn,'value')==0 | handles.SkippingSort == 1
    str = get(handles.popup_EventType,'string');
    ev_str = str{get(handles.popup_EventType,'value')};
    str = get(handles.popup_EventSource,'string');
    ev_str = ['[' ev_str '] ' str{get(handles.popup_EventSource,'value')}];
    handles.sortedEvents.name = ev_str;
    handles.sortedEvents.options = handles.P.event;
    
    handles.Order = 1:size(warpTimes,1);
    if get(handles.radio_YTrial,'value')==1
        str = get(handles.popup_SecondarySort,'string');
        [triggerInfo ord] = SortTriggers(triggerInfo,str{get(handles.popup_SecondarySort,'value')},get(handles.check_SecondaryDescending,'value'),handles.P.event.includeSyllList,0);
        warpTimes = warpTimes(ord,:);
        handles.Order = handles.Order(ord);
        str = get(handles.popup_PrimarySort,'string');
        [triggerInfo ord] = SortTriggers(triggerInfo,str{get(handles.popup_PrimarySort,'value')},get(handles.check_PrimaryDescending,'value'),handles.P.event.includeSyllList,get(handles.check_GroupLabels,'value'));
        warpTimes = warpTimes(ord,:);
        handles.Order = handles.Order(ord);
    else
        [triggerInfo ord] = SortTriggers(triggerInfo,'Absolute time',0,handles.P.event.includeSyllList,0);
        warpTimes = warpTimes(ord,:);
        handles.Order = handles.Order(ord);
    end
else
    ord = handles.Order;
    fields = fieldnames(triggerInfo);
    for c = 1:length(fields)
        if ~strcmp(fields{c},'contLabel')
            fld = getfield(triggerInfo,fields{c});
            fld = fld(ord);
            triggerInfo = setfield(triggerInfo,fields{c},fld);
        end
    end
    warpTimes = warpTimes(ord,:);
end

% Warp
if ~isempty(handles.WarpPoints)
    newwarp = zeros(1,size(warpTimes,2));
    cnt = handles.WarpNumBefore+1;
    for c = 1:handles.WarpNumBefore
        if -c < handles.WarpIntervalLim(1)
            tp = 1;
            dur = 0.1;
        else
            tp = handles.WarpIntervalType(-c-handles.WarpIntervalLim(1)+1);
            dur = handles.WarpIntervalDuration(-c-handles.WarpIntervalLim(1)+1);
        end
        switch tp
            case 1
                dur = mean(warpTimes(:,cnt-c+1)-warpTimes(:,cnt-c));
            case 2
                dur = median(warpTimes(:,cnt-c+1)-warpTimes(:,cnt-c));
            case 3
                dur = max(warpTimes(:,cnt-c+1)-warpTimes(:,cnt-c));
            case 4
                % dur = dur
        end
        newwarp(cnt-c) = newwarp(cnt-c+1)-dur;
    end
    for c = 1:handles.WarpNumAfter
        if c > handles.WarpIntervalLim(2)
            tp = 1;
            dur = 0.1;
        else
            tp = handles.WarpIntervalType(c-handles.WarpIntervalLim(1));
            dur = handles.WarpIntervalDuration(c-handles.WarpIntervalLim(1));
        end
        switch tp
            case 1
                dur = mean(warpTimes(:,cnt+c)-warpTimes(:,cnt+c-1));
            case 2
                dur = median(warpTimes(:,cnt+c)-warpTimes(:,cnt+c-1));
            case 3
                dur = max(warpTimes(:,cnt+c)-warpTimes(:,cnt+c-1));
            case 4
                % dur = dur
        end
        newwarp(cnt+c) = newwarp(cnt+c-1)+dur;
    end
        

    str = get(handles.popup_WarpingAlgorithm,'string');
    val = get(handles.popup_WarpingAlgorithm,'value');
    
    towarp = {'prevTrigOnset','prevTrigOffset','currTrigOnset','currTrigOffset','nextTrigOnset','nextTrigOffset','eventOnsets','eventOffsets','dataStart','dataStop'};
    stretch = zeros(size(warpTimes,1),size(warpTimes,2)-1);
    for w = 1:length(towarp)
        fld = getfield(triggerInfo,towarp{w});
        for c = 1:size(warpTimes,1)
            if iscell(fld)
                [fld{c} strt] = WarpTrial(fld{c},warpTimes(c,:),newwarp,str{val},handles.egh.fs,towarp{w});
            else
                [fld(c) strt] = WarpTrial(fld(c),warpTimes(c,:),newwarp,str{val},handles.egh.fs,towarp{w});
            end
            stretch(c,:) = strt;
        end
        triggerInfo = setfield(triggerInfo,towarp{w},fld);
    end
end

% if limits copy window, fix limits to the warp points or reference
if get(handles.check_CopyWindow,'value')==1
    if get(handles.popup_StartReference,'value')==6
        handles.PlotXLim(1) = newwarp(1)-handles.P.preStartRef;
    else
        handles.PlotXLim(1) = -handles.P.preStartRef;
    end
    if get(handles.popup_StopReference,'value')==6
        handles.PlotXLim(2) = newwarp(end)+handles.P.postStopRef;
    else
        handles.PlotXLim(2) = handles.P.postStopRef;
    end
end

  
if get(handles.check_HoldOn,'value')==0 | handles.SkippingSort == 1
    handles.TriggerSelection = ones(1,length(triggerInfo.absTime));
    handles.Selection(1,:) = [1 length(triggerInfo.absTime)];
    handles.Selection(2,:) = [min(triggerInfo.absTime) max(triggerInfo.absTime)];
    handles.Selection(3,:) = [min(triggerInfo.currTrigOffset-triggerInfo.currTrigOnset) max(triggerInfo.currTrigOffset-triggerInfo.currTrigOnset)];
    handles.Selection(4,:) = [min(triggerInfo.prevTrigOnset) max(triggerInfo.prevTrigOnset)];
    handles.Selection(5,:) = [min(triggerInfo.prevTrigOffset) max(triggerInfo.prevTrigOffset)];
    handles.Selection(6,:) = [min(triggerInfo.nextTrigOnset) max(triggerInfo.nextTrigOnset)];
    handles.Selection(7,:) = [min(triggerInfo.nextTrigOffset) max(triggerInfo.nextTrigOffset)];
    handles.Selection(8,:) = handles.FileRange([min(triggerInfo.fileNum) max(triggerInfo.fileNum)]);

    val = -inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOnsets{c}<0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOnsets{c}(f(end));
        end
    end
    handles.Selection(9,:) = [min(val) max(val)];

    val = -inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOffsets{c}<0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOffsets{c}(f(end));
        end
    end
    handles.Selection(10,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOnsets{c}>0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOnsets{c}(f(1));
        end
    end
    handles.Selection(11,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOffsets{c}>0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOffsets{c}(f(1));
        end
    end
    handles.Selection(12,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOnsets{c});
            val(c) = min(triggerInfo.eventOnsets{c});
        end
    end
    handles.Selection(13,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOffsets{c});
            val(c) = min(triggerInfo.eventOffsets{c});
        end
    end
    handles.Selection(14,:) = [min(val) max(val)];
    
    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOnsets{c});
            val(c) = max(triggerInfo.eventOnsets{c});
        end
    end
    handles.Selection(15,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOffsets{c});
            val(c) = max(triggerInfo.eventOffsets{c});
        end
    end
    handles.Selection(16,:) = [min(val) max(val)];
    
    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        val(c) = length(triggerInfo.eventOnsets{c});
    end
    handles.Selection(17,:) = [min(val) max(val)];
    
    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        val(c) = (length(find(triggerInfo.eventOnsets{c}<=0)) > length(find(triggerInfo.eventOffsets{c}<0)));
    end
    handles.Selection(18,:) = [min(val) max(val)];

    handles.LabelSelectionInc = '';
    handles.LabelSelectionExc = '';
    if min(triggerInfo.label) >= 1000
        handles.LabelRange = [min(triggerInfo.label) max(triggerInfo.label)]-1000;
    else
        handles.LabelRange = [];
    end

    set(handles.text_NumTriggers,'string',[num2str(length(triggerInfo.absTime)) ' triggers']);
else
    f = find(handles.TriggerSelection==0);
    triggerInfo.eventOnsets(f) = cell(1,length(f));
    triggerInfo.eventOffsets(f) = cell(1,length(f));
end

if ~isempty(handles.WarpPoints)
    triggerInfo.warpTimes = newwarp;
    triggerInfo.warpStretch = stretch;
else
    triggerInfo.warpTimes = 0;
    triggerInfo.warpStretch = [];
end


%% ======================
% PLOT
warning off
set(gcf,'renderer','opengl');

subplot(handles.axes_Raster);
hold on;

if get(handles.check_HoldOn,'value') == 0 | handles.SkippingSort == 1
    cla;
    handles.PlotHandles = cell(1,30);
    for c = 10:12
        handles.PlotHandles{c} = {[]};
    end
    event_indx = 1;
    handles.AllEventOnsets = {triggerInfo.eventOnsets};
    handles.AllEventOffsets = {triggerInfo.eventOffsets};
    handles.AllEventLabels = {triggerInfo.eventLabels};
    handles.AllEventSelections = {handles.TriggerSelection};
    handles.AllEventOptions = {handles.P.event};
    handles.AllEventPlots = [handles.PlotInclude(10:12) max(handles.PlotInclude(13:14)) max(handles.PlotInclude(16:18))];
    set(handles.popup_EventList,'value',1);
    set(handles.popup_EventList,'string',{'(None)'});
else
    for c = 10:12
        handles.PlotHandles{c}{end+1} = [];
    end
    handles.PlotHandles(13:18) = cell(1,6);
    handles.AllEventOnsets{end+1} = triggerInfo.eventOnsets;
    handles.AllEventOffsets{end+1} = triggerInfo.eventOffsets;
    handles.AllEventLabels{end+1} = triggerInfo.eventLabels;
    handles.AllEventSelections{end+1} = handles.TriggerSelection;
    handles.AllEventOptions{end+1} = handles.P.event;
    handles.AllEventPlots(end+1,:) = [handles.PlotInclude(10:12) max(handles.PlotInclude(13:14)) max(handles.PlotInclude(16:18))];
end
if handles.AllEventPlots(end,4)==1
    handles.AllEventPlots(1:end-1,4) = 0;
end
if handles.AllEventPlots(end,5)==1
    handles.AllEventPlots(1:end-1,5) = 0;
end
if handles.HistShow(1)==0
    handles.AllEventPlots(:,4) = 0;
end
if handles.HistShow(2)==0
    handles.AllEventPlots(:,5) = 0;
end
hold on;

str = get(handles.popup_EventType,'string');
ev_str = str{get(handles.popup_EventType,'value')};
str = get(handles.popup_EventSource,'string');
ev_str = ['[' ev_str '] ' str{get(handles.popup_EventSource,'value')}];
if ~isempty(findstr(ev_str,'Syllables'))
    if ~isempty(handles.P.event.includeSyllList)
        ev_str = [ev_str ' - Include ' handles.P.event.includeSyllList];
    end
    if ~isempty(handles.P.event.ignoreSyllList)
        ev_str = [ev_str ' - Ignore ' handles.P.event.ignoreSyllList];
    end
end
ev_str = [ev_str ' -'];
str = get(handles.popup_EventList,'string');
str{length(handles.AllEventOnsets)} = ev_str;

plt = {'On','Off','Box','PSTH','Vert'};
for c = 1:length(str)
    f = findstr(str{c},'-');
    str{c} = str{c}(1:f(end)-2);
    if sum(handles.AllEventPlots(c,:)) == 0
        str{c} = [str{c} ' - No plots'];
    else
        tas = ' - ';
        for d = find(handles.AllEventPlots(c,:)==1)
            tas = [tas plt{d} '+'];
        end
        str{c} = [str{c} tas(1:end-1)];
    end
end
    

set(handles.popup_EventList,'string',str);
set(handles.popup_EventList,'value',length(str));

if get(handles.radio_YTrial,'value')==1
    y1 = (1:length(triggerInfo.absTime));
else
    y1 = (triggerInfo.absTime-min(triggerInfo.absTime))*(24*60*60);
end
if length(y1)==1
    df = 1;
else
    df = mean(diff(y1));
end

if get(handles.radio_TickTrials,'value')==1
    y2 = [y1(handles.PlotTickSize(1)+1:end) y1(end)+(1:handles.PlotTickSize(1)).*repmat(df,1,handles.PlotTickSize(1))];
elseif get(handles.radio_TickSeconds,'value')==1
    y2 = y1 + handles.PlotTickSize(2);
elseif get(handles.radio_TickInches,'value')==1
    if get(handles.radio_YTrial,'value')==1
        y2 = y1 + 100/(100-handles.PlotOverlap);
    else
        y2 = y1 + handles.PlotTickSize(3)/handles.PlotInPerSec;
    end
elseif get(handles.radio_TickPercent,'value')==1
    p = handles.PlotTickSize(4)/100;
    y2 = y1 + p/(1-p)*(max(y1)-min(y1));
end

if strcmp(get(handles.popup_EventType,'enable'),'on')
    evx1 = cat(1,triggerInfo.eventOnsets{:});
    evx2 = cat(1,triggerInfo.eventOffsets{:});
    evy1 = zeros(size(evx1));
    evy2 = zeros(size(evx1)); % makes y's same length as onset x's
    indx2 = cumsum(cellfun('length',triggerInfo.eventOnsets));
    indx1 = [1 indx2(1:end-1)+1];
    for tNum = 1:length(indx1)
        evy1(indx1(tNum):indx2(tNum)) = y1(tNum);
        evy2(indx1(tNum):indx2(tNum)) = y2(tNum);
    end
end

ys = reshape(repmat((y1(2:end)+y2(1:end-1))/2,2,1),1,2*length(y1)-2);
ys = [y1(1) ys y2(end)];

handles.TrialYs = y1;

bck_inc = handles.PlotInclude;
if get(handles.check_HoldOn,'value')==1 & handles.SkippingSort==0
    handles.PlotInclude([1:9 19 21:end]) = 0;
end


% Trial boxes
if handles.PlotInclude(21)==1
    xcorr = [handles.PlotXLim(1) handles.PlotXLim(2) handles.PlotXLim(2) handles.PlotXLim(1)]';
    handles.PlotHandles{21} = patch(repmat(xcorr,1,length(y1)),[ys(1:2:end); ys(1:2:end); ys(2:2:end); ys(2:2:end)],ones(1,length(y1),3));
end

% Window boxes
if handles.PlotInclude(24)==1
    d1 = [];
    d2 = [];
    for c = 1:length(triggerInfo.dataStart)
        d1(c) = min(triggerInfo.dataStart{c});
        d2(c) = max(triggerInfo.dataStop{c});
    end
    handles.PlotHandles{24} = patch([d1; d2; d2; d1],[ys(1:2:end); ys(1:2:end); ys(2:2:end); ys(2:2:end)],ones(1,length(y1),3));
end

% Continuous function
if max(handles.PlotInclude(10:12))==1 & strcmp(get(handles.popup_EventType,'enable'),'off')
    for c = 1:length(triggerInfo.eventOnsets)
        for d = 1:length(triggerInfo.dataStart{c})
            f = find(triggerInfo.eventOnsets{c}>=triggerInfo.dataStart{c}(d) & triggerInfo.eventOnsets{c}<=triggerInfo.dataStop{c}(d));
            if length(f)>1
                xt = linspace(triggerInfo.dataStart{c}(d),triggerInfo.dataStop{c}(d),2*length(f)+1);
                if strcmp(get(handles.menu_LogScale,'checked'),'off')
                    imagesc(xt(2:2:end-1),[y1(c)+(y2(c)-y1(c))/3 y2(c)-(y2(c)-y1(c))/3],triggerInfo.eventLabels{c}(f));
                else
                    imagesc(xt(2:2:end-1),[y1(c)+(y2(c)-y1(c))/3 y2(c)-(y2(c)-y1(c))/3],log10(triggerInfo.eventLabels{c}(f)));
                end
            end
        end
    end
    if ~isfield(handles,'CLim')
        handles.CLim = get(handles.axes_Raster,'clim');
    end
    set(handles.axes_Raster,'clim',handles.CLim);
end

% Trigger boxes
if handles.PlotInclude(3)==1
    x1 = triggerInfo.prevTrigOnset;
    x2 = triggerInfo.prevTrigOffset;
    handles.PlotHandles{3} = patch([x1; x2; x2; x1],[y1; y1; y2; y2],ones(1,length(x1),3));
end
if handles.PlotInclude(6)==1
    x1 = triggerInfo.currTrigOnset;
    x2 = triggerInfo.currTrigOffset;
    handles.PlotHandles{6} = patch([x1; x2; x2; x1],[y1; y1; y2; y2],ones(1,length(x1),3));
end
if handles.PlotInclude(9)==1
    x1 = triggerInfo.nextTrigOnset;
    x2 = triggerInfo.nextTrigOffset;
    handles.PlotHandles{9} = patch([x1; x2; x2; x1],[y1; y1; y2; y2],ones(1,length(x1),3));
end

% Event boxes
if handles.PlotInclude(12)==1 & strcmp(get(handles.popup_EventType,'enable'),'on')
    handles.PlotHandles{12}{end} = patch([evx1 evx2 evx2 evx1]',[evy1 evy1 evy2 evy2]',ones(1,length(evx1),3));
end

% ROI boxes
if handles.PlotInclude(27)==1
    xcorr = [handles.PlotXLim(1) handles.PlotXLim(2) handles.PlotXLim(2) handles.PlotXLim(1)]';
    handles.PlotHandles{27} = patch(repmat(xcorr,1,length(y1)),[ys(1:2:end); ys(1:2:end); ys(2:2:end); ys(2:2:end)],ones(1,length(y1),3));
end

% Warp line ticks
if handles.PlotInclude(19)==1 & handles.PlotContinuous(19)<1 & ~isempty(handles.WarpPoints)
    for w = 1:size(warpTimes,2)
        handles.PlotHandles{19} = [handles.PlotHandles{19}; line(repmat(newwarp(w),2,length(y1)),[y1; y2])'];
    end
end

% Window start and stop ticks
if handles.PlotInclude(22)==1 & handles.PlotContinuous(22)<1
    d1 = [];
    for c = 1:length(triggerInfo.dataStart)
        d1(c) = min(triggerInfo.dataStart{c});
    end
    handles.PlotHandles{22} = line([d1; d1],[y1; y2])';
end
if handles.PlotInclude(23)==1 & handles.PlotContinuous(23)<1
    d2 = [];
    for c = 1:length(triggerInfo.dataStart)
        d2(c) = max(triggerInfo.dataStop{c});
    end
    handles.PlotHandles{23} = line([d2; d2],[y1; y2])';
end

% Trigger ticks
if handles.PlotInclude(1)==1 & handles.PlotContinuous(1)<1
    handles.PlotHandles{1} = line([triggerInfo.prevTrigOnset; triggerInfo.prevTrigOnset],[y1; y2])';
end
if handles.PlotInclude(2)==1 & handles.PlotContinuous(2)<1
    handles.PlotHandles{2} = line([triggerInfo.prevTrigOffset; triggerInfo.prevTrigOffset],[y1; y2])';
end
if handles.PlotInclude(4)==1 & handles.PlotContinuous(4)<1
    handles.PlotHandles{4} = line([triggerInfo.currTrigOnset; triggerInfo.currTrigOnset],[y1; y2])';
end
if handles.PlotInclude(5)==1 & handles.PlotContinuous(5)<1
    handles.PlotHandles{5} = line([triggerInfo.currTrigOffset; triggerInfo.currTrigOffset],[y1; y2])';
end
if handles.PlotInclude(7)==1 & handles.PlotContinuous(7)<1
    handles.PlotHandles{7} = line([triggerInfo.nextTrigOnset; triggerInfo.nextTrigOnset],[y1; y2])';
end
if handles.PlotInclude(8)==1 & handles.PlotContinuous(8)<1
    handles.PlotHandles{8} = line([triggerInfo.nextTrigOffset; triggerInfo.nextTrigOffset],[y1; y2])';
end

% ROI ticks
if handles.PlotInclude(25)==1 & handles.PlotContinuous(25)<1
    handles.PlotHandles{25} = line(repmat(handles.ROILim(1),2,length(y1)),[y1; y2])';
end
if handles.PlotInclude(26)==1 & handles.PlotContinuous(26)<1
    handles.PlotHandles{26} = line(repmat(handles.ROILim(2),2,length(y1)),[y1; y2])';
end

% Plot all event ticks
if handles.PlotInclude(10)==1 & strcmp(get(handles.popup_EventType,'enable'),'on')
    handles.PlotHandles{10}{end} = line([evx1 evx1]',[evy1 evy2]');
end
if handles.PlotInclude(11)==1 & strcmp(get(handles.popup_EventType,'enable'),'on')
    handles.PlotHandles{11}{end} = line([evx2 evx2]',[evy1 evy2]')';
end

%% Continuous window limits
if handles.PlotInclude(22)==1 & handles.PlotContinuous(22)==1
    d1 = [];
    for c = 1:length(triggerInfo.dataStart)
        d1(c) = min(triggerInfo.dataStart{c});
    end
    handles.PlotHandles{22} = plot(reshape(repmat(d1,2,1),1,2*length(d1)),ys);
end
if handles.PlotInclude(23)==1 & handles.PlotContinuous(23)==1
    d2 = [];
    for c = 1:length(triggerInfo.dataStart)
        d2(c) = max(triggerInfo.dataStop{c});
    end
    handles.PlotHandles{23} = plot(reshape(repmat(d2,2,1),1,2*length(d2)),ys);
end

%% Continuous warp lines
if handles.PlotInclude(19)==1 & handles.PlotContinuous(19)==1 & ~isempty(handles.WarpPoints)
    for w = 1:size(warpTimes,2)
        px = repmat(newwarp(w),1,length(y1));
        handles.PlotHandles{19} = [handles.PlotHandles{19}; plot(reshape(repmat(px,2,1),1,2*length(px)),ys)];
    end
end

% Plot continuous trigger lines
if handles.PlotInclude(1)==1 & handles.PlotContinuous(1)==1
    px = triggerInfo.prevTrigOnset;
    handles.PlotHandles{1} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(2)==1 & handles.PlotContinuous(2)==1
    px = triggerInfo.prevTrigOffset;
    handles.PlotHandles{2} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(4)==1 & handles.PlotContinuous(4)==1
    px = triggerInfo.currTrigOnset;
    handles.PlotHandles{4} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(5)==1 & handles.PlotContinuous(5)==1
    px = triggerInfo.currTrigOffset;
    handles.PlotHandles{5} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(7)==1 & handles.PlotContinuous(7)==1
    px = triggerInfo.nextTrigOnset;
    handles.PlotHandles{7} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(8)==1 & handles.PlotContinuous(8)==1
    px = triggerInfo.nextTrigOffset;
    handles.PlotHandles{8} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end


%% Plot continuous ROI lines
if handles.PlotInclude(25)==1 & handles.PlotContinuous(25)==1
    px = repmat(handles.ROILim(1),1,length(y1));
    handles.PlotHandles{25} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(26)==1 & handles.PlotContinuous(26)==1
    px = repmat(handles.ROILim(2),1,length(y1));
    handles.PlotHandles{26} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end


if get(handles.check_HoldOn,'value')==0 | handles.SkippingSort == 1
    ylim([min([y1(1) y2(1)]) max([y1(end) y2(end)])]);
    yl = ylim;

    if handles.HistShow(1) == 1
        h = handles.AxisPosRaster(4);
    else
        h = handles.AxisPosPSTH(4) + handles.AxisPosPSTH(2) - handles.AxisPosRaster(2);
    end
    if handles.HistShow(2) == 1
        w = handles.AxisPosRaster(3);
    else
        w = handles.AxisPosHist(3) + handles.AxisPosHist(1) - handles.AxisPosRaster(1);
    end
    pos = get(handles.axes_Raster,'position');
    pos(3) = w;
    pos(4) = h;
    set(handles.axes_Raster,'position',pos);

    if get(handles.radio_TickInches,'value')==1
        bck = get(handles.axes_Raster,'units');
        set(handles.axes_Raster,'units','inches');
        pos = get(handles.axes_Raster,'position');
        if get(handles.radio_YTrial,'value')==1
            hg = (100-handles.PlotOverlap)/100*handles.PlotTickSize(3)*range(yl);
        else
            hg = handles.PlotInPerSec*range(yl);
        end
        pos(4) = hg;
        set(handles.axes_Raster,'position',pos);
        set(handles.axes_Raster,'units',bck);
    end

    pos = get(handles.axes_Raster,'position');
    h = pos(4);
    pos = get(handles.axes_Hist,'position');
    pos(4) = h;
    set(handles.axes_Hist,'position',pos);


    if get(handles.check_CopyWindow,'value')==1 & get(handles.check_LockLimits,'value')==0
        yl_back = ylim;
        axis tight
        handles.PlotXLim = xlim;
        if get(handles.popup_StartReference,'value') == get(handles.popup_TriggerAlignment,'value')+2 | (~isempty(handles.WarpPoints) & get(handles.popup_StartReference,'value')==6)
            if get(handles.popup_StartReference,'value')==6
                handles.PlotXLim(1) = newwarp(1)-handles.P.preStartRef;
            else
                handles.PlotXLim(1) = -handles.P.preStartRef;
            end
        end
        if get(handles.popup_StopReference,'value') == get(handles.popup_TriggerAlignment,'value') | (~isempty(handles.WarpPoints) & get(handles.popup_StopReference,'value')==6)
            if get(handles.popup_StopReference,'value')==6
                handles.PlotXLim(2) = newwarp(end)+handles.P.postStopRef;
            else
                handles.PlotXLim(2) = handles.P.postStopRef;
            end
        end
        ylim(yl_back);
    end

if handles.PlotXLim(2) <= handles.PlotXLim(1)
    handles.PlotXLim = [-0.1 0.1];
    warndlg('Invalid time axis limits. Limits automatically set to [-0.1 0.1].','Warning');
end
    xlim([handles.PlotXLim(1)-eps handles.PlotXLim(2)]);
    box on;
    
    if handles.PlotInclude(21)==1
        xl = xlim;
        xcorr = [xl(1) xl(2) xl(2) xl(1)]';
        set(handles.PlotHandles{21},'xdata',repmat(xcorr,1,length(y1)));
    end
    
    if handles.PlotInclude(27)==1
        xl = xlim;
        xl(1) = max([handles.ROILim(1) xl(1)]);
        xl(2) = min([handles.ROILim(2) xl(2)]);
        xcorr = [xl(1) xl(2) xl(2) xl(1)]';
        set(handles.PlotHandles{27},'xdata',repmat(xcorr,1,length(y1)));
    end

    str = get(handles.popup_TriggerType,'string');
    str = str{get(handles.popup_TriggerType,'value')};
    if get(handles.radio_YTrial,'value')==1
        ylabel([str(1:end-1) ' number']);
    else
        ylabel([str(1:end-1) ' time (sec)']);
    end

    str2 = get(handles.popup_TriggerAlignment,'string');
    str2 = str2{get(handles.popup_TriggerAlignment,'value')};
    xlabel(['Time relative to ' lower(str(1:end-1)) ' ' lower(str2) ' (sec)']);
end


%% Plot PSTH
subplot(handles.axes_PSTH);
if get(handles.check_HoldOn,'value')==0 | handles.SkippingSort == 1
    cla;
end

if handles.HistShow(1)==1
    binsize = range(handles.PlotXLim)/ceil(range(handles.PlotXLim)/handles.PSTHBinSize);
    if handles.PlotInclude(13)==1 | handles.PlotInclude(14)==1
        cla;
        hold on;
        str = get(handles.popup_PSTHCount,'string');
        xs = handles.PlotXLim(1):binsize:handles.PlotXLim(2);

        str_unit = get(handles.popup_PSTHUnits,'string');
        str_unit = str_unit{get(handles.popup_PSTHUnits,'value')};

        counts = zeros(length(xs)-1,1);

        if strcmp(get(handles.popup_EventType,'enable'),'on')
            if isempty(handles.WarpPoints) | ~strcmp(str_unit,'Rate (Hz)')
                nindx1 = 1;
                nindx2 = length(evx1);
            else
                nindx1 = indx1;
                nindx2 = indx2;
            end
            cnt = zeros(length(xs)-1,1);
            for tNum = 1:length(nindx1)
                if nindx2(tNum)>=nindx1(tNum)
                    switch str{get(handles.popup_PSTHCount,'value')}
                        case 'Onsets'
                            cnt = histc(evx1(nindx1(tNum):nindx2(tNum)),xs);
                            cnt = cnt(1:end-1);
                        case 'Offsets'
                            cnt = histc(evx2(nindx1(tNum):nindx2(tNum)),xs);
                            cnt = cnt(1:end-1);
                        case 'Full duration'
                            for j = 1:length(xs)-1
                                cnt(j,1) = length(find(evx1(nindx1(tNum):nindx2(tNum))<xs(j+1) & evx2(nindx1(tNum):nindx2(tNum))>xs(j)));
                            end
                    end
                    if ~isempty(handles.WarpPoints) & strcmp(str_unit,'Rate (Hz)')
                        for j = 1:length(newwarp)-1
                            f = find((xs(1:end-1)+xs(2:end))/2>=newwarp(j) & (xs(1:end-1)+xs(2:end))/2<newwarp(j+1));
                            cnt(f) = cnt(f)*stretch(tNum,j);
                        end
                    end
                    if size(cnt,1)==size(counts,2)
                        cnt = cnt';
                    end
                    counts = counts + cnt;
                end
            end
        else
            for tNum = 1:length(triggerInfo.eventOnsets)
                for j = 1:length(xs)-1
                    f = find(triggerInfo.eventOnsets{tNum}<xs(j+1) & triggerInfo.eventOnsets{tNum}>xs(j));
                    if strcmp(get(handles.menu_LogScale,'checked'),'on')
                        counts(j) = counts(j) + log10(sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps)+eps);
                    else
                        counts(j) = counts(j) + sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps);
                    end
                end
            end
        end

        counts = smooth(counts,handles.PSTHSmoothingWindow);

        numtrials = zeros(length(xs)-1,1);
        for c = find(handles.TriggerSelection==1)
            for d = 1:length(triggerInfo.dataStart{c})
                numtrials = numtrials + (xs(2:end)>triggerInfo.dataStart{c}(d) & xs(1:end-1)<triggerInfo.dataStop{c}(d))';
            end
        end
        numtrials(find(numtrials==0)) = inf;

        switch str_unit
            case 'Rate (Hz)'
                counts = counts ./ numtrials / binsize;
            case 'Total count'
                % Do nothing
            case {'Count per trial','Average'}
                counts = counts ./ numtrials;
        end

        xs = handles.PlotXLim(1):binsize:handles.PlotXLim(2);
        if handles.PlotInclude(14)==1
            bx = [xs; xs];
            bx = reshape(bx,1,numel(bx));
            bc = [counts'; counts'];
            bc = reshape(bc,1,numel(bc));
            bc = [0 bc 0];
            handles.PlotHandles{14} = patch(bx,bc,'w');
        end
        if handles.PlotInclude(13)==1
            cnts = reshape(repmat(counts',2,1),2*length(counts),1);
            xcorr = reshape(repmat(xs,2,1),2*length(xs),1);
            xcorr = xcorr(2:end-1);
            handles.PlotHandles{13} = plot(xcorr,cnts);
        end

        if get(handles.radio_PSTHAuto,'value')==1
            axis tight
            yl = ylim;
            ylim([yl(1) yl(1)+(yl(2)-yl(1))*1.05]);
        else
            if strcmp(get(handles.popup_EventType,'enable'),'on')
                ylim(handles.PSTHYLim(get(handles.popup_PSTHUnits,'value'),:));
            else
                ylim(handles.PSTHYLim(get(handles.popup_PSTHUnits,'value')+3,:));
            end
        end

        if strcmp(get(handles.popup_EventType,'enable'),'off')
            if strcmp(get(handles.menu_LogScale,'checked'),'on')
                if length(triggerInfo.contLabel) > 1
                    triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
                end
                str_unit = [str_unit ' log'];
            end
            if length(triggerInfo.contLabel) > 1
                triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
            end
            str_unit = [str_unit ' ' triggerInfo.contLabel];
        end
        ylabel(str_unit);
    end

    if handles.PlotInclude(20)==1
        delete(handles.PlotHandles{20}(ishandle(handles.PlotHandles{20})));
        hold on
        if ~isempty(handles.WarpPoints)
            handles.PlotHandles{20} = line(repmat(newwarp,2,1),repmat(ylim',1,length(newwarp)));
        end
    end

    if handles.PlotInclude(15)==1
        delete(handles.PlotHandles{15}(ishandle(handles.PlotHandles{15})));
        hold on
        handles.PlotHandles{15} = plot([0 0],ylim);
    end
    
    if handles.PlotInclude(28)==1
        delete(handles.PlotHandles{28}(ishandle(handles.PlotHandles{28})));
        hold on
        handles.PlotHandles{28} = plot([handles.ROILim(1) handles.ROILim(1)],ylim);
    end
    if handles.PlotInclude(29)==1
        delete(handles.PlotHandles{29}(ishandle(handles.PlotHandles{29})));
        hold on
        handles.PlotHandles{29} = plot([handles.ROILim(2) handles.ROILim(2)],ylim);
    end
    if handles.PlotInclude(30)==1
        delete(handles.PlotHandles{30}(ishandle(handles.PlotHandles{30})));
        hold on
        xl = get(handles.axes_Raster,'xlim');
        xl(1) = max([handles.ROILim(1) xl(1)]);
        xl(2) = min([handles.ROILim(2) xl(2)]);
        handles.PlotHandles{30} = patch([xl(1) xl(2) xl(2) xl(1)],reshape([ylim; ylim],1,4),'w');
    end
    

    xlim([handles.PlotXLim(1)-eps handles.PlotXLim(2)]);
    set(gca,'xtick',[]);
end

%% Plot vertical histogram
subplot(handles.axes_Hist);
if get(handles.check_HoldOn,'value')==0 | handles.SkippingSort == 1
    cla;
end
if handles.HistShow(2)==1
    if handles.PlotInclude(16)==1 | handles.PlotInclude(17)==1 | handles.PlotInclude(18)==1
        cla;
        hold on;
    end
    if get(handles.radio_YTrial,'value')==1
        binsize = range([y1 y2])/ceil(range([y1 y2])/handles.HistBinSize(1));
    else
        binsize = range([y1 y2])/ceil(range([y1 y2])/handles.HistBinSize(2));
    end
    
    if handles.PlotInclude(18)==1
        bx = ys([1 2:2:end]);
        xl = xlim;
        handles.PlotHandles{18} = patch(repmat([xl(1) xl(2) xl(2) xl(1)]',1,length(bx)-1),[bx(1:end-1); bx(1:end-1); bx(2:end); bx(2:end)],ones(1,length(bx)-1,3));
    end
    
    if handles.PlotInclude(16)==1 | handles.PlotInclude(17)==1
        str = get(handles.popup_HistCount,'string');
        xs = min([y1 y2]):binsize:max([y1 y2]);

        str_unit = get(handles.popup_HistUnits,'string');
        str_unit = str_unit{get(handles.popup_HistUnits,'value')};

        counts = zeros(length(xs)-1,1);

        if strcmp(get(handles.popup_EventType,'enable'),'on')
            cnt = zeros(1,length(y1));
            for tNum = 1:length(cnt)
                f = indx1(tNum):indx2(tNum);
                switch str_unit
                    case {'Fraction of time','Time per trial (sec)','Total time (sec)'}
                        cnt(tNum) = 0;
                        if strcmp(str{get(handles.popup_HistCount,'value')},'Onsets') | strcmp(str{get(handles.popup_HistCount,'value')},'Offsets')
                            % do nothing
                        else
                            for j = 1:length(triggerInfo.dataStart{tNum})
                                g = find(evx1(f)>=triggerInfo.dataStart{tNum}(j) & evx1(f)<=triggerInfo.dataStop{tNum}(j));
                                g = intersect(g,find(evx2(f)>=triggerInfo.dataStart{tNum}(j) & evx2(f)<=triggerInfo.dataStop{tNum}(j)));
                                st = evx1(f(g));
                                en = evx2(f(g));
                                h1 = find(st<handles.ROILim(1));
                                st(h1) = handles.ROILim(1);
                                h2 = find(en>handles.ROILim(2));
                                en(h2) = handles.ROILim(2);
                                if strcmp(str{get(handles.popup_HistCount,'value')},'Events, excluding partial')
                                    st(intersect(h1,h2)) = [];
                                    en(intersect(h1,h2)) = [];
                                end
                                st(find(st<triggerInfo.dataStart{tNum}(j))) = triggerInfo.dataStart{tNum}(j);
                                en(find(st>triggerInfo.dataStop{tNum}(j))) = triggerInfo.dataStop{tNum}(j);
                                g = find(en>st);
                                st = st(g);
                                en = en(g);
                                toadd = sum(en-st);
                                if ~isempty(handles.WarpPoints)
                                    g = find((st+en)/2 >= newwarp(1:end-1) & (st+en)/2 <= newwarp(2:end));
                                    if ~isempty(g)
                                        toadd = toadd/stretch(tNum,g);
                                    end
                                end
                                cnt(tNum) = cnt(tNum) + toadd;
                            end
                        end
                    otherwise
                        switch str{get(handles.popup_HistCount,'value')}
                            case 'Onsets'
                                cnt(tNum) = length(find(evx1(f)>=handles.ROILim(1) & evx1(f)<=handles.ROILim(2)));
                            case 'Offsets'
                                cnt(tNum) = length(find(evx2(f)>=handles.ROILim(1) & evx2(f)<=handles.ROILim(2)));
                            case 'Events, including partial'
                                cnt(tNum) = length(f) - length(find((evx1(f)<handles.ROILim(1) & evx2(f)<handles.ROILim(1)) | (evx1(f)>handles.ROILim(2) & evx2(f)>handles.ROILim(2))));
                            case 'Events, excluding partial'
                                cnt(tNum) = length(find(evx1(f)>=handles.ROILim(1) & evx1(f)<=handles.ROILim(2) & evx2(f)>=handles.ROILim(1) & evx2(f)<=handles.ROILim(2)));
                        end
                end
            end
        else
            cnt = zeros(1,length(y1));
            for tNum = 1:length(cnt)
                f = find(triggerInfo.eventOnsets{tNum}>=handles.ROILim(1) & triggerInfo.eventOnsets{tNum}<=handles.ROILim(2));
                if strcmp(get(handles.menu_LogScale,'checked'),'on')
                    cnt(tNum) = cnt(tNum) + log10(sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps)+eps);
                else
                    cnt(tNum) = cnt(tNum) + sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps);
                end
            end
        end
        
        switch str_unit
            case {'Rate (Hz)','Fraction of time'}
                totdur = zeros(size(cnt));
                for tNum = 1:length(cnt)
                    for j = 1:length(triggerInfo.dataStart{tNum})
                        st = max([triggerInfo.dataStart{tNum}(j) handles.ROILim(1)]);
                        en = min([triggerInfo.dataStop{tNum}(j) handles.ROILim(2)]);
                        toadd = max([0 en-st]);
                        if ~isempty(handles.WarpPoints)
                            f = find((st+en)/2 >= newwarp(1:end-1) & (st+en)/2 <= newwarp(2:end));
                            if ~isempty(f)
                                toadd = toadd/stretch(tNum,f(1));
                            end
                        end
                        totdur(tNum) = totdur(tNum) + toadd;
                    end
                end
                cnt = cnt ./ (totdur+eps);
            case {'Total count','Count per trial','Time per trial (sec)','Total time (sec)','Average'}
                % Do nothing
        end
        
        numtrials = zeros(size(counts));
        for bn = 1:length(counts)
            f = find(y1>=xs(bn) & y1<xs(bn+1));
            counts(bn) = sum(cnt(f));
            numtrials(bn) = length(f);
        end

        counts = smooth(counts,handles.HistSmoothingWindow);
        
        
        switch str_unit
            case {'Rate (Hz)','Count per trial','Fraction of time','Time per trial (sec)','Average'}
                counts(find(numtrials==0))=0;
                numtrials(find(numtrials==0))=eps;
                counts = counts ./ numtrials;
            case {'Total count','Total time (sec)'}
                % Do nothing
        end
        
        bx = ys([1 2:2:end]);
        bc = zeros(1,length(y1));
        for bn = 1:length(counts)
            f = find(y1>=xs(bn) & y1<xs(bn+1));
            bc(f) = counts(bn);
        end

        
        if handles.PlotInclude(17)==1
            handles.PlotHandles{17} = patch([zeros(size(bc)); bc; bc; zeros(size(bc))],[bx(1:end-1); bx(1:end-1); bx(2:end); bx(2:end)],ones(1,length(bc),3));
        end
        if handles.PlotInclude(16)==1
            handles.PlotHandles{16} = plot(reshape(repmat(bc,2,1),1,length(bc)*2),ys);
        end

        if get(handles.radio_PSTHAuto,'value')==1
            axis tight
            xl = xlim;
            xlim([xl(1) xl(1)+(xl(2)-xl(1))*1.05]);
        else
            if strcmp(get(handles.popup_EventType,'enable'),'on')
                xlim(handles.HistYLim(get(handles.popup_HistUnits,'value'),:));
            else
                xlim(handles.HistYLim(get(handles.popup_HistUnits,'value')+3,:));
            end
        end
        
        xl = xlim;
        if ~isempty(handles.PlotHandles{18})
            xd = get(handles.PlotHandles{18},'xdata');
            xd = repmat([xl(1) xl(2) xl(2) xl(1)]',1,size(xd,2));
            set(handles.PlotHandles{18},'xdata',xd);
        end

        if strcmp(get(handles.popup_EventType,'enable'),'off')
            if strcmp(get(handles.menu_LogScale,'checked'),'on')
                if length(triggerInfo.contLabel) > 1
                    triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
                end
                str_unit = [str_unit ' log'];
            end
            if length(triggerInfo.contLabel) > 1
                triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
            end
            str_unit = [str_unit ' ' triggerInfo.contLabel];
        end
        xlabel(str_unit);
        ylim(get(handles.axes_Raster,'ylim'));
    end
end



% Format events
for c = [1 2 4 5 7 8 10 11 13 15 16 19 20 22 23 25 26 28 29] % line plots
    if iscell(handles.PlotHandles{c})
        set(handles.PlotHandles{c}{end},'color',handles.PlotColor(c,:));
        set(handles.PlotHandles{c}{end},'linewidth',handles.PlotLineWidth(c));
    else
        set(handles.PlotHandles{c},'color',handles.PlotColor(c,:));
        set(handles.PlotHandles{c},'linewidth',handles.PlotLineWidth(c));
    end
end
for c = [14 30] % Single patch
    drawnow
    set(handles.PlotHandles{c},'facecolor',handles.PlotColor(c,:),'edgecolor','none');
    set(handles.PlotHandles{c},'facealpha',handles.PlotAlpha(c));
end

for c = [3 6 9 12 17 18 21 24 27] % sets of patches
    if iscell(handles.PlotHandles{c})
        h = handles.PlotHandles{c}{end};
    else
        h = handles.PlotHandles{c};
    end
    if ~isempty(h)
        drawnow;
        sz = get(h,'cdata');
        if ~isempty(sz)
            sz = size(sz);
            sz = sz(1:2);
            set(h,'cdata',cat(3,handles.PlotColor(c,1)*ones(sz),handles.PlotColor(c,2)*ones(sz),handles.PlotColor(c,3)*ones(sz)));
        else
            set(h,'facecolor',handles.PlotColor(c,:));
        end
        set(h,'edgecolor','none');
        if handles.PlotAlpha(c)<1
            set(h,'facealpha',handles.PlotAlpha(c));
        end
    end
end

set(handles.text_Info,'string','');

set(handles.axes_PSTH,'color',handles.BackgroundColor);
set(handles.axes_Hist,'color',handles.BackgroundColor);
set(handles.axes_Raster,'color',handles.BackgroundColor);


drawnow;
set(handles.push_GenerateRaster,'foregroundcolor','k');

handles.triggerInfo = triggerInfo;
handles.PlotInclude = bck_inc;

handles.BackupXLimRaster = get(handles.axes_Raster,'xlim');
handles.BackupYLimRaster = get(handles.axes_Raster,'ylim');
handles.BackupYLimPSTH = get(handles.axes_PSTH,'ylim');
handles.BackupXLimHist = get(handles.axes_Hist,'xlim');

set(handles.axes_Raster,'buttondownfcn','egm_Sorted_rasters(''click_Raster'',gcbo,[],guidata(gcbo))');
ch = get(handles.axes_Raster,'children');
for c = 1:length(handles.PlotHandles)
    if handles.PlotContinuous(c) < 1
        if iscell(handles.PlotHandles{c})
            for d = 1:length(handles.PlotHandles{c})
                h = intersect(ch,handles.PlotHandles{c}{d});
                set(h,'buttondownfcn','egm_Sorted_rasters(''click_Raster'',gcbo,[],guidata(gcbo))')
            end
        else
            h = intersect(ch,handles.PlotHandles{c});
            set(h,'buttondownfcn','egm_Sorted_rasters(''click_Raster'',gcbo,[],guidata(gcbo))')
        end
    end
end

set(handles.axes_PSTH,'buttondownfcn','egm_Sorted_rasters(''click_PSTH'',gcbo,[],guidata(gcbo))');
set(get(handles.axes_PSTH,'children'),'buttondownfcn','egm_Sorted_rasters(''click_PSTH'',gcbo,[],guidata(gcbo))');
set(handles.axes_Hist,'buttondownfcn','egm_Sorted_rasters(''click_Hist'',gcbo,[],guidata(gcbo))');
set(get(handles.axes_Hist,'children'),'buttondownfcn','egm_Sorted_rasters(''click_Hist'',gcbo,[],guidata(gcbo))');

handles.SkippingSort = 0;
warning on
guidata(hObject, handles);

%%
function [triggerInfo EventFilters] = GetTriggerAlignedEvents(handles,trig,event,warp_points,EventFilters)
% Aligns events to triggers

count = 0;
triggerInfo = [];
for c = 1:length(trig.on)
    if ~isempty(trig.on{c}) & strcmp(get(handles.popup_EventType,'enable'),'off')
        val = get(handles.popup_EventSource,'value')-1;
        axnum = val - length(handles.egh.EventTimes);
        if get(handles.egh.popup_Channel1,'value')==1
            axnum = 2;
        end
        [funct triggerInfo.contLabel fxs] = getContinuousFunction(handles,trig.info.filenum(c),axnum,1);
    end
    
    corr_ax = get(handles.popup_Correlation,'value')-1;
    if corr_ax > 0
        if get(handles.egh.popup_Channel1,'value')==1
            corr_ax = 2;
        end
        [cfunct lab cxs] = getContinuousFunction(handles,trig.info.filenum(c),corr_ax,0);
        if ~isempty(cfunct)
            cfunct = cfunct-mean(cfunct);
            cfunct = cfunct/norm(cfunct);
        end
    end
        
        
    
    for d = 1:length(trig.on{c})
        str = get(handles.popup_TriggerAlignment,'string');
        switch str{get(handles.popup_TriggerAlignment,'value')} % Determine trigger position
            case 'Onset'
                algn = trig.on{c}(d);
            case 'Midpoint'
                algn = round((trig.on{c}(d)+trig.off{c}(d))/2);
            case 'Offset'
                algn = trig.off{c}(d);
        end
        absTime = handles.egh.DatesAndTimes(trig.info.filenum(c)) + algn/(handles.egh.fs*24*60*60);
        
        str = get(handles.popup_StartReference,'string');
        switch str{get(handles.popup_StartReference,'value')} % Determine window start
            case 'Previous onset'
                if d==1
                    bef = -inf;
                else
                    bef = trig.on{c}(d-1);
                end
            case 'Previous offset'
                if d==1
                    bef = -inf;
                else
                    bef = trig.off{c}(d-1);
                end
            case 'Current onset'
                bef = trig.on{c}(d);
            case 'Current midpoint'
                bef = (trig.on{c}(d)+trig.off{c}(d))/2;
            case 'Current offset'
                bef = trig.off{c}(d);
            case 'First warp point'
                f = find(warp_points{c}<absTime);
                if length(f) < handles.WarpNumBefore
                    bef = -inf;
                else
                    if handles.WarpNumBefore > 0
                        tm = warp_points{c}(f(end-handles.WarpNumBefore+1));
                        bef = (tm - handles.egh.DatesAndTimes(trig.info.filenum(c))) * (handles.egh.fs*24*60*60);
                    else
                        bef = algn;
                    end
                end
        end

        str = get(handles.popup_StopReference,'string');
        switch str{get(handles.popup_StopReference,'value')} % Determine window end
            case 'Current onset'
                aft = trig.on{c}(d);
            case 'Current midpoint'
                aft = (trig.on{c}(d)+trig.off{c}(d))/2;
            case 'Current offset'
                aft = trig.off{c}(d);
            case 'Next onset'
                if d==length(trig.on{c})
                    aft = inf;
                else
                    aft = trig.on{c}(d+1);
                end
            case 'Next offset'
                if d==length(trig.on{c})
                    aft = inf;
                else
                    aft = trig.off{c}(d+1);
                end
            case 'Last warp point'
                f = find(warp_points{c}>absTime);
                if length(f) < handles.WarpNumAfter
                    aft = inf;
                else
                    if handles.WarpNumAfter > 0
                        tm = warp_points{c}(f(handles.WarpNumAfter));
                        aft = (tm - handles.egh.DatesAndTimes(trig.info.filenum(c))) * (handles.egh.fs*24*60*60);
                    else
                        aft = algn;
                    end
                end
        end

        bef = round(bef - handles.P.preStartRef*handles.egh.fs);
        aft = round(aft + handles.P.postStopRef*handles.egh.fs);

        if bef < 1 | aft > handles.egh.FileLength(trig.info.filenum(c))
            if get(handles.check_ExcludeIncomplete,'value') == 1
                continue % Skip incomplete trigger
            end
            comp = 0;
        else
            comp = 1;
        end

        bef = max([bef 1]);
        aft = min([aft handles.egh.FileLength(trig.info.filenum(c))]);

        count = count + 1;

        if corr_ax > 0
            indx = find(cxs>=bef & cxs<=aft);
            if isempty(indx)
                triggerInfo.corrShift(count) = 0;
            else
                ons = (cxs(indx(1))-algn)'/handles.egh.fs;
                cval = cfunct(indx);
                if exist('ref_ons','var')
                    [cx lags] = xcorr(cval,ref_cval);
                    f = find(abs(lags/handles.egh.fs)<handles.corrMax);
                    cx = cx(f);
                    lags = lags(f);
                    [mx f] = max(cx);
                    triggerInfo.corrShift(count) = lags(f)/handles.egh.fs + (ons-ref_ons);
                else
                    triggerInfo.corrShift(count) = 0;
                    ref_ons = ons;
                    ref_cval = cval;
                end
            end
        else
            triggerInfo.corrShift(count) = 0;
        end

        algn = algn + triggerInfo.corrShift(count)*handles.egh.fs;

        triggerInfo.fileNum(count) = c;
        triggerInfo.isComplete(count) = comp;
        triggerInfo.absTime(count) = absTime;
        triggerInfo.label(count) = trig.info.label{c}(d);
        triggerInfo.dataStart{count} = (bef-algn)/handles.egh.fs+eps;
        triggerInfo.dataStop{count} = (aft-algn)/handles.egh.fs-eps;
        if d==1
            triggerInfo.prevTrigOnset(count) = -inf;
            triggerInfo.prevTrigOffset(count) = -inf;
        else
            triggerInfo.prevTrigOnset(count) = (trig.on{c}(d-1)-algn)/handles.egh.fs;
            triggerInfo.prevTrigOffset(count) = (trig.off{c}(d-1)-algn)/handles.egh.fs;
        end
        triggerInfo.currTrigOnset(count) = (trig.on{c}(d)-algn)/handles.egh.fs;
        triggerInfo.currTrigOffset(count) = (trig.off{c}(d)-algn)/handles.egh.fs;
        if d==length(trig.on{c})
            triggerInfo.nextTrigOnset(count) = inf;
            triggerInfo.nextTrigOffset(count) = inf;
        else
            triggerInfo.nextTrigOnset(count) = (trig.on{c}(d+1)-algn)/handles.egh.fs;
            triggerInfo.nextTrigOffset(count) = (trig.off{c}(d+1)-algn)/handles.egh.fs;
        end
        
        
        % Filter triggers
        ff = [];
        ff(1) = (triggerInfo.currTrigOffset(count)-triggerInfo.currTrigOnset(count)>=handles.P.filter(1,1) & triggerInfo.currTrigOffset(count)-triggerInfo.currTrigOnset(count)<=handles.P.filter(1,2));
        ff(2) = (triggerInfo.prevTrigOnset(count)>=handles.P.filter(2,1) & triggerInfo.prevTrigOnset(count)<=handles.P.filter(2,2));
        ff(3) = (triggerInfo.prevTrigOffset(count)>=handles.P.filter(3,1) & triggerInfo.prevTrigOffset(count)<=handles.P.filter(3,2));
        ff(4) = (triggerInfo.nextTrigOnset(count)>=handles.P.filter(4,1) & triggerInfo.nextTrigOnset(count)<=handles.P.filter(4,2));
        ff(5) = (triggerInfo.nextTrigOffset(count)>=handles.P.filter(5,1) & triggerInfo.nextTrigOffset(count)<=handles.P.filter(5,2));     
        
        f = prod(ff);
        if f == 0
            fields = fieldnames(triggerInfo);
            for j = 1:length(fields)
                fld = getfield(triggerInfo,fields{j});
                if ~strcmp(fields{j},'contLabel') & length(fld)==count
                    fld = getfield(triggerInfo,fields{j});
                    fld(count) = [];
                    triggerInfo = setfield(triggerInfo,fields{j},fld);
                end
            end
            count = count - 1;
            continue
        end
       
        
        if strcmp(get(handles.popup_EventType,'enable'),'on')
            if get(handles.check_ExcludePartialEvents,'value') == 1
                f = find(event.on{c}>bef & event.off{c}<aft);
            else
                f1 = find(event.on{c}>bef & event.on{c}<aft);
                f2 = find(event.off{c}>bef & event.off{c}<aft);
                f3 = find(event.on{c}<bef & event.off{c}>aft);
                f = union(f1,f2);
                f = union(f,f3);
            end
            triggerInfo.eventOnsets{count} = (event.on{c}(f)-algn)/handles.egh.fs;
            triggerInfo.eventOffsets{count} = (event.off{c}(f)-algn)/handles.egh.fs;
            triggerInfo.eventLabels{count} = (event.info.label{c}(f))/handles.egh.fs;
        else
            indx = find(fxs>=bef & fxs<=aft);
            triggerInfo.eventOnsets{count} = (fxs(indx)-algn)'/handles.egh.fs;
            triggerInfo.eventOffsets{count} = [];
            triggerInfo.eventLabels{count} = funct(indx);
        end
        
        % Filter triggers based on events
        ff = [];
        
        fval = -inf;
        f = find(triggerInfo.eventOnsets{count}<0);
        if ~isempty(f)
            fval = triggerInfo.eventOnsets{count}(f(end));
        end
        ff(1) = (fval>=handles.P.filter(6,1) & fval<=handles.P.filter(6,2));

        fval = -inf;
        f = find(triggerInfo.eventOffsets{count}<0);
        if ~isempty(f)
            fval = triggerInfo.eventOffsets{count}(f(end));
        end
        ff(2) = (fval>=handles.P.filter(7,1) & fval<=handles.P.filter(7,2));

        fval = inf;
        f = find(triggerInfo.eventOnsets{count}>0);
        if ~isempty(f)
            fval = triggerInfo.eventOnsets{count}(f(1));
        end
        ff(3) = (fval>=handles.P.filter(8,1) & fval<=handles.P.filter(8,2));

        fval = inf;
        f = find(triggerInfo.eventOffsets{count}>0);
        if ~isempty(f)
            fval = triggerInfo.eventOffsets{count}(f(1));
        end
        ff(4) = (fval>=handles.P.filter(9,1) & fval<=handles.P.filter(9,2));

        fval = inf;
        if ~isempty(triggerInfo.eventOnsets{count});
            fval = min(triggerInfo.eventOnsets{count});
        end
        ff(5) = (fval>=handles.P.filter(10,1) & fval<=handles.P.filter(10,2));

        fval = inf;
        if ~isempty(triggerInfo.eventOffsets{count});
            fval = min(triggerInfo.eventOffsets{count});
        end
        ff(6) = (fval>=handles.P.filter(11,1) & fval<=handles.P.filter(11,2));
        
        fval = inf;
        if ~isempty(triggerInfo.eventOnsets{count});
            fval = max(triggerInfo.eventOnsets{count});
        end
        ff(7) = (fval>=handles.P.filter(12,1) & fval<=handles.P.filter(12,2));

        fval = inf;
        if ~isempty(triggerInfo.eventOffsets{count});
            fval = max(triggerInfo.eventOffsets{count});
        end
        ff(8) = (fval>=handles.P.filter(13,1) & fval<=handles.P.filter(13,2));
        
        fval = length(triggerInfo.eventOnsets{count});
        ff(9) = (fval>=handles.P.filter(14,1) & fval<=handles.P.filter(14,2));
        
        fval = (length(find(triggerInfo.eventOnsets{count}<=0)) > length(find(triggerInfo.eventOffsets{count}<0)));
        ff(10) = (fval>=handles.P.filter(15,1) & fval<=handles.P.filter(15,2));
        
        if get(handles.check_HoldOn,'value')==0
            f = prod(ff);
            EventFilters{c}(d) = f;
        else
            f = EventFilters{c}(d);
        end
        if f == 0
            fields = fieldnames(triggerInfo);
            for j = 1:length(fields)
                fld = getfield(triggerInfo,fields{j});
                if ~strcmp(fields{j},'contLabel') & length(fld)==count
                    fld = getfield(triggerInfo,fields{j});
                    fld(count) = [];
                    triggerInfo = setfield(triggerInfo,fields{j},fld);
                end
            end
            count = count - 1;
            continue
        end
    end
end



function [triggerInfo ord] = SortTriggers(triggerInfo,type,descend,inc,group_labels)
% Sorts triggers according to the specifications

switch type
    case 'Trigger duration'
        srt = triggerInfo.currTrigOffset-triggerInfo.currTrigOnset;
    case 'Absolute time'
        srt = triggerInfo.absTime;
    case 'Previous trigger onset'
        srt = -triggerInfo.prevTrigOnset;
    case 'Previous trigger offset'
        srt = -triggerInfo.prevTrigOffset;
    case 'Next trigger onset'
        srt = triggerInfo.nextTrigOnset;
    case 'Next trigger offset'
        srt = triggerInfo.nextTrigOffset;
    case 'Trigger label'
        srt = triggerInfo.label;
        if max(srt) & ~isempty(inc)
            f = findstr(inc,'''''');
            inc = double(inc);
            if ~isempty(f)
                inc(f+1) = [];
                inc(f) = 0;
            end
           [dummy ord] = sort(inc);
           for c = 1:length(inc)
               srt(find(srt==inc(c))) = 1000+c;
           end
        end                
    case 'Preceding event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOnsets{c}<0);
            if ~isempty(f)
                srt(c) = -triggerInfo.eventOnsets{c}(f(end));
            end
        end
    case 'Preceding event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOffsets{c}<0);
            if ~isempty(f)
                srt(c) = -triggerInfo.eventOffsets{c}(f(end));
            end
        end
    case 'Following event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOnsets{c}>0);
            if ~isempty(f)
                srt(c) = triggerInfo.eventOnsets{c}(f(1));
            end
        end
    case 'Following event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOffsets{c}>0);
            if ~isempty(f)
                srt(c) = triggerInfo.eventOffsets{c}(f(1));
            end
        end
    case 'First event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOnsets{c});
                srt(c) = min(triggerInfo.eventOnsets{c});
            end
        end
    case 'First event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOffsets{c});
                srt(c) = min(triggerInfo.eventOffsets{c});
            end
        end
    case 'Last event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOnsets{c});
                srt(c) = max(triggerInfo.eventOnsets{c});
            end
        end
    case 'Last event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOffsets{c});
                srt(c) = max(triggerInfo.eventOffsets{c});
            end
        end
    case 'Number of events'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            srt(c) = length(triggerInfo.eventOnsets{c});
        end
    case 'Is in event'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            srt(c) = (length(find(triggerInfo.eventOnsets{c}<=0)) > length(find(triggerInfo.eventOffsets{c}<0)));
        end
end

[srt ord] = sort(srt);
if descend == 1
    ord = ord(end:-1:1);
end

if group_labels == 1
    labs = unique(triggerInfo.label);
    srt = zeros(size(triggerInfo.label));
    for c = 1:length(labs)
        srt(find(triggerInfo.label==labs(c))) = mean(find(triggerInfo.label(ord)==labs(c)));
    end
    [srt ord] = sort(srt);
end

fields = fieldnames(triggerInfo);
for c = 1:length(fields)
    if ~strcmp(fields{c},'contLabel')
        fld = getfield(triggerInfo,fields{c});
        fld = fld(ord);
        triggerInfo = setfield(triggerInfo,fields{c},fld);
    end
end



function [ons offs inform lst] = GetEventStructure(handles,indx,str,P)
% Generates a structure with the list of all events

lst = handles.FileRange;
if get(handles.popup_Files,'value')>1 % all files
    fls = get(handles.egh.list_Files,'string');
    found = [];
    for c = 1:handles.egh.TotalFileNumber
        if strcmp(fls{c}(19),'F')
            found = [found c];
        end
    end
    if get(handles.popup_Files,'value')==2 % Selected files
        lst = intersect(lst,found);
    else
        lst = setdiff(lst,found);
    end
end


ons = cell(1,length(lst));
offs = cell(1,length(lst));
inform.label = cell(1,length(lst));
inform.filenum = zeros(1,length(lst));
for c = 1:length(lst)
    switch str
        case 'Events'
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            ons{c} = min(ev,[],2);
            offs{c} = max(ev,[],2);
            inform.label{c} = zeros(size(ev,1),1);
        case 'Bursts'
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            ev = min(ev,[],2);
            bon = find(handles.egh.fs./(ev(1:end-1)-[-inf; ev(1:end-2)]) <= P.burstFrequency & handles.egh.fs./(ev(2:end)-ev(1:end-1)) > (P.burstFrequency+eps));
            boff = find(handles.egh.fs./(ev(2:end)-ev(1:end-1)) > P.burstFrequency & handles.egh.fs./([ev(3:end); inf]-ev(2:end)) <= P.burstFrequency)+1;
            g = find(boff-bon>=P.burstMinSpikes-1);
            ons{c} = ev(bon(g));
            offs{c} = ev(boff(g));
            inform.label{c} = 1000+boff(g)-bon(g)+1;
        case {'Burst events','Single events'}
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            ev = min(ev,[],2);
            evoff = max(ev,[],2);
            bon = find(handles.egh.fs./(ev(1:end-1)-[-inf; ev(1:end-2)]) <= P.burstFrequency & handles.egh.fs./(ev(2:end)-ev(1:end-1)) > (P.burstFrequency+eps));
            boff = find(handles.egh.fs./(ev(2:end)-ev(1:end-1)) > P.burstFrequency & handles.egh.fs./([ev(3:end); inf]-ev(2:end)) <= P.burstFrequency)+1;
            g = find(boff-bon>=P.burstMinSpikes-1);
            
            burst_spikes = [];
            for bnum = 1:length(g)
                burst_spikes = [burst_spikes bon(g(bnum)):boff(g(bnum))];
            end

            if strcmp(str,'Burst events')
                ons{c} = ev(burst_spikes);
                offs{c} = evoff(burst_spikes);
                inform.label{c} = zeros(size(ev,1),1);
            elseif strcmp(str,'Single events')
                ons{c} = ev(setdiff(1:length(ev),burst_spikes));
                offs{c} = evoff(setdiff(1:length(ev),burst_spikes));
                inform.label{c} = zeros(size(ev,1),1);
            end           
        case 'Pauses'
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            eon = [min(ev,[],2); handles.egh.FileLength(lst(c))+handles.egh.fs*P.pauseMinDuration];
            eoff = [-handles.egh.fs*P.pauseMinDuration; max(ev,[],2)];
            f = find(eon-eoff>handles.egh.fs*P.pauseMinDuration);
            ons{c} = eoff(f);
            offs{c} = eon(f);
            inform.label{c} = zeros(length(f),1);            
        case 'Syllables'
            if ~isempty(handles.egh.SegmentTimes{lst(c)})
                f = find(handles.egh.SegmentSelection{lst(c)}==1);
                ons{c} = handles.egh.SegmentTimes{lst(c)}(f,1);
                offs{c} = handles.egh.SegmentTimes{lst(c)}(f,2);
                lab = zeros(size(ons{c}));
                for d = 1:length(lab)
                    if ~isempty(handles.egh.SegmentTitles{lst(c)}{f(d)})
                        lab(d) = double(handles.egh.SegmentTitles{lst(c)}{f(d)});
                    end
                end
                inform.label{c} = lab;
                
                inc = P.includeSyllList;
                f = findstr(inc,'''''');
                inc([f f+1]) = [];
                inc = double(inc);
                if ~isempty(f)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    f = [];
                    for lb = 1:length(inc)
                        f = union(f,find(lab==inc(lb)));
                    end
                    ons{c} = ons{c}(f);
                    offs{c} = offs{c}(f);
                    inform.label{c} = inform.label{c}(f);
                end
                
                inc = P.ignoreSyllList;
                f = findstr(inc,'''''');
                inc([f f+1]) = [];
                inc = double(inc);
                if ~isempty(f)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    lab = inform.label{c};
                    f = [];
                    for lb = 1:length(inc)
                        f = union(f,find(lab==inc(lb)));
                    end
                    ons{c}(f) = [];
                    offs{c}(f) = [];
                    inform.label{c}(f) = [];
                end
                
            end            
        case 'Motifs'
            if ~isempty(handles.egh.SegmentTimes{lst(c)})
                f = find(handles.egh.SegmentSelection{lst(c)}==1);
                son = handles.egh.SegmentTimes{lst(c)}(f,1);
                soff = handles.egh.SegmentTimes{lst(c)}(f,2);
                titl = handles.egh.SegmentTitles{lst(c)}(f);
                stitl = '';
                for j = 1:length(titl)
                    if strcmp(titl{j},'') | isempty(titl{j});
                        stitl = [stitl char(1)];
                    else
                        stitl = [stitl titl{j}];
                    end
                end
                ons{c} = [];
                offs{c} = [];
                inform.label{c} = [];
                for mot = 1:length(P.motifSequences)
                    st = [];
                    en = [];
                    [st en] = regexp(stitl,P.motifSequences{mot},'start','end');
                    for j = length(st):-1:1
                        if max(son(st(j)+1:en(j))-soff(st(j):en(j)-1)) > handles.egh.fs*P.motifInterval
                            st(j) = [];
                            en(j) = [];
                        end
                    end
                    ons{c} = [ons{c}; son(st)];
                    offs{c} = [offs{c}; soff(en)];
                    inform.label{c} = [inform.label{c}; mot*ones(length(st),1)];
                end                
                inform.label{c} = 1000+inform.label{c};
            end
        case 'Bouts'
            if ~isempty(handles.egh.SegmentTimes{lst(c)})             
                f = find(handles.egh.SegmentSelection{lst(c)}==1);
                
                lab = zeros(1,length(f));
                for d = 1:length(lab)
                    if ~isempty(handles.egh.SegmentTitles{lst(c)}{f(d)})
                        lab(d) = double(handles.egh.SegmentTitles{lst(c)}{f(d)});
                    end
                end
                
                inc = P.includeSyllList;
                g = findstr(inc,'''''');
                inc([g g+1]) = [];
                inc = double(inc);
                if ~isempty(g)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    g = [];
                    for lb = 1:length(inc)
                        g = union(g,find(lab==inc(lb)));
                    end
                end
                if ~isempty(inc)
                    f = f(g);
                end
                
                inc = P.ignoreSyllList;
                g = findstr(inc,'''''');
                inc([g g+1]) = [];
                inc = double(inc);
                if ~isempty(g)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    g = [];
                    for lb = 1:length(inc)
                        g = union(g,find(lab==inc(lb)));
                    end
                end
                if ~isempty(inc)
                    f(g) = [];
                end
                
                son = [handles.egh.SegmentTimes{lst(c)}(f,1); inf];
                soff = [-inf; handles.egh.SegmentTimes{lst(c)}(f,2)];
                f = find(son-soff>handles.egh.fs*P.boutInterval);
                bon = f(1:end-1);
                boff = f(2:end)-1;
                f = find(soff(boff+1)-son(bon)>handles.egh.fs*P.boutMinDuration);
                g = find(boff-bon>=P.boutMinSyllables-1);
                bon = bon(intersect(f,g));
                boff = boff(intersect(f,g));
                ons{c} = son(bon);
                offs{c} = soff(boff+1);
                inform.label{c} = 1000+boff-bon+1;
            end
        case 'Continuous function'
            ons{c} = [];
            offs{c} = [];
            inform.label{c} = [];
    end
    inform.filenum(c) = lst(c);
    if size(ons{c},2)==0
        ons{c} = [];
        offs{c} = [];
        inform.label{c} = [];
    end
end


% --- Executes on button press in check_ExcludeIncomplete.
function check_ExcludeIncomplete_Callback(hObject, eventdata, handles)
% hObject    handle to check_ExcludeIncomplete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ExcludeIncomplete


% --- Executes on selection change in popup_TriggerAlignment.
function popup_TriggerAlignment_Callback(hObject, eventdata, handles)
% hObject    handle to popup_TriggerAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_TriggerAlignment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_TriggerAlignment

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
end

handles = AutoInclude(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popup_TriggerAlignment_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_TriggerAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_ExcludePartialEvents.
function check_ExcludePartialEvents_Callback(hObject, eventdata, handles)
% hObject    handle to check_ExcludePartialEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ExcludePartialEvents


% --- Executes on selection change in list_Filter.
function list_Filter_Callback(hObject, eventdata, handles)
% hObject    handle to list_Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_Filter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_Filter


val = get(handles.list_Filter,'value');
set(handles.edit_FilterFrom,'string',num2str(handles.P.filter(val,1)));
set(handles.edit_FilterTo,'string',num2str(handles.P.filter(val,2)));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function list_Filter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FilterFrom_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FilterFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FilterFrom as text
%        str2double(get(hObject,'String')) returns contents of edit_FilterFrom as a double

val = get(handles.list_Filter,'value');
handles.P.filter(val,1) = str2num(get(handles.edit_FilterFrom,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_FilterFrom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FilterFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FilterTo_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FilterTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FilterTo as text
%        str2double(get(hObject,'String')) returns contents of edit_FilterTo as a double


val = get(handles.list_Filter,'value');
handles.P.filter(val,2) = str2num(get(handles.edit_FilterTo,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_FilterTo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FilterTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_Plot.
function list_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to list_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_Plot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_Plot

val = get(handles.list_Plot,'value');

if strcmp(get(gcf,'selectiontype'),'open')
    if get(handles.check_HoldOn,'value')==0 | (val > 9 & val < 19) | val==20
        handles.PlotInclude(val) = 1-handles.PlotInclude(val);
    end
end

patch_obj = [3 6 9 12 14 17 18 21 24 27 30];
if ~isempty(find(patch_obj==val,1))
    set(handles.push_PlotWidth,'String','Transparency');
else
    set(handles.push_PlotWidth,'String','Width');
end

str = get(handles.list_Plot,'string');
for c = 1:length(str)
    if handles.PlotInclude(c)==1
        str{c}(19:24) = 'FF0000';
    else
        if c==val
            str{val}(19:24) = 'FFFFFF';
        else
            str{c}(19:24) = '000000';
        end
    end
end
set(handles.list_Plot,'string',str);

set(handles.check_PlotInclude,'value',handles.PlotInclude(val));
if handles.PlotContinuous(val) == -1
    set(handles.check_PlotContinuous,'value',0,'enable','off');
else
    set(handles.check_PlotContinuous,'value',handles.PlotContinuous(val),'enable','on');
end

set(handles.check_PlotInclude,'enable','on');
if get(handles.check_HoldOn,'value')==1 & (val < 10 | val == 19 | val > 20)
    set(handles.check_PlotInclude,'enable','off');
    set(handles.check_PlotContinuous,'enable','off');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function list_Plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_PlotInclude.
function check_PlotInclude_Callback(hObject, eventdata, handles)
% hObject    handle to check_PlotInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_PlotInclude


val = get(handles.list_Plot,'value');
handles.PlotInclude(val) = get(handles.check_PlotInclude,'value');

str = get(handles.list_Plot,'string');
for c = 1:length(str)
    if handles.PlotInclude(c)==1
        str{c}(19:24) = 'FF0000';
    else
        if c==val
            str{val}(19:24) = 'FFFFFF';
        else
            str{c}(19:24) = '000000';
        end
    end
end
set(handles.list_Plot,'string',str);

guidata(hObject, handles);


% --- Executes on button press in check_PlotContinuous.
function check_PlotContinuous_Callback(hObject, eventdata, handles)
% hObject    handle to check_PlotContinuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_PlotContinuous


val = get(handles.list_Plot,'value');
handles.PlotContinuous(val) = get(handles.check_PlotContinuous,'value');

str = get(handles.list_Plot,'string');
for c = 1:length(str)
    if handles.PlotInclude(c)==1
        str{c}(19:24) = 'FF0000';
    else
        if c==val
            str{val}(19:24) = 'FFFFFF';
        else
            str{c}(19:24) = '000000';
        end
    end
end
set(handles.list_Plot,'string',str);

guidata(hObject, handles);


% --- Executes on button press in push_PlotColor.
function push_PlotColor_Callback(hObject, eventdata, handles)
% hObject    handle to push_PlotColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.list_Plot,'string');
val = get(handles.list_Plot,'value');
query = [str{val}(26:end-14) ' color'];
c = uisetcolor(handles.PlotColor(val,:),query);
if length(c)<3
    return
end

handles.PlotColor(val,:) = c;

if isempty(handles.PlotHandles{val})
    guidata(hObject, handles);
    return
end

event_indx = get(handles.popup_EventList,'value');

if isfield(handles,'TriggerSelection')
    if val == 10 | val == 11 | val ==12
        indx2 = cumsum(cellfun('length',handles.AllEventOnsets{event_indx}));
        indx1 = [1 indx2(1:end-1)+1];
        indx = [];
        for c = find(handles.TriggerSelection==1)
            indx = [indx indx1(c):indx2(c)];
        end
    else
        indx = find(handles.TriggerSelection==1);
    end
else
    indx = [];
end

for c = intersect([1 2 4 5 7 8 19 22 23 25 26],val)
    if handles.PlotContinuous(val)==1
        if sum(handles.TriggerSelection)<length(handles.triggerInfo.absTime)
            warndlg('Could not selectively change color for a subset of triggers because object''s ''continuous'' option is on.','Warning');
        end
        set(handles.PlotHandles{c},'color',handles.PlotColor(c,:));
    else
        set(handles.PlotHandles{c}(:,indx),'color',handles.PlotColor(c,:));
    end
end
for c = intersect([13 15 16 20 28 29],val)
    set(handles.PlotHandles{c},'color',handles.PlotColor(c,:));
end
for c = intersect([10 11],val)
    if ~isempty(handles.PlotHandles{c}{event_indx})
        set(handles.PlotHandles{c}{event_indx}(indx),'color',handles.PlotColor(c,:));
    end
end
for c = intersect([14 30],val)
    set(handles.PlotHandles{c},'facecolor',handles.PlotColor(c,:),'edgecolor',handles.PlotColor(c,:));
end
for c = intersect([3 6 9 12 17 18 21 24 27],val)
    if iscell(handles.PlotHandles{c})
        h = handles.PlotHandles{c}{event_indx};
    else
        h = handles.PlotHandles{c};
    end
    if ~isempty(h)
        cdt = get(h,'cdata');
        if length(size(cdt))==3
            sz = [length(indx) 1];
            cdt(indx,1,:) = cat(3,handles.PlotColor(c,1)*ones(sz),handles.PlotColor(c,2)*ones(sz),handles.PlotColor(c,3)*ones(sz));
            set(h,'cdata',cdt);
        else
            set(h,'facecolor',handles.PlotColor(c,:));
        end
    end
end


guidata(hObject, handles);


% --- Executes on button press in push_PlotWidth.
function push_PlotWidth_Callback(hObject, eventdata, handles)
% hObject    handle to push_PlotWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.list_Plot,'string');
val = get(handles.list_Plot,'value');

if strcmp(get(handles.push_PlotWidth,'string'),'Width')
    query = [str{val}(26:end-14) ' line width'];
    answer = inputdlg(query,'Line width',1,{num2str(handles.PlotLineWidth(val))});
    if isempty(answer)
        return
    end

    handles.PlotLineWidth(val) = str2num(answer{1});
else
    query = [str{val}(26:end-14) ' transparency'];
    answer = inputdlg(query,'Transparency',1,{num2str(handles.PlotAlpha(val))});
    if isempty(answer)
        return
    end

    handles.PlotAlpha(val) = str2num(answer{1});
end

if isempty(handles.PlotHandles{val})
    guidata(hObject, handles);
    return
end

event_indx = get(handles.popup_EventList,'value');

if isfield(handles,'TriggerSelection')
    if val == 10 | val == 11 | val ==12
        indx2 = cumsum(cellfun('length',handles.AllEventOnsets{event_indx}));
        indx1 = [1 indx2(1:end-1)+1];
        indx = [];
        for c = find(handles.TriggerSelection)
            indx = [indx indx1(c):indx2(c)];
        end
    else
        indx = find(handles.TriggerSelection==1);
    end
else
    indx = [];
end

for c = intersect([1 2 4 5 7 8 19 22 23 25 26],val)
    if handles.PlotContinuous(val)==1
        if sum(handles.TriggerSelection)<length(handles.triggerInfo.absTime)
            warndlg('Could not selectively change width for a subset of triggers because object''s ''continuous'' option is on.','Warning');
        end
        set(handles.PlotHandles{c},'linewidth',handles.PlotLineWidth(c));
    else
        set(handles.PlotHandles{c}(:,indx),'linewidth',handles.PlotLineWidth(c));
    end
end
for c = intersect([13 15 16 20 28 29],val)
    set(handles.PlotHandles{c},'linewidth',handles.PlotLineWidth(c));
end
for c = intersect([10 11],val)
    if ~isempty(handles.PlotHandles{c})
        set(handles.PlotHandles{c}{event_indx}(indx),'linewidth',handles.PlotLineWidth(c));
    end
end

if strcmp(get(handles.push_PlotWidth,'string'),'Transparency')
    if iscell(handles.PlotHandles{val})
        set(handles.PlotHandles{event_indx},'facealpha',handles.PlotAlpha(val));
    else
        set(handles.PlotHandles{val},'facealpha',handles.PlotAlpha(val));
    end
end

guidata(hObject, handles);


% --- Executes on button press in check_LockLimits.
function check_LockLimits_Callback(hObject, eventdata, handles)
% hObject    handle to check_LockLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_LockLimits


if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'enable','off');
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'enable','off');
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
else
    set(handles.popup_StartReference,'enable','on');
    set(handles.popup_StopReference,'enable','on');
end

guidata(hObject, handles);


% --- Executes on button press in push_TimeLimits.
function push_TimeLimits_Callback(hObject, eventdata, handles)
% hObject    handle to push_TimeLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


answer = inputdlg({'Min (sec)','Max (sec)'},'Time limits',1,{num2str(handles.PlotXLim(1)),num2str(handles.PlotXLim(2))});
if isempty(answer)
    return
end
handles.PlotXLim(1) = str2num(answer{1});
handles.PlotXLim(2) = str2num(answer{2});

set(handles.axes_Raster,'xlim',handles.PlotXLim);
set(handles.axes_PSTH,'xlim',handles.PlotXLim);

set(handles.check_CopyWindow,'value',0);

handles.BackupXLim = handles.PlotXLim;

guidata(hObject, handles);


% --- Executes on button press in push_TickHeight.
function push_TickHeight_Callback(hObject, eventdata, handles)
% hObject    handle to push_TickHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = findobj('parent',handles.panel_TickUnits,'style','radiobutton','value',1);
ch = get(handles.panel_TickUnits,'children');
f = 6-find(ch==f);

str = {'number of trials','seconds','inches','percent of the plot'};

if f == 3
    if get(handles.radio_YTrial,'value')==1
        answer = inputdlg({['Tick height (' str{f} ')'],'Overlap (percent)'},'Tick height',1,{num2str(handles.PlotTickSize(f)),num2str(handles.PlotOverlap)});
        if isempty(answer)
            return
        end
        handles.PlotTickSize(f) = str2num(answer{1});
        handles.PlotOverlap = str2num(answer{2});
    else
        answer = inputdlg({['Tick height (' str{f} ')'],'Inches per second'},'Tick height',1,{num2str(handles.PlotTickSize(f)),num2str(handles.PlotInPerSec)});
        if isempty(answer)
            return
        end
        handles.PlotTickSize(f) = str2num(answer{1});
        handles.PlotInPerSec = str2num(answer{2});
    end
else
    answer = inputdlg(['Tick height (' str{f} ')'],'Tick height',1,{num2str(handles.PlotTickSize(f))});
    if isempty(answer)
        return
    end
    handles.PlotTickSize(f) = str2num(answer{1});
end

guidata(hObject, handles);


function RadioYAxis_Callback(hObject, eventdata, handles)

if get(handles.radio_YTrial,'value')==1
    set(get(handles.panel_Sorting,'children'),'enable','on');
    set(handles.radio_TickSeconds,'enable','off');
    if get(handles.radio_TickSeconds,'value')==1
        set(handles.radio_TickTrials,'value',1);
    end
else
    set(handles.radio_TickSeconds,'enable','on');
    set(get(handles.panel_Sorting,'children'),'enable','off');
end

if get(handles.radio_TickInches,'value')==1
    set(get(handles.panel_ExportHeight,'children'),'enable','off');
else
    set(get(handles.panel_ExportHeight,'children'),'enable','on');
end

guidata(hObject, handles);


% --- Executes on button press in check_CopyWindow.
function check_CopyWindow_Callback(hObject, eventdata, handles)
% hObject    handle to check_CopyWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_CopyWindow



% --- Executes on button press in push_Export.
function push_Export_Callback(hObject, eventdata, handles)
% hObject    handle to push_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ch = get(handles.panel_ExportWidth,'children');
iw = findobj('parent',handles.panel_ExportWidth,'value',1);
iw = 3-find(ch==iw);

ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);

switch iw
    case 1
        imwidth = handles.ExportWidth(1);
    case 2
        imwidth = handles.ExportWidth(2)*range(get(handles.axes_Raster,'xlim'));
end

switch ih
    case 1
        imheight = handles.ExportHeight(1);
    case 2
        imheight = handles.ExportHeight(2)*length(handles.triggerInfo.absTime);
    case 3
        imheight = handles.ExportHeight(3)*(max(handles.triggerInfo.absTime)-min(handles.triggerInfo.absTime))*(24*60*60);
end

if get(handles.radio_TickInches,'value')==1
    yl = get(handles.axes_Raster,'ylim');
    if get(handles.radio_YTrial,'value')==1
        imheight = (100-handles.PlotOverlap)/100*handles.PlotTickSize(3)*range(yl);
    else
        imheight = handles.PlotInPerSec*range(yl);
    end
end


subplot(handles.axes_Raster);
bck = get(gca,'units');
set(gca,'units','normalized');
ps = get(gca,'position');
set(gca,'position',[0 0 1 1]);
axis off

bckf = get(handles.fig_Main,'units');
figpos = get(handles.fig_Main,'position');
set(handles.fig_Main,'units','inches','visible','off');
rendback = get(handles.fig_Main,'renderer');
warning off;
set(handles.fig_Main,'PaperPositionMode','auto','Inverthardcopy','off')
obj = findobj('parent',handles.fig_Main,'type','uipanel');
set(obj,'visible','off');
set(handles.axes_PSTH,'visible','off')
set(get(handles.axes_PSTH,'children'),'visible','off')
set(handles.axes_Hist,'visible','off')
set(get(handles.axes_Hist,'children'),'visible','off')
col = get(handles.fig_Main,'color');
set(handles.fig_Main,'color',handles.BackgroundColor);
set(handles.fig_Main,'position',[0 0 imwidth imheight]);

fcont = find(handles.PlotContinuous==1);
for c = 1:length(fcont)
    set(handles.PlotHandles{fcont(c)},'visible','off');
end
set(findobj(handles.axes_Raster,'type','text'),'visible','off');

print('-dtiff','raster.tif',['-r' num2str(handles.ExportResolution)],'-noui');
set(handles.fig_Main,'Renderer','painters');
[newslide pic_top pic_left] = PowerPointExport(handles,imheight,imwidth);
delete('raster.tif');

set(get(handles.axes_Raster,'children'),'visible','off');

for c = 1:length(fcont)
    set(handles.PlotHandles{fcont(c)},'visible','on');
end
set(findobj(handles.axes_Raster,'type','text'),'visible','on');

set(handles.fig_Main,'color',col);
set(handles.fig_Main,'position',[0 0 imwidth*1.25 imheight*1.25]);
set(handles.axes_Raster,'position',[.1 .1 .8 .8]);
subplot(handles.axes_Raster);
set(gca,'visible','on');
axis on
print('-dmeta',['-r' num2str(handles.ExportResolution)],'-noui');
set(handles.fig_Main,'renderer',rendback);
warning on
pic = invoke(newslide.Shapes,'Paste');
ug = invoke(pic,'Ungroup');
set(ug,'Height',72*imheight*1.25,'Width',72*imwidth*1.25);
set(ug,'Top',pic_top-0.1*get(ug,'Height'),'Left',pic_left-0.1*get(ug,'Width'));
set(ug.Fill,'Visible','msoFalse');
tp = get(ug,'Top')+0.9*get(ug,'Height');
lf = get(ug,'Left')+0.1*get(ug,'Width');
ug = invoke(ug,'Ungroup');
for c = 1:get(ug,'Count')
    txt = invoke(ug,'Item',c);
    if strcmp(get(txt,'HasTextFrame'),'msoTrue')
        if get(txt,'Top') > tp
            set(txt.TextFrame,'VerticalAnchor','msoAnchorTop','HorizontalAnchor','msoAnchorCenter');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
        elseif get(txt,'Top') < tp & get(txt,'Left') < lf & get(txt,'Rotation') == 0
            set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
        elseif get(txt,'Top') < tp & get(txt,'Left') < lf & get(txt,'Rotation') ~= 0
            set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
        else
            set(txt.TextFrame,'VerticalAnchor','msoAnchorTop');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
        end
    end
end
invoke(invoke(ug,'Item',2),'Delete');
invoke(invoke(ug,'Item',1),'Delete');

set(get(handles.axes_Raster,'children'),'visible','on');

set(obj,'visible','on');
if handles.HistShow(1)==1
    set(get(handles.axes_PSTH,'children'),'visible','on')
    set(handles.axes_PSTH,'visible','on')
end

set(get(handles.axes_Hist,'children'),'visible','on')
set(handles.axes_Hist,'visible','on')
if handles.HistShow(2)==0
    set(get(handles.axes_Hist,'children'),'visible','off')
    set(handles.axes_Hist,'visible','off')
end
set(handles.fig_Main,'units',bckf);
set(handles.fig_Main,'position',figpos,'visible','on');
subplot(handles.axes_Raster);
set(gca,'position',ps);
set(gca,'units',bck);

guidata(hObject, handles);

% --- Executes on button press in push_Dimensions.
function push_Dimensions_Callback(hObject, eventdata, handles)
% hObject    handle to push_Dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ch = get(handles.panel_ExportWidth,'children');
iw = findobj('parent',handles.panel_ExportWidth,'value',1);
iw = 3-find(ch==iw);

ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);

query{1} = 'PSTH height (in)';
query{2} = 'Vertical histogram width (in)';
query{3} = 'Interval between subplots (in)';
query{4} = 'Raster resolution (dpi)';
str = {'Raster width (in)','Raster width (in/sec)'};
query{5} = str{iw};
if strcmp(get(ch(1),'enable'),'on')
    str = {'Raster height (in)','Raster height (in/trial)','Raster height (in/sec)'};
    query{6} = str{ih};
end

def{1} = num2str(handles.ExportPSTHHeight);
def{2} = num2str(handles.ExportHistHeight);
def{3} = num2str(handles.ExportInterval);
def{4} = num2str(handles.ExportResolution);
def{5} = num2str(handles.ExportWidth(iw));
if strcmp(get(ch(1),'enable'),'on')
    def{6} = num2str(handles.ExportHeight(ih));
end

answer = inputdlg(query,'Image dimensions',1,def);
if isempty(answer)
    return
end

handles.ExportPSTHHeight = str2num(answer{1});
handles.ExportHistHeight = str2num(answer{2});
handles.ExportInterval = str2num(answer{3});
handles.ExportResolution = str2num(answer{4});
handles.ExportWidth(iw) = str2num(answer{5});
if strcmp(get(ch(1),'enable'),'on')
    handles.ExportHeight(ih) = str2num(answer{6});
end

guidata(hObject, handles);



function [newslide pic_top pic_left] = PowerPointExport(handles,imheight,imwidth)

% Start presentation
ppt = actxserver('PowerPoint.Application');
op = get(ppt,'ActivePresentation');
slide_count = get(op.Slides,'Count');
slide_count = int32(double(slide_count)+1);
newslide = invoke(op.Slides,'Add',slide_count,'ppLayoutBlank');

% Add picture
pic = invoke(newslide.Shapes,'AddPicture',[pwd '\raster.tif'],'msoFalse','msoTrue',0,0,imwidth*72,imheight*72);
totheight = get(pic,'Height');
if get(handles.check_IncludePSTH,'value')==1 & handles.HistShow(1)==1
    totheight = totheight + 72*handles.ExportPSTHHeight + 72*handles.ExportInterval;
end
totwidth = get(pic,'Width');
if get(handles.check_IncludePSTH,'value')==1 & handles.HistShow(2)==1
    totwidth = totwidth + 72*handles.ExportHistHeight + 72*handles.ExportInterval;
end
set(pic,'top',get(op.PageSetup,'SlideHeight')/2+totheight/2-get(pic,'Height'));
set(pic,'left',get(op.PageSetup,'SlideWidth')/2-totwidth/2);

pic_top = get(pic,'top');
pic_left = get(pic,'left');


% Add PSTH

if get(handles.check_IncludePSTH,'value')==1 & handles.HistShow(1)==1

    yoff = get(pic,'Top') - 72*handles.ExportInterval;

    if ~isempty(handles.PlotHandles{14})
        x = get(handles.PlotHandles{14},'xdata');
        y = get(handles.PlotHandles{14},'ydata');
        x = x(2:2:end-2);
        y = y(2:2:end-2);
        xl = get(handles.axes_PSTH,'xlim');
        yl = get(handles.axes_PSTH,'ylim');
        f = find(x>=xl(1) & x<=xl(2));
        x = x(f);
        y = y(f);

        num = ceil(handles.ExportResolution*imwidth/length(y));
        y = repmat(y',num,1);
        y = reshape(y,numel(y),1);
        x = repmat(x',num,1);
        x = reshape(x,numel(x),1);
        
        img = repmat(linspace(yl(1),yl(2),round(handles.ExportResolution*handles.ExportPSTHHeight))',1,length(y));
        img = img - repmat(y',size(img,1),1);
        img = (img>0);
        imwrite(flipud(img),[handles.PlotColor(14,:); handles.BackgroundColor],'psth.gif');
        clear img;

        psth = invoke(newslide.Shapes,'AddPicture',[pwd '\psth.gif'],'msoFalse','msoTrue',0,0,imwidth*72,handles.ExportPSTHHeight*72);
        set(psth,'Top',yoff-get(psth,'Height'));
        set(psth,'Left',get(pic,'Left'));
        delete([pwd '\psth.gif']);
    end
    
    if ~isempty(handles.PlotHandles{20})
        for c = 1:length(handles.PlotHandles{20})
            xp = get(handles.PlotHandles{20}(c),'xdata');
            xp = xp(1);
            xpos = (xp-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
            xpos = xpos*get(pic,'Width')+get(pic,'Left');
            ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
            col = 255*handles.PlotColor(20,1) + 256*255*handles.PlotColor(20,2) + 256^2*255*handles.PlotColor(20,3);
            set(ln.Line.ForeColor,'RGB',col);
            set(ln.Line,'Weight',handles.PlotLineWidth(20));
        end
    end

    if ~isempty(handles.PlotHandles{15})
        xpos = (0-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
        xpos = xpos*get(pic,'Width')+get(pic,'Left');
        ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
        col = 255*handles.PlotColor(15,1) + 256*255*handles.PlotColor(15,2) + 256^2*255*handles.PlotColor(15,3);
        set(ln.Line.ForeColor,'RGB',col);
        set(ln.Line,'Weight',handles.PlotLineWidth(15));
    end
    
    if ~isempty(handles.PlotHandles{30})
        xp = get(handles.PlotHandles{30},'xdata');
        xpos = (xp(1)-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
        xpos1 = xpos*get(pic,'Width')+get(pic,'Left');
        xpos = (xp(2)-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
        xpos2 = xpos*get(pic,'Width')+get(pic,'Left');
        rc = invoke(newslide.Shapes,'AddShape','msoShapeRectangle',xpos1,yoff-72*handles.ExportPSTHHeight,xpos2-xpos1,72*handles.ExportPSTHHeight);
        set(rc.Line,'Visible','msoFalse');
        col = 255*handles.PlotColor(30,1) + 256*255*handles.PlotColor(30,2) + 256^2*255*handles.PlotColor(30,3);
        set(rc.Fill.ForeColor,'RGB',col);
        set(rc.Fill,'Transparency',handles.PlotAlpha(30));
    end
    xl = get(handles.axes_PSTH,'xlim');
    if ~isempty(handles.PlotHandles{28})
        xp = get(handles.PlotHandles{28},'xdata');
        xp = xp(1);
        if xp>=xl(1) & xp<=xl(2)
            xpos = (xp-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
            xpos = xpos*get(pic,'Width')+get(pic,'Left');
            ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
            col = 255*handles.PlotColor(28,1) + 256*255*handles.PlotColor(28,2) + 256^2*255*handles.PlotColor(28,3);
            set(ln.Line.ForeColor,'RGB',col);
            set(ln.Line,'Weight',handles.PlotLineWidth(28));
        end
    end
    if ~isempty(handles.PlotHandles{29})
        xp = get(handles.PlotHandles{29},'xdata');
        xp = xp(1);
        if xp>=xl(1) & xp<=xl(2)
            xpos = (xp-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
            xpos = xpos*get(pic,'Width')+get(pic,'Left');
            ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
            col = 255*handles.PlotColor(29,1) + 256*255*handles.PlotColor(29,2) + 256^2*255*handles.PlotColor(29,3);
            set(ln.Line.ForeColor,'RGB',col);
            set(ln.Line,'Weight',handles.PlotLineWidth(29));
        end
    end

    fig = figure('visible','off','units','inches','position',[0 0 imwidth*1.25 handles.ExportPSTHHeight*1.25]);
    subplot('position',[.1 .1 .8 .8]);
    if ~isempty(handles.PlotHandles{13})
        h = handles.PlotHandles{13};
        x = get(h,'xdata');
        y = get(h,'ydata');
        xl = get(handles.axes_PSTH,'xlim');
        yl = get(handles.axes_PSTH,'ylim');
        pl = plot(x,y);
        set(pl,'color',handles.PlotColor(13,:));
        set(pl,'linewidth',handles.PlotLineWidth(13));
    end
    xlim(get(handles.axes_PSTH,'xlim'));
    ylim(get(handles.axes_PSTH,'ylim'));
    set(gca,'xtick',[]);
    ylabel(get(get(handles.axes_PSTH,'ylabel'),'string'));
    print('-dmeta',['-f' num2str(fig)],['-r' num2str(handles.ExportResolution)]);
    delete(fig);
    ug = invoke(newslide.Shapes,'Paste');
    ug = invoke(ug,'Ungroup');
    set(ug.Fill,'Visible','msoFalse');
    ug = invoke(ug,'Ungroup');
    for c = 1:get(ug,'Count')
        txt = invoke(ug,'Item',c);
        if strcmp(get(txt,'HasTextFrame'),'msoTrue')
            if get(txt,'Rotation') == 0
                set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle');
                set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
            else
                set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter');
                set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
            end
        end
    end
    ug = invoke(ug,'Group');
    set(ug,'Height',72*handles.ExportPSTHHeight*1.25,'Width',72*imwidth*1.25);
    set(ug,'Top',yoff-get(ug,'Height')+0.1*get(ug,'Height'));
    set(ug,'Left',get(pic,'Left')-0.1*get(ug,'Width'));
    ug = invoke(ug,'Ungroup');
    for c = 4:-1:1
        invoke(invoke(ug,'Item',c),'Delete');
    end

end


% Add vertical histogram

if get(handles.check_IncludePSTH,'value')==1 & handles.HistShow(2)==1

    xoff = get(pic,'Left') + get(pic,'Width') + 72*handles.ExportInterval;
    
    if ~isempty(handles.PlotHandles{17})
        x = get(handles.PlotHandles{17},'xdata');
        y = get(handles.PlotHandles{17},'ydata');
        cd = get(handles.PlotHandles{17},'cdata');
        if length(size(cd))==2
            cd = get(handles.PlotHandles{17},'facecolor');
            cd = permute(cd,[3 1 2]);
        end
        if ~isempty(handles.PlotHandles{18})
            cdb = get(handles.PlotHandles{18},'cdata');
            if length(size(cdb))==2
                cdb = get(handles.PlotHandles{18},'facecolor');
                cdb = permute(cdb,[3 1 2]);
            end
        end
        
        resy = round(handles.ExportResolution*imheight);
        resx = round(handles.ExportResolution*handles.ExportHistHeight);
        xl = get(handles.axes_Hist,'xlim');
        yl = get(handles.axes_Hist,'ylim');
        xs = linspace(xl(1),xl(2),resx);
        ys = linspace(yl(1),yl(2),resy);
        
        img = repmat(permute(handles.BackgroundColor,[3 1 2]),resy,resx);
        for c = 1:size(cd,1)
            indxx = find(xs<=x(2,c));
            indxy = find(ys>=y(1,c) & ys<=y(3,c));
            img(indxy,indxx,:) = repmat(cd(c,1,:),length(indxy),length(indxx));
            if ~isempty(handles.PlotHandles{18})
                indxx = find(xs>x(2,c));
                img(indxy,indxx,:) = repmat(cdb(c,1,:),length(indxy),length(indxx));
            end
        end
        for c = 1:3
            img(:,:,c) = flipud(img(:,:,c));
        end
        
        imwrite(img,'hist.tif');
        clear img;
        
        psth = invoke(newslide.Shapes,'AddPicture',[pwd '\hist.tif'],'msoFalse','msoTrue',0,0,handles.ExportHistHeight*72,imheight*72);
        set(psth,'Top',get(pic,'top')+get(pic,'height')-get(psth,'height'));
        set(psth,'Left',xoff);
        delete([pwd '\hist.tif']);
    end

    fig = figure('visible','off','units','inches','position',[0 0 handles.ExportHistHeight*1.25 imheight*1.25]);
    subplot('position',[.1 .1 .8 .8]);
    if ~isempty(handles.PlotHandles{16})
        h = handles.PlotHandles{16};
        x = get(h,'xdata');
        y = get(h,'ydata');
        pl = plot(x,y);
        set(pl,'color',handles.PlotColor(16,:));
        set(pl,'linewidth',handles.PlotLineWidth(16));
    end
    xlim(get(handles.axes_Hist,'xlim'));
    ylim(get(handles.axes_Hist,'ylim'));
    set(gca,'ytick',[]);
    box off
    xlabel(get(get(handles.axes_Hist,'xlabel'),'string'));
    print('-dmeta',['-f' num2str(fig)],['-r' num2str(handles.ExportResolution)]);
    delete(fig);
    ug = invoke(newslide.Shapes,'Paste');
    ug = invoke(ug,'Ungroup');
    set(ug.Fill,'Visible','msoFalse');
    ug = invoke(ug,'Ungroup');
    for c = 1:get(ug,'Count')
        txt = invoke(ug,'Item',c);
        if strcmp(get(txt,'HasTextFrame'),'msoTrue')
            set(txt.TextFrame,'HorizontalAnchor','msoAnchorCenter');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
        end
    end
    ug = invoke(ug,'Group');
    set(ug,'Height',72*imheight*1.25,'Width',72*handles.ExportHistHeight*1.25);
    set(ug,'Top',get(pic,'Top')-0.1*get(ug,'Height'));
    set(ug,'Left',xoff-0.1*get(ug,'Width'));
    ug = invoke(ug,'Ungroup');
    for c = 4:-1:1
        invoke(invoke(ug,'Item',c),'Delete');
    end
end



% --- Executes on button press in push_Open.
function push_Open_Callback(hObject, eventdata, handles)
% hObject    handle to push_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat','Load analysis');
if ~isstr(file)
    return
end
cd(path)

load([path file],'dbase');

set(handles.popup_Files,'value',1);
set(handles.popup_Files,'string',{'All files in range'});

handles.egh.fs = dbase.Fs;
handles.egh.DatesAndTimes = dbase.Times;
handles.egh.FileLength = dbase.FileLength;
handles.egh.sound_files = dbase.SoundFiles;
handles.egh.chan_files = dbase.ChannelFiles;
handles.egh.sound_loader = dbase.SoundLoader;
handles.egh.chan_loader = dbase.ChannelLoader;
handles.egh.SoundThresholds = dbase.SegmentThresholds;
handles.egh.SegmentTimes = dbase.SegmentTimes;
handles.egh.SegmentTitles = dbase.SegmentTitles;
handles.egh.SegmentSelection = dbase.SegmentIsSelected;
handles.egh.EventSources = dbase.EventSources;
handles.egh.EventFunctions = dbase.EventFunctions;
handles.egh.EventDetectors = dbase.EventDetectors;
handles.egh.EventThresholds = dbase.EventThresholds;
handles.egh.EventTimes = dbase.EventTimes;
handles.egh.EventSelected = dbase.EventIsSelected;
handles.egh.Properties = dbase.Properties;
handles.egh.TotalFileNumber = length(handles.egh.sound_files);

handles.egh.overlaptolerance = 0.0001;
handles.egh = Fix_Overlap(handles.egh);

handles.FileRange = 1:handles.egh.TotalFileNumber;
handles.FileNames = {};
for c = 1:length(dbase.SoundFiles)
    handles.FileNames{c} = dbase.SoundFiles(c).name;
end


% Get event list
str = {'Sound'};
for c = 1:length(handles.egh.EventSources)
    str{end+1} = [handles.egh.EventDetectors{c} ' - ' handles.egh.EventSources{c} ' - ' handles.egh.EventFunctions{c}];
end

if get(handles.popup_TriggerSource,'value') > length(str)
    set(handles.popup_TriggerSource,'value',1);
end
set(handles.popup_TriggerSource,'string',str);

if get(handles.popup_EventSource,'value') > length(str)
    if length(str)==1
        set(handles.popup_EventSource,'value',1);
    else
        set(handles.popup_EventSource,'value',2);
    end
end
set(handles.popup_EventSource,'string',str);

if get(handles.popup_TriggerSource,'value') == 1
    set(handles.popup_TriggerType,'string',{'Syllables','Motifs','Bouts'});
else
    set(handles.popup_TriggerType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
end

if get(handles.popup_EventSource,'value') == 1
    set(handles.popup_EventType,'string',{'Syllables','Motifs','Bouts'});
else
    set(handles.popup_EventType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
end

set(handles.popup_EventType,'enable','on');
set(handles.popup_Correlation,'value',1);
set(handles.popup_Correlation,'string',{'(None)'});

cla(handles.axes_PSTH);
cla(handles.axes_Hist);
cla(handles.axes_Raster);

str = get(handles.list_WarpPoints,'string');
for c = length(handles.WarpPoints):-1:1
    if handles.WarpPoints{c}.source > 0
        handles.WarpPoints(c) = [];
        str(c) = [];
    end
end
if isempty(str)
    str = {'(None)'};
end
set(handles.list_WarpPoints,'value',1);
set(handles.list_WarpPoints,'string',str);

if get(handles.check_CopyWindow,'value')==1
    if get(handles.check_LockLimits,'value')==1
        set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
        set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
        if ~isempty(handles.WarpPoints)
            set(handles.popup_StartReference,'value',6);
            set(handles.popup_StopReference,'value',6);
        end
    end
end

set(handles.push_GenerateRaster,'enable','on');
set(handles.push_FileRange,'enable','on');

guidata(hObject, handles);


% --- Executes on selection change in popup_PSTHUnits.
function popup_PSTHUnits_Callback(hObject, eventdata, handles)
% hObject    handle to popup_PSTHUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_PSTHUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_PSTHUnits


% --- Executes during object creation, after setting all properties.
function popup_PSTHUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_PSTHUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_PSTHBinSize.
function push_PSTHBinSize_Callback(hObject, eventdata, handles)
% hObject    handle to push_PSTHBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.push_HistHoriz,'fontweight'),'bold')
    str = get(handles.popup_PSTHUnits,'string');
    val = get(handles.popup_PSTHUnits,'value');
    str = str{val};
    str(1) = lower(str(1));

    if strcmp(get(handles.popup_EventType,'enable'),'off')
        val = val + 3;
    end
    
    answer = inputdlg({'PSTH bin size (sec)','Smoothing window (# of bins)',['Min ' str],['Max ' str]},'Options',1,{num2str(handles.PSTHBinSize),num2str(handles.PSTHSmoothingWindow),num2str(handles.PSTHYLim(val,1)),num2str(handles.PSTHYLim(val,2))});
    if isempty(answer)
        return
    end

    handles.PSTHBinSize = str2num(answer{1});
    handles.PSTHSmoothingWindow = str2num(answer{2});
    handles.PSTHYLim(val,1) = str2num(answer{3});
    handles.PSTHYLim(val,2) = str2num(answer{4});

    if get(handles.radio_PSTHManual,'value')==1
        set(handles.axes_PSTH,'ylim',handles.PSTHYLim(val,:));
    end
else
    str = get(handles.popup_HistUnits,'string');
    valm = get(handles.popup_HistUnits,'value');
    strm = str{valm};
    strm(1) = lower(strm(1));

    if strcmp(get(handles.popup_EventType,'enable'),'off')
        valm = valm + 3;
    end
    
    if get(handles.radio_YTrial,'value')==1
        val = 1;
    else
        val = 2;
    end
    str = {'trials','sec'};
    answer = inputdlg({['Histogram bin size (' str{val} ')'],'Smoothing window (# of bins)','ROI start (sec)','ROI stop (sec)',['Min ' strm],['Max ' strm]},'Options',1,{num2str(handles.HistBinSize(val)),num2str(handles.HistSmoothingWindow),num2str(handles.ROILim(1)),num2str(handles.ROILim(2)),num2str(handles.HistYLim(val,1)),num2str(handles.HistYLim(val,2))});
    if isempty(answer)
        return
    end
    
    handles.HistBinSize(val) = str2num(answer{1});
    handles.HistSmoothingWindow = str2num(answer{2});
    handles.ROILim(1) = str2num(answer{3});
    handles.ROILim(2) = str2num(answer{4});
    handles.HistYLim(val,1) = str2num(answer{5});
    handles.HistYLim(val,2) = str2num(answer{6});

    if get(handles.radio_PSTHManual,'value')==1
        set(handles.axes_Hist,'xlim',handles.HistYLim(val,:));
    end
end

guidata(hObject, handles);


% --- Executes on selection change in popup_PSTHCount.
function popup_PSTHCount_Callback(hObject, eventdata, handles)
% hObject    handle to popup_PSTHCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_PSTHCount contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_PSTHCount


% --- Executes during object creation, after setting all properties.
function popup_PSTHCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_PSTHCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_IncludePSTH.
function check_IncludePSTH_Callback(hObject, eventdata, handles)
% hObject    handle to check_IncludePSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_IncludePSTH


% --- Executes on button press in check_HoldOn.
function check_HoldOn_Callback(hObject, eventdata, handles)
% hObject    handle to check_HoldOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_HoldOn

if get(handles.check_HoldOn,'value')==1
    set(get(handles.panel_Files,'children'),'enable','off');
    set(get(handles.panel_Trigger,'children'),'enable','off');
    set(get(handles.panel_Window,'children'),'enable','off');
    set(get(handles.panel_Filtering,'children'),'enable','off');
    set(setdiff(get(handles.panel_Warping,'children'),handles.panel_WarpedDurations),'enable','off');
    set(get(handles.panel_WarpedDurations,'children'),'enable','off');
    set(get(handles.panel_TickUnits,'children'),'enable','off');
    set(get(handles.panel_TimeAxis,'children'),'enable','off');
    set(get(handles.panel_YAxis,'children'),'enable','off');
    set(handles.check_CopyEvents,'userdata',get(handles.check_CopyEvents,'value'));
    set(handles.check_CopyEvents,'value',0);
    set(get(handles.panel_Sorting,'children'),'enable','off');
    set(handles.check_SkipSorting,'userdata',get(handles.check_SkipSorting,'value'));
    set(handles.check_SkipSorting,'value',0);
    set(handles.check_SkipSorting,'enable','off');
else
    set(get(handles.panel_Files,'children'),'enable','on');
    set(get(handles.panel_Trigger,'children'),'enable','on');
    set(get(handles.panel_Window,'children'),'enable','on');
    set(get(handles.panel_Filtering,'children'),'enable','on');
    set(setdiff(get(handles.panel_Warping,'children'),handles.panel_WarpedDurations),'enable','on');
    set(get(handles.panel_WarpedDurations,'children'),'enable','on');
    set(get(handles.panel_TickUnits,'children'),'enable','on');
    set(get(handles.panel_TimeAxis,'children'),'enable','on');
    set(get(handles.panel_YAxis,'children'),'enable','on');
    set(handles.check_CopyEvents,'value',get(handles.check_CopyEvents,'userdata'));
    set(handles.check_SkipSorting,'value',get(handles.check_SkipSorting,'userdata'));
    set(handles.check_SkipSorting,'enable','on');
    if get(handles.radio_YTrial,'value')==1
        set(get(handles.panel_Sorting,'children'),'enable','on');
        set(handles.radio_TickSeconds,'enable','off');
    end
    if get(handles.check_LockLimits,'value')==1
        set(handles.popup_StartReference,'enable','off');
        set(handles.popup_StopReference,'enable','off');
    end
end

obj = handles.list_Plot;
egm_Sorted_rasters('list_Plot_Callback',obj,[],guidata(obj));

guidata(hObject, handles);


% --- Executes on selection change in list_WarpPoints.
function list_WarpPoints_Callback(hObject, eventdata, handles)
% hObject    handle to list_WarpPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_WarpPoints contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_WarpPoints


% --- Executes during object creation, after setting all properties.
function list_WarpPoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_WarpPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_AddPoint.
function push_AddPoint_Callback(hObject, eventdata, handles)
% hObject    handle to push_AddPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val_s = get(handles.popup_TriggerSource,'value');
str = get(handles.popup_TriggerSource,'string');
str_s = str{val_s};

val = get(handles.popup_TriggerType,'value');
str = get(handles.popup_TriggerType,'string');
str_t = str{val};

val = get(handles.popup_TriggerAlignment,'value');
str = get(handles.popup_TriggerAlignment,'string');
str_a = str{val};

w.P = handles.P.trig;
w.source = val_s - 1;
w.type = str_t;
w.alignment = str_a;

str = [str_t(1:end-1) ' ' lower(str_a) 's - ' str_s];

lst = get(handles.list_WarpPoints,'string');
if length(lst) == 1 & strcmp(lst{1},'(None)')
    lst = {str};
else
    lst{end+1} = str;
end

handles.WarpPoints{end+1} = w;

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',6);
    set(handles.popup_StopReference,'value',6);
end

set(handles.list_WarpPoints,'string',lst);
set(handles.list_WarpPoints,'value',length(lst));

guidata(hObject, handles);


% --- Executes on button press in push_DeletePoint.
function push_DeletePoint_Callback(hObject, eventdata, handles)
% hObject    handle to push_DeletePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.list_WarpPoints,'value');
str = get(handles.list_WarpPoints,'string');
if length(str) == 1 & strcmp(str{1},'(None)')
    return
end

str(val) = [];
handles.WarpPoints(val) = [];

if isempty(str)
    str = {'(None)'};
end

if val > length(str)
    val = length(str);
end
set(handles.list_WarpPoints,'value',val);

set(handles.list_WarpPoints,'string',str);

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
end


guidata(hObject, handles);


% --- Executes on selection change in popup_WarpingAlgorithm.
function popup_WarpingAlgorithm_Callback(hObject, eventdata, handles)
% hObject    handle to popup_WarpingAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_WarpingAlgorithm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_WarpingAlgorithm


% --- Executes during object creation, after setting all properties.
function popup_WarpingAlgorithm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_WarpingAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_WarpOptions.
function push_WarpOptions_Callback(hObject, eventdata, handles)
% hObject    handle to push_WarpOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Maximum allowed correlation shift (sec)','Number of warp intervals prior to trigger','Number of warp intervals after trigger'},'Warp options',1,{num2str(handles.corrMax),num2str(handles.WarpNumBefore),num2str(handles.WarpNumAfter)});
if isempty(answer)
    return
end
handles.corrMax = str2num(answer{1});
handles.WarpNumBefore = str2num(answer{2});
handles.WarpNumAfter = str2num(answer{3});

guidata(hObject, handles);


% --- Executes on button press in push_IntervalDuration.
function push_IntervalDuration_Callback(hObject, eventdata, handles)
% hObject    handle to push_IntervalDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2num(get(handles.text_Interval,'string'));
indx = num - handles.WarpIntervalLim(1) + 1;
if num > 0
    indx = indx - 1;
end

answer = inputdlg({['Custom duration for interval ' get(handles.text_Interval,'string')]},'Duration',1,{num2str(handles.WarpIntervalDuration(indx))});
if isempty(answer)
    return
end
handles.WarpIntervalDuration(indx) = str2num(answer{1});
handles.WarpIntervalType(indx) = 4;
set(handles.radio_WarpCustom,'value',1);

guidata(hObject, handles);


% --- Executes on button press in push_IntervalLeft.
function push_IntervalLeft_Callback(hObject, eventdata, handles)
% hObject    handle to push_IntervalLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2num(get(handles.text_Interval,'string'));
num = num - 1;
if num == 0
    num = -1;
end
handles = UpdateInterval(handles,num);

guidata(hObject, handles);

% --- Executes on button press in push_IntervalRight.
function push_IntervalRight_Callback(hObject, eventdata, handles)
% hObject    handle to push_IntervalRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2num(get(handles.text_Interval,'string'));
num = num + 1;
if num == 0
    num = 1;
end
handles = UpdateInterval(handles,num);

guidata(hObject, handles);


function handles = UpdateInterval(handles,num);

str = num2str(num);
if num > 0
    str = ['+' str];
end

set(handles.text_Interval,'string',str);

if num < handles.WarpIntervalLim(1)
    handles.WarpIntervalLim(1) = handles.WarpIntervalLim(1) - 1;
    handles.WarpIntervalType = [1 handles.WarpIntervalType];
    handles.WarpIntervalDuration = [.1 handles.WarpIntervalDuration];
end

if num > handles.WarpIntervalLim(2)
    handles.WarpIntervalLim(2) = handles.WarpIntervalLim(2) + 1;
    handles.WarpIntervalType = [handles.WarpIntervalType 1];
    handles.WarpIntervalDuration = [handles.WarpIntervalDuration .1];
end

indx = num - handles.WarpIntervalLim(1) + 1;
if num > 0
    indx = indx - 1;
end
ch = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton');
set(ch(handles.WarpIntervalType(indx)),'value',1);


function RadioWarpedDurations(hObject, eventdata, handles)

num = str2num(get(handles.text_Interval,'string'));
indx = num - handles.WarpIntervalLim(1) + 1;
if num > 0
    indx = indx - 1;
end

ch = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton');
sel = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton','value',1);
handles.WarpIntervalType(indx) = find(ch==sel);

guidata(hObject, handles);


function click_Raster(hObject, eventdata, handles)

if strcmp(get(gcf,'selectiontype'),'normal')
    set(gca,'units','pixels');
    set(get(gca,'parent'),'units','pixels');
    rect = rbbox;

    pos = get(gca,'position');
    set(get(gca,'parent'),'units','normalized');
    set(gca,'units','normalized');
    xl = xlim;
    yl = ylim;

    rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
    rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

    if rect(3) == 0 | rect(4) == 0
        if ~strcmp(get(hObject,'type'),'axes') & ~strcmp(get(hObject,'type'),'text')
            [mn indx] = min(abs(rect(2)-handles.TrialYs));
            
            x = get(hObject,'xdata');
            y = get(hObject,'ydata');
            if strcmp(get(hObject,'type'),'patch')
                f = find(x(1,:)<rect(1) & x(2,:)>rect(1) & y(2,:)<rect(2) & y(3,:)>rect(2));
                if ~isempty(f)
                    x = x(1:2,f(1));
                else
                    return
                end
            else
                x = x(1);
            end
            
            tm = (handles.triggerInfo.absTime(indx)-min(handles.triggerInfo.absTime))*(24*60*60);
            f = find(handles.triggerInfo.fileNum==handles.triggerInfo.fileNum(indx));
            trig = find(f==indx);
            if handles.triggerInfo.label(indx) == 0
                lab = 'N/A';
            elseif handles.triggerInfo.label(indx) >= 1000
                lab = num2str(handles.triggerInfo.label(indx)-1000);
            else
                lab = char(handles.triggerInfo.label(indx));
            end
            ftm = (handles.triggerInfo.absTime(indx)-handles.egh.DatesAndTimes(handles.FileList(handles.triggerInfo.fileNum(indx))))*(24*60*60);
            
            spc = repmat(' ',1,5);
            if length(x)==1
                set(handles.text_Info,'string',['Trial #: ' num2str(indx) spc 'Trial time: ' num2str(tm,4) spc 'File #: ' num2str(handles.FileList(handles.triggerInfo.fileNum(indx))) spc 'Trig #: ' num2str(trig) spc 'Trig time: ' num2str(ftm,4) spc 'Trig label: ' lab spc 'Event time: ' num2str(ftm+x,4) spc 'Event rel time: ' num2str(x,4)]);
            else
                set(handles.text_Info,'string',['Trial #: ' num2str(indx) spc 'Trial time: ' num2str(tm,4) spc 'File #: ' num2str(handles.FileList(handles.triggerInfo.fileNum(indx))) spc 'Trig #: ' num2str(trig) spc 'Trig time: ' num2str(ftm,4) spc 'Trig label: ' lab spc 'Event time: ' num2str(ftm+x(1),4) ' - ' num2str(ftm+x(2),4) spc 'Event rel time: ' num2str(x(1),4) ' - ' num2str(x(2),4)]);
            end
        end
        return
    end

    set(handles.axes_Raster,'xlim',[rect(1) rect(1)+rect(3)],'ylim',[rect(2) rect(2)+rect(4)]);
    set(handles.axes_PSTH,'xlim',[rect(1) rect(1)+rect(3)]);
    set(handles.axes_Hist,'ylim',[rect(2) rect(2)+rect(4)]);
elseif strcmp(get(gcf,'selectiontype'),'open')
    set(handles.axes_Raster,'xlim',handles.BackupXLimRaster,'ylim',handles.BackupYLimRaster);
    set(handles.axes_PSTH,'xlim',handles.BackupXLimRaster);
    set(handles.axes_Hist,'ylim',handles.BackupYLimRaster);
elseif strcmp(get(gcf,'selectiontype'),'extend')
    if strcmp(get(hObject,'type'),'text')
        delete(hObject);
    end
end

function click_PSTH(hObject, eventdata, handles)

if strcmp(get(gcf,'selectiontype'),'normal')
    set(gca,'units','pixels');
    set(get(gca,'parent'),'units','pixels');
    rect = rbbox;

    pos = get(gca,'position');
    set(get(gca,'parent'),'units','normalized');
    set(gca,'units','normalized');
    xl = xlim;
    yl = ylim;

    rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
    rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

    if rect(3) == 0 | rect(4) == 0
        return
    end

    set(handles.axes_Raster,'xlim',[rect(1) rect(1)+rect(3)]);
    set(handles.axes_PSTH,'xlim',[rect(1) rect(1)+rect(3)],'ylim',[rect(2) rect(2)+rect(4)]);
else
    set(handles.axes_Raster,'xlim',handles.BackupXLimRaster);
    set(handles.axes_PSTH,'xlim',handles.BackupXLimRaster,'ylim',handles.BackupYLimPSTH);
end


function click_Hist(hObject, eventdata, handles)

if strcmp(get(gcf,'selectiontype'),'normal')
    set(gca,'units','pixels');
    set(get(gca,'parent'),'units','pixels');
    rect = rbbox;

    pos = get(gca,'position');
    set(get(gca,'parent'),'units','normalized');
    set(gca,'units','normalized');
    xl = xlim;
    yl = ylim;

    rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
    rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

    if rect(3) == 0 | rect(4) == 0
        return
    end

    set(handles.axes_Raster,'ylim',[rect(2) rect(2)+rect(4)]);
    set(handles.axes_Hist,'xlim',[rect(1) rect(1)+rect(3)],'ylim',[rect(2) rect(2)+rect(4)]);
else
    set(handles.axes_Raster,'ylim',handles.BackupYLimRaster);
    set(handles.axes_Hist,'xlim',handles.BackupXLimHist,'ylim',handles.BackupYLimRaster);
end


function [fld_new stretch] = WarpTrial(fld,oldwarp,newwarp,method,fs,warpstr);
% warping algorithms

tol = 1/fs;

fld_new = fld;

% Events before first warp point are mapped to real time
f = find(fld < oldwarp(1)+tol);
fld_new(f) = fld(f)-oldwarp(1)+newwarp(1);

% Events after the last warp point are mapped to real time
f = find(fld >= oldwarp(end)-tol);
fld_new(f) = fld(f)-oldwarp(end)+newwarp(end);

% Events right at warp points get mapped to new warp points
for c = 1:length(oldwarp)
    f = find(fld >= oldwarp(c)-tol & fld < oldwarp(c)+tol);
    fld_new(f) = newwarp(c);
end

switch method
    case 'Linear stretch'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = newwarp(c) + (newwarp(c+1)-newwarp(c)) * (fld(f)-oldwarp(c))/(oldwarp(c+1)-oldwarp(c));
            if strcmp(warpstr,'dataStart')
                fld_new(end+1) = newwarp(c);
            end
            if strcmp(warpstr,'dataStop')
                fld_new(end+1) = newwarp(c+1);
            end
        end
        if strcmp(warpstr,'dataStart')
            fld_new(end+1) = newwarp(end);
        end
        if strcmp(warpstr,'dataStop')
            fld_new(end+1) = newwarp(1);
        end
        stretch = (newwarp(2:end)-newwarp(1:end-1))./(oldwarp(2:end)-oldwarp(1:end-1));
    case 'Align left'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = newwarp(c) + (fld(f)-oldwarp(c));
            g = find(fld_new(f)>newwarp(c+1));
            fld_new(f(g)) = inf;
            
            if newwarp(c+1)-newwarp(c) > oldwarp(c+1)-oldwarp(c)
                if strcmp(warpstr,'dataStart')
                    fld_new(end+1) = newwarp(c+1)-tol;
                end
                if strcmp(warpstr,'dataStop')
                    fld_new(end+1) = newwarp(c) + (oldwarp(c+1)-oldwarp(c));
                end
            end

        end
        stretch = ones(size(newwarp(2:end)));
    case 'Align right'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = newwarp(c+1) - (oldwarp(c+1)-fld(f));
            g = find(fld_new(f)<newwarp(c));
            fld_new(f(g)) = inf;

            if newwarp(c+1)-newwarp(c) > oldwarp(c+1)-oldwarp(c)
                if strcmp(warpstr,'dataStart')
                    fld_new(end+1) = newwarp(c+1)-(oldwarp(c+1)-oldwarp(c));
                end
                if strcmp(warpstr,'dataStop')
                    fld_new(end+1) = newwarp(c) + tol;
                end
            end

        end
        stretch = ones(size(newwarp(2:end)));
    case 'Align center'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = (newwarp(c)+newwarp(c+1))/2 - (oldwarp(c+1)-oldwarp(c))/2 + (fld(f)-oldwarp(c));
            g = find(fld_new(f)<newwarp(c) | fld_new(f)>newwarp(c+1));
            fld_new(f(g)) = inf;

            if newwarp(c+1)-newwarp(c) > oldwarp(c+1)-oldwarp(c)
                if strcmp(warpstr,'dataStart')
                    fld_new(end+1) = (newwarp(c)+newwarp(c+1))/2 - (oldwarp(c+1)-oldwarp(c))/2;
                    fld_new(end+1) = newwarp(c+1)-tol;
                end
                if strcmp(warpstr,'dataStop')
                    fld_new(end+1) = (newwarp(c)+newwarp(c+1))/2 + (oldwarp(c+1)-oldwarp(c))/2;
                    fld_new(end+1) = newwarp(c) + tol;
                end
            end

        end
        stretch = ones(size(newwarp(2:end)));
end

if strcmp(warpstr,'dataStart') | strcmp(warpstr,'dataStop')
    fld_new = sort(fld_new);
end


% --- Executes on button press in push_Colors.
function push_Colors_Callback(hObject, eventdata, handles)
% hObject    handle to push_Colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_Colors,'uicontextmenu',handles.context_Color);

% Trigger a right-click event
try
    import java.awt.*;
    import java.awt.event.*;
    rob = Robot;
    rob.mousePress(InputEvent.BUTTON3_MASK);
    pause(0.01);
    rob.mouseRelease(InputEvent.BUTTON3_MASK);
catch
    errordlg('Java is not working properly. You must right-click the button.','Java error');
end



function [funct lab indx] = getContinuousFunction(handles,filenum,axnum,doSubsample)


val = get(handles.egh.(['popup_Channel',num2str(axnum)]),'value');
str = get(handles.egh.(['popup_Channel',num2str(axnum)]),'string');
nums = [];
for c = 1:length(handles.egh.EventTimes);
    nums(c) = size(handles.egh.EventTimes{c},1);
end

if val <= length(str)-sum(nums)
    fm = find(handles.egh.Overlaps==filenum);
    if isempty(fm)
        funct = [];
    else
        true_len = [round(diff(handles.egh.DatesAndTimes(fm))*(24*60*60)*handles.egh.fs) handles.egh.FileLength(fm(end))];
        pos = [0 cumsum(true_len)];
        funct = [];
        for ovr = 1:length(fm);
            chan = str2num(str{val}(9:end));
            if length(str{val})>4 & strcmp(str{val}(1:5),'Sound')
                [funct1 fs dt lab props] = eval(['egl_' handles.egh.sound_loader '([''' handles.egh.path_name '\' handles.egh.sound_files(fm(ovr)).name '''],1)']);
            else
                [funct1 fs dt lab props] = eval(['egl_' handles.egh.chan_loader{chan} '([''' handles.egh.path_name '\' handles.egh.chan_files{chan}(fm(ovr)).name '''],1)']);
            end
            funct(pos(ovr)+1:pos(ovr)+length(funct1)) = funct1;
        end
    end
else
    ev = zeros(1,handles.egh.FileLength(filenum));
    indx = val-(length(str)-sum(nums));
    cs = cumsum(nums);
    f = length(find(cs<indx))+1;
    if f>1
        g = indx-cs(f-1);
    else
        g = indx;
    end
    tm = handles.egh.EventTimes{f}{g,filenum};
    issel = handles.egh.EventSelected{f}{g,filenum};
    ev(tm(find(issel==1))) = 1;
    funct = ev;
end

if get(handles.egh.(['popup_Function',num2str(axnum)]),'value') > 1
    str = get(handles.egh.(['popup_Function',num2str(axnum)]),'string');
    str = str{get(handles.egh.(['popup_Function',num2str(axnum)]),'value')};
    f = findstr(str,' - ');
    if isempty(f)
        [funct lab] = eval(['egf_' str '(funct,handles.egh.fs,handles.egh.FunctionParams' num2str(axnum) ')']);
    else
        strall = get(handles.(['popup_Function',num2str(axnum)]),'string');
        count = 0;
        for c = 1:get(handles.(['popup_Function',num2str(axnum)]),'value')
            count = count + strcmp(strall{c}(1:min([f-1 length(strall{c})])),str(1:f-1));
        end
        [funct lab] = eval(['egf_' str(1:f-1) '(funct,handles.egh.fs,handles.egh.FunctionParams' num2str(axnum) ')']);
        funct = funct{count};
        lab = lab{count}
    end
end

if isempty(funct)
    indx = [];
    return
end

if length(funct) < handles.egh.FileLength(filenum)
    indx = round(linspace(1,length(funct),handles.egh.FileLength(filenum)));
    funct = funct(indx);
end


if doSubsample == 1
    num_edges = ceil(length(funct)/0.5e6)+1;
    edges = round(linspace(0,length(funct),num_edges));
    if handles.P.event.contSmooth > 1
        for j = 1:length(edges)-1
            funct(edges(j)+1:edges(j+1)) = smooth(funct(edges(j)+1:edges(j+1)),handles.P.event.contSmooth);
        end
    end
    npt = round(handles.P.event.contSubsample*handles.egh.fs);
else
    npt = 1;
end

indx = 1:npt:length(funct);
indx = indx+round((length(funct)-indx(end))/2);
funct = funct(indx);

if size(funct,1)>size(funct,2)
    funct = funct';
end


% --------------------------------------------------------------------
function context_Color_Callback(hObject, eventdata, handles)
% hObject    handle to context_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Background_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

c = uisetcolor(handles.BackgroundColor,'Background color');
if length(c)<3
    return
end

handles.BackgroundColor = c;

set(handles.axes_PSTH,'color',handles.BackgroundColor);
set(handles.axes_Hist,'color',handles.BackgroundColor);
set(handles.axes_Raster,'color',handles.BackgroundColor);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_CLimits_Callback(hObject, eventdata, handles)
% hObject    handle to menu_CLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end
answer = inputdlg({'Min','Max'},'C-limits',1,{num2str(handles.CLim(1)),num2str(handles.CLim(2))});
if isempty(answer)
    return
end
handles.CLim(1) = str2num(answer{1});
handles.CLim(2) = str2num(answer{2});
set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Colormap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_SetAutoCLim_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SetAutoCLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.axes_Raster,'CLimMode','auto');
handles.CLim = get(handles.axes_Raster,'clim');

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_EditColormap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_EditColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormapeditor;


% --------------------------------------------------------------------
function menu_InvertColormap_Callback(hObject, eventdata, handles)
% hObject    handle to menu_InvertColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

col = colormap;
col = flipud(col);
colormap(col);


% --- Executes on button press in push_MinDown.
function push_MinDown_Callback(hObject, eventdata, handles)
% hObject    handle to push_MinDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(1) = handles.CLim(2) - df*1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);

% --- Executes on button press in push_MinUp.
function push_MinUp_Callback(hObject, eventdata, handles)
% hObject    handle to push_MinUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(1) = handles.CLim(2) - df/1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);

% --- Executes on button press in push_MaxDown.
function push_MaxDown_Callback(hObject, eventdata, handles)
% hObject    handle to push_MaxDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(2) = handles.CLim(1) + df/1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);

% --- Executes on button press in push_MaxUp.
function push_MaxUp_Callback(hObject, eventdata, handles)
% hObject    handle to push_MaxUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(2) = handles.CLim(1) + df*1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);


% --- Executes on selection change in popup_Correlation.
function popup_Correlation_Callback(hObject, eventdata, handles)
% hObject    handle to popup_Correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Correlation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Correlation


% --- Executes during object creation, after setting all properties.
function popup_Correlation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_Correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_LogScale_Callback(hObject, eventdata, handles)
% hObject    handle to menu_LogScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(handles.menu_LogScale,'checked'),'on')
    set(handles.menu_LogScale,'checked','off');
else
    set(handles.menu_LogScale,'checked','on');
end


% --- Executes on button press in push_Select.
function push_Select_Callback(hObject, eventdata, handles)
% hObject    handle to push_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_Select,'uicontextmenu',handles.context_Select);

% Trigger a right-click event
try
    import java.awt.*;
    import java.awt.event.*;
    rob = Robot;
    rob.mousePress(InputEvent.BUTTON3_MASK);
    pause(0.01);
    rob.mouseRelease(InputEvent.BUTTON3_MASK);
catch
    errordlg('Java is not working properly. You must right-click the button.','Java error');
end


% --------------------------------------------------------------------
function context_Select_Callback(hObject, eventdata, handles)
% hObject    handle to context_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Select1_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select2_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select3_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select4_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,4);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select5_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,5);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select6_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,6);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select7_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,7);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Select8_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,8);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select9_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,9);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select10_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,10);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select11_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,11);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select12_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,12);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select13_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,13);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Select14_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,14);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Select15_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,15);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select16_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,16);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select17_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,17);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select18_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Select18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,18);
guidata(hObject, handles);

function handles = menuSelectClick(handles,num);

if num == 2
    str1 = datestr(handles.Selection(num,1));
    str2 = datestr(handles.Selection(num,2));
else
    str1 = num2str(handles.Selection(num,1));
    str2 = num2str(handles.Selection(num,2));
end

mstr = get(handles.(['menu_Select' num2str(num)]),'Label');
answer = inputdlg({'From','To'},mstr,1,{str1,str2});
if isempty(answer)
    return
end

if num == 2
    handles.Selection(num,1) = datenum(answer{1});
    handles.Selection(num,2) = datenum(answer{2});
else
    handles.Selection(num,1) = str2num(answer{1});
    handles.Selection(num,2) = str2num(answer{2});
end


switch num
    case 1
        val = 1:length(handles.triggerInfo.absTime);
    case 2
        val = handles.triggerInfo.absTime;
    case 3
        val = handles.triggerInfo.currTrigOffset-handles.triggerInfo.currTrigOnset;
    case 4
        val = handles.triggerInfo.prevTrigOnset;
    case 5
        val = handles.triggerInfo.prevTrigOffset;
    case 6
        val = handles.triggerInfo.nextTrigOnset;
    case 7
        val = handles.triggerInfo.nextTrigOffset;
    case 8
        val = handles.FileRange(handles.triggerInfo.fileNum);
    case 9
        val = -inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOnsets{c}<0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOnsets{c}(f(end));
            end
        end
    case 10
        val = -inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOffsets{c}<0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOffsets{c}(f(end));
            end
        end
    case 11
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOnsets{c}>0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOnsets{c}(f(1));
            end
        end
    case 12
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOffsets{c}>0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOffsets{c}(f(1));
            end
        end
    case 13
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOnsets{c});
                val(c) = min(handles.triggerInfo.eventOnsets{c});
            end
        end
    case 14
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOffsets{c});
                val(c) = min(handles.triggerInfo.eventOffsets{c});
            end
        end
    case 15
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOnsets{c});
                val(c) = max(handles.triggerInfo.eventOnsets{c});
            end
        end
    case 16
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOffsets{c});
                val(c) = max(handles.triggerInfo.eventOffsets{c});
            end
        end
    case 17
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            val(c) = length(handles.triggerInfo.eventOnsets{c});
        end
    case 18
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            val(c) = (length(find(handles.triggerInfo.eventOnsets{c}<=0)) > length(find(handles.triggerInfo.eventOffsets{c}<0)));
        end
end

f = (val>=handles.Selection(num,1)-1e-5 & val<=handles.Selection(num,2)+1e-5);
handles.TriggerSelection = f.*handles.TriggerSelection;

set(handles.text_NumTriggers,'string',[num2str(sum(handles.TriggerSelection)) ' triggers']);


% --------------------------------------------------------------------
function menu_SelectLabel_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SelectLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.LabelRange)
    answer = inputdlg({'List of included labels ('''' for unlabeled). Leave empty to include all.','List of excluded labels'},'Trigger label',1,{handles.LabelSelectionInc,handles.LabelSelectionExc});
    if isempty(answer)
        return
    end

    handles.LabelSelectionInc = answer{1};
    handles.LabelSelectionExc = answer{2};

    f = findstr(handles.LabelSelectionInc,'''''');
    inc = handles.LabelSelectionInc;
    inc([f f+1]) = [];
    inc = double(inc);
    if ~isempty(f)
        inc = [inc 0];
    end

    f = findstr(handles.LabelSelectionExc,'''''');
    exc = handles.LabelSelectionExc;
    exc([f f+1]) = [];
    exc = double(exc);
    if ~isempty(f)
        exc = [exc 0];
    end

    f = zeros(1,length(handles.triggerInfo.absTime));
    for c = 1:length(handles.triggerInfo.absTime)
        if ~isempty(find(inc==handles.triggerInfo.label(c))) | isempty(inc)
            f(c) = 1;
        end
        if ~isempty(find(exc==handles.triggerInfo.label(c)))
            f(c) = 0;
        end
    end
else
    answer = inputdlg({'From','To'},'Trigger label',1,{num2str(handles.LabelRange(1)),num2str(handles.LabelRange(2))});
    if isempty(answer)
        return
    end
    handles.LabelRange(1) = str2num(answer{1});
    handles.LabelRange(2) = str2num(answer{2});
    
    f = (handles.triggerInfo.label>=handles.LabelRange(1)+1000 & handles.triggerInfo.label<=handles.LabelRange(2)+1000);
end

handles.TriggerSelection = f.*handles.TriggerSelection;

set(handles.text_NumTriggers,'string',[num2str(sum(handles.TriggerSelection)) ' triggers']);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_SelectAll_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.TriggerSelection = ones(size(handles.TriggerSelection));

set(handles.text_NumTriggers,'string',[num2str(length(handles.TriggerSelection)) ' triggers']);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_InvertSelection_Callback(hObject, eventdata, handles)
% hObject    handle to menu_InvertSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.TriggerSelection = 1-handles.TriggerSelection;

set(handles.text_NumTriggers,'string',[num2str(sum(handles.TriggerSelection)) ' triggers']);

guidata(hObject, handles);


% --- Executes on button press in push_HistHoriz.
function push_HistHoriz_Callback(hObject, eventdata, handles)
% hObject    handle to push_HistHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_HistHoriz,'fontweight','bold');
set(handles.push_HistVert,'fontweight','normal');
set(handles.check_HistShow,'value',handles.HistShow(1));

set(handles.popup_PSTHUnits,'visible','on');
set(handles.popup_PSTHCount,'visible','on');
set(handles.popup_HistUnits,'visible','off');
set(handles.popup_HistCount,'visible','off');


% --- Executes on button press in push_HistVert.
function push_HistVert_Callback(hObject, eventdata, handles)
% hObject    handle to push_HistVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_HistHoriz,'fontweight','normal');
set(handles.push_HistVert,'fontweight','bold');
set(handles.check_HistShow,'value',handles.HistShow(2));

set(handles.popup_PSTHUnits,'visible','off');
set(handles.popup_PSTHCount,'visible','off');
set(handles.popup_HistUnits,'visible','on');
set(handles.popup_HistCount,'visible','on');

% --- Executes on button press in check_HistShow.
function check_HistShow_Callback(hObject, eventdata, handles)
% hObject    handle to check_HistShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_HistShow

if strcmp(get(handles.push_HistHoriz,'fontweight'),'bold')
    handles.HistShow(1) = get(handles.check_HistShow,'value');
else
    handles.HistShow(2) = get(handles.check_HistShow,'value');
end

st = {'off','on'};
set(handles.axes_PSTH,'visible',st{handles.HistShow(1)+1});
set(get(handles.axes_PSTH,'children'),'visible',st{handles.HistShow(1)+1});
set(handles.axes_Hist,'visible',st{handles.HistShow(2)+1});
set(get(handles.axes_Hist,'children'),'visible',st{handles.HistShow(2)+1});

if handles.HistShow(1) == 1
    h = handles.AxisPosRaster(4);
else
    h = handles.AxisPosPSTH(4) + handles.AxisPosPSTH(2) - handles.AxisPosRaster(2);
end
if handles.HistShow(2) == 1
    w = handles.AxisPosRaster(3);
else
    w = handles.AxisPosHist(3) + handles.AxisPosHist(1) - handles.AxisPosRaster(1);
end

pos = get(handles.axes_Raster,'position');
pos(3) = w;
pos(4) = h;
set(handles.axes_Raster,'position',pos);

pos = get(handles.axes_PSTH,'position');
pos(3) = w;
set(handles.axes_PSTH,'position',pos);

pos = get(handles.axes_Hist,'position');
pos(4) = h;
drawnow
set(handles.axes_Hist,'position',pos);

guidata(hObject, handles);


% --- Executes on selection change in popup_HistUnits.
function popup_HistUnits_Callback(hObject, eventdata, handles)
% hObject    handle to popup_HistUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_HistUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_HistUnits


% --- Executes during object creation, after setting all properties.
function popup_HistUnits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_HistUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_HistCount.
function popup_HistCount_Callback(hObject, eventdata, handles)
% hObject    handle to popup_HistCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_HistCount contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_HistCount


% --- Executes during object creation, after setting all properties.
function popup_HistCount_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_HistCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_DeleteEvents.
function push_DeleteEvents_Callback(hObject, eventdata, handles)
% hObject    handle to push_DeleteEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

event_indx = get(handles.popup_EventList,'value');

for c = 10:12
    delete(handles.PlotHandles{c}{event_indx});
    handles.PlotHandles{c}(event_indx) = [];
end

if isempty(handles.AllEventOnsets)
    return
end

handles.AllEventOnsets(event_indx) = [];
handles.AllEventOffsets(event_indx) = [];
handles.AllEventLabels(event_indx) = [];
handles.AllEventSelections(event_indx) = [];
handles.AllEventOptions(event_indx) = [];
handles.AllEventPlots(event_indx,:) = [];

str = get(handles.popup_EventList,'string');
str(event_indx) = [];
if isempty(str)
    str = {'(None)'};
end
if get(handles.popup_EventList,'value') > length(str)
    set(handles.popup_EventList,'value',length(str));
end
set(handles.popup_EventList,'string',str);

guidata(hObject, handles);


% --- Executes on selection change in popup_EventList.
function popup_EventList_Callback(hObject, eventdata, handles)
% hObject    handle to popup_EventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_EventList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventList


% --- Executes during object creation, after setting all properties.
function popup_EventList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_EventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_WarpingOn.
function check_WarpingOn_Callback(hObject, eventdata, handles)
% hObject    handle to check_WarpingOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_WarpingOn


if get(handles.check_WarpingOn,'value')==1
    handles.WarpPoints = handles.BackupWarp;
    set(handles.list_WarpPoints,'value',1);
    set(handles.list_WarpPoints,'string',handles.BackupWarpString);
else
    handles.BackupWarp = handles.WarpPoints;
    handles.BackupWarpString = get(handles.list_WarpPoints,'string');
    set(handles.list_WarpPoints,'value',1);
    set(handles.list_WarpPoints,'string',{'(None)'});
    handles.WarpPoints = {};
end

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
end

guidata(hObject, handles);



% --------------------------------------------------------------------
function context_MatlabExport_Callback(hObject, eventdata, handles)
% hObject    handle to context_MatlabExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_8_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_AutoColor.
function push_AutoColor_Callback(hObject, eventdata, handles)
% hObject    handle to push_AutoColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.popup_TriggerType,'string');
is_syllable = strcmp(str{get(handles.popup_TriggerType,'value')},'Syllables');

if ~isempty(handles.P.trig.includeSyllList) & is_syllable == 1
    inc = handles.P.trig.includeSyllList;
    inc = double(inc);
    f = findstr(inc,'''''');
    if ~isempty(f)
        inc(f+1) = [];
        inc(f) = 0;
    end
else
    inc = unique(handles.triggerInfo.label);
end

if ~isempty(handles.P.trig.ignoreSyllList) & is_syllable == 1
    exc = handles.P.trig.ignoreSyllList;
    exc = double(exc);
    f = findstr(exc,'''''');
    if ~isempty(f)
        exc(f+1) = [];
        exc(f) = 0;
    end
    for c = 1:length(exc)
        inc(find(inc==exc(c))) = [];
    end
end

if isempty(handles.PlotAutoColors)
    handles.PlotAutoColors = hsv(length(inc));
end

answ = 0;
val = get(handles.list_Plot,'value');
if handles.PlotContinuous(val)==1
    errordlg('Auto colors cannot be set for continuous objects!','Error');
    return
end

islast = 0;
while islast == 0
    str = {};
    for c = 1:size(handles.PlotAutoColors,1)
        hx = dec2hex(round(255*handles.PlotAutoColors(c,3)) + round(256*255*handles.PlotAutoColors(c,2)) + round(256^2*255*handles.PlotAutoColors(c,1)));
        if length(hx)< 6
            hx = [repmat('0',1,6-length(hx)) hx];
        end
        str{c} = ['<HTML>Change <FONT COLOR=' hx '>color #' num2str(c) '</FONT></HTML>'];
    end
    str{end+1} = ' ';
    str{end+1} = 'Set default colors';
    str{end+1} = 'Set number of colors';
    str{end+1} = ' ';
    str{end+1} = 'Remove first color';
    str{end+1} = 'Remove last color';
    str{end+1} = 'Add one color';
    str{end+1} = ' ';
    str{end+1} = 'Auto sort colors';
    str{end+1} = 'Permute up';
    str{end+1} = 'Permute down';
    str{end+1} = 'Flip color list';
    str{end+1} = ' ';
    str{end+1} = 'Apply current colors';
    
    [answ,ok] = listdlg('ListString',str,'Name','Auto color','PromptString','Select one of the options','SelectionMode','single','InitialValue',length(str));
    if ok==0
        return
    end
    
   indx = answ - size(handles.PlotAutoColors,1);
   switch indx
       case 1
           
       case 2
           handles.PlotAutoColors = hsv(length(inc));
       case 3
           answer = inputdlg({'Number of colors'},'Auto colors',1,{num2str(size(handles.PlotAutoColors,1))});
           if ~isempty(answer)
               handles.PlotAutoColors = hsv(str2num(answer{1}));
           end
       case 4
           
       case 5
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors(1,:) = [];
           end
       case 6
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors(end,:) = [];
           end
       case 7
           handles.PlotAutoColors(end+1,:) = handles.PlotColor(val,:);
       case 8
           
       case 9
           srt = zeros(size(inc));
           for c = 1:length(inc)
               srt(c) = mean(find(handles.triggerInfo.label==inc(c)));
           end
           [srt ord] = sort(srt);
           [srt ord] = sort(ord);
           if size(handles.PlotAutoColors,1)>=length(ord)
               handles.PlotAutoColors(1:length(ord),:) = handles.PlotAutoColors(ord,:);
           else
               num = ceil(length(ord)/size(handles.PlotAutoColors,1));
               handles.PlotAutoColors = repmat(handles.PlotAutoColors,num,1);
               handles.PlotAutoColors(length(ord)+1:end,:) = [];
               handles.PlotAutoColors = handles.PlotAutoColors(ord,:);
           end
       case 10
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors = handles.PlotAutoColors([2:end 1],:);
           end
       case 11
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors = handles.PlotAutoColors([end 1:end-1],:);
           end
       case 12
           handles.PlotAutoColors = flipud(handles.PlotAutoColors);
       case 13
           
       case 14
           % apply current colors
       otherwise
           c = uisetcolor(handles.PlotAutoColors(answ,:),['Color #' num2str(answ)]);
           if length(c)==3
               handles.PlotAutoColors(answ,:) = c;
           end
   end
   
   islast = (answ == length(str));
end

lab = inf*ones(1,length(handles.triggerInfo.label));
for c = 1:length(handles.triggerInfo.label)
    f = find(inc == handles.triggerInfo.label(c));
    if ~isempty(f)
        lab(c) = f;
    end
end
md = mod(lab,size(handles.PlotAutoColors,1));
md(find(md==0)) = size(handles.PlotAutoColors,1);

legend_str = '';
for c = 1:length(inc)
    colindx = mod(c,size(handles.PlotAutoColors,1));
    if colindx == 0
        colindx = size(handles.PlotAutoColors,1);
    end
    if inc(c) == 0
        lb = ' Unlabeled ';
    elseif is_syllable == 1
        lb = [' ' char(inc(c)) ' '];
    else
        lb = [' ' num2str(inc(c)-1000) ' '];
    end
    legend_str =  [legend_str '\color[rgb]{' num2str(handles.PlotAutoColors(colindx,:)) '}' lb];
end
subplot(handles.axes_Raster);
delete(findobj(gca,'type','text'));
xl = xlim;
yl = ylim;
tx = text(xl(2),yl(2),legend_str,'HorizontalAlignment','Right','VerticalAlignment','Top');
set(tx,'fontsize',10,'fontweight','bold','units','normalized');
set(tx,'backgroundcolor',handles.BackgroundColor);
set(tx,'buttondownfcn',get(handles.axes_Raster,'buttondownfcn'));


for m = 1:size(handles.PlotAutoColors,1)
    selection = (md==m);
    event_indx = get(handles.popup_EventList,'value');

    if val == 10 | val == 11 | val ==12
        indx2 = cumsum(cellfun('length',handles.AllEventOnsets{event_indx}));
        indx1 = [1 indx2(1:end-1)+1];
        indx = [];
        for c = find(selection==1)
            indx = [indx indx1(c):indx2(c)];
        end
    else
        indx = find(selection==1);
    end

    for c = intersect([1 2 4 5 7 8 13 15 16 19 20 22 23 25 26 28 29],val)
        set(handles.PlotHandles{c}(:,indx),'color',handles.PlotAutoColors(m,:));
    end
    for c = intersect([10 11],val)
        if ~isempty(handles.PlotHandles{c}{event_indx})
            set(handles.PlotHandles{c}{event_indx}(indx),'color',handles.PlotAutoColors(m,:));
        end
    end
    for c = intersect([14 30],val)
        set(handles.PlotHandles{c},'facecolor',handles.PlotAutoColors(m,:),'edgecolor',handles.PlotAutoColors(m,:));
    end
    for c = intersect([3 6 9 12 17 18 21 24 27],val)
        if iscell(handles.PlotHandles{c})
            h = handles.PlotHandles{c}{event_indx};
        else
            h = handles.PlotHandles{c};
        end
        if ~isempty(h)
            cdt = get(h,'cdata');
            if length(size(cdt))==3
                sz = [length(indx) 1];
                cdt(indx,1,:) = cat(3,handles.PlotAutoColors(m,1)*ones(sz),handles.PlotAutoColors(m,2)*ones(sz),handles.PlotAutoColors(m,3)*ones(sz));
                set(h,'cdata',cdt);
            else
                set(h,'facecolor',handles.PlotAutoColors(m,:));
            end
        end
    end
end

guidata(hObject, handles);


% --- Executes on button press in check_GroupLabels.
function check_GroupLabels_Callback(hObject, eventdata, handles)
% hObject    handle to check_GroupLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_GroupLabels

handles = AutoInclude(handles);
guidata(hObject, handles);

% --- Executes on button press in push_MatlabExport.
function push_MatlabExport_Callback(hObject, eventdata, handles)
% hObject    handle to push_MatlabExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_Colors,'uicontextmenu',handles.context_MatlabExport);

% Trigger a right-click event
try
    import java.awt.*;
    import java.awt.event.*;
    rob = Robot;
    rob.mousePress(InputEvent.BUTTON3_MASK);
    pause(0.01);
    rob.mouseRelease(InputEvent.BUTTON3_MASK);
catch
    errordlg('Java is not working properly. You must right-click the button.','Java error');
end



% --- Executes on button press in check_AutoInclude.
function check_AutoInclude_Callback(hObject, eventdata, handles)
% hObject    handle to check_AutoInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_AutoInclude


handles = AutoInclude(handles);
guidata(hObject, handles);


function handles = AutoInclude(handles)

if get(handles.check_AutoInclude,'value')==0
    return
end

str = get(handles.popup_PrimarySort,'string');
str1 = str{get(handles.popup_PrimarySort,'value')};
str = get(handles.popup_SecondarySort,'string');
str2 = str{get(handles.popup_SecondarySort,'value')};

if get(handles.check_GroupLabels,'value')==1 | ~strcmp(str2,'Absolute time')
    str = str2;
else
    str = str1;
end

str_obj = get(handles.list_Plot,'string');
for c = [1 2 4 5 7 8]
    str_curr = str_obj{c};
    if strcmp(str_obj{c}(26:end-14),str)
        handles.PlotInclude(c) = 1;
    else
        handles.PlotInclude(c) = 0;
    end
end
if strcmp(str,'Trigger duration')
    for c = [4 5]
        handles.PlotInclude(c) = 1;
    end
end
str = get(handles.popup_TriggerAlignment,'string');
str = str{get(handles.popup_TriggerAlignment,'value')};
if strcmp(str,'Onset')
    handles.PlotInclude(4) = 1;
end
if strcmp(str,'Offset')
    handles.PlotInclude(5) = 1;
end

for c = [1 2 4 5 7 8]
    if handles.PlotInclude(c)==1
        str_obj{c}(19:24) = 'FF0000';
    else
        str_obj{c}(19:24) = '000000';
    end
end

set(handles.list_Plot,'string',str_obj);
set(handles.check_PlotInclude,'value',handles.PlotInclude(get(handles.list_Plot,'value')));


% --- Executes on button press in check_SkipSorting.
function check_SkipSorting_Callback(hObject, eventdata, handles)
% hObject    handle to check_SkipSorting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_SkipSorting


function handles = Fix_Overlap(handles)

handles.Overlaps = 1:length(handles.DatesAndTimes);

answer = inputdlg({'File overlap tolerance (sec). Press cancel to omit fixing overlaps.'},'File overlaps',1,{num2str(handles.overlaptolerance)});
if isempty(answer)
    return
end

handles.overlaptolerance = str2num(answer{1});
tol = handles.overlaptolerance*handles.fs;

for c = length(handles.DatesAndTimes)-1:-1:1
    if handles.FileLength(c)==0 | handles.FileLength(c+1)==0 % files unanalyzed
        continue
    end
    
    if handles.DatesAndTimes(c) + (handles.FileLength(c) + tol)/(24*60*60)/handles.fs > handles.DatesAndTimes(c+1)
        handles.SegmentTimes{c} = [handles.SegmentTimes{c}; handles.SegmentTimes{c+1}+round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs)];
        handles.SegmentTimes{c+1} = zeros(0,2);
        handles.SegmentTitles{c} = [handles.SegmentTitles{c} handles.SegmentTitles{c+1}];
        handles.SegmentTitles{c+1} = {};
        handles.SegmentSelection{c} = [handles.SegmentSelection{c} handles.SegmentSelection{c+1}];
        handles.SegmentSelection{c+1} = [];
        for d = 1:length(handles.EventTimes)
            for e = 1:size(handles.EventTimes{d},1)
                handles.EventTimes{d}{e,c} = [handles.EventTimes{d}{e,c}; handles.EventTimes{d}{e,c+1}+round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs)];
                handles.EventTimes{d}{e,c+1} = [];
                handles.EventSelected{d}{e,c} = [handles.EventSelected{d}{e,c} handles.EventSelected{d}{e,c+1}];
                handles.EventSelected{d}{e,c+1} = [];
            end
        end
        handles.FileLength(c) = round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs + handles.FileLength(c+1));
        
        handles.Overlaps(find(handles.Overlaps==c+1)) = c;
    end
    
end

for c = 1:length(handles.DatesAndTimes)
    [dummy ord] = sortrows(handles.SegmentTimes{c});
    handles.SegmentTimes{c} = handles.SegmentTimes{c}(ord,:);
    handles.SegmentTitles{c} = handles.SegmentTitles{c}(ord);
    handles.SegmentSelection{c} = handles.SegmentSelection{c}(ord);
    
    for d = 1:length(handles.EventTimes)
        [dummy ord] = sort(handles.EventTimes{d}{1,c});
        for e = 1:size(handles.EventTimes{d},1)
            handles.EventTimes{d}{e,c} = handles.EventTimes{d}{e,c}(ord);
            handles.EventSelected{d}{e,c} = handles.EventSelected{d}{e,c}(ord);
        end
    end
    
    % Syllable overlaps
    for d = size(handles.SegmentTimes{c},1)-1:-1:1
        f = find((1:size(handles.SegmentTimes{c},1))' > d & handles.SegmentTimes{c}(d,2) > handles.SegmentTimes{c}(:,1));
        if ~isempty(f)
            handles.SegmentTimes{c}(d,1) = min(handles.SegmentTimes{c}(d:max(f),1));
            handles.SegmentTimes{c}(d,2) = max(handles.SegmentTimes{c}(d:max(f),2));
            handles.SegmentTimes{c}(d+1:max(f),:) = [];
            handles.SegmentTitles{c}(d+1:max(f)) = [];
            handles.SegmentSelection{c}(d+1:max(f)) = [];
        end
    end
    
    % Event overlaps
    for d = 1:length(handles.EventTimes)
        for e = length(handles.EventTimes{d}{1,c})-1:-1:1
            if handles.EventTimes{d}{1,c}(e+1)-handles.EventTimes{d}{1,c}(e) < tol
                for i = 1:size(handles.EventTimes{d},1)
                    handles.EventTimes{d}{i,c}(e+1) = [];
                    handles.EventSelected{d}{i,c}(e+1) = [];
                end
            end
        end
    end
end


% --------------------------------------------------------------------
function menu_ExportData_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ExportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[file, path] = uiputfile('raster.mat','Save trigger info');
if ~isstr(file)
    return
end

triggerInfo = handles.triggerInfo;

triggerInfo.eventOnsets = handles.AllEventOnsets;
triggerInfo.eventOffsets = handles.AllEventOffsets;
triggerInfo.eventLabels = handles.AllEventLabels;
triggerInfo.eventNames = get(handles.popup_EventList,'string')';
for c = 1:length(triggerInfo.eventNames)
    f = findstr(triggerInfo.eventNames{c},'Syllables');
    if ~isempty(f)
        triggerInfo.eventNames{c} = '[Syllables] Sound';
    else
        f = findstr(triggerInfo.eventNames{c},'-');
        triggerInfo.eventNames{c} = triggerInfo.eventNames{c}(1:f(end)-2);
    end
end

triggerInfo.eventOptions = handles.AllEventOptions;

triggerInfo.filterNames = get(handles.list_Filter,'string');
f = find(handles.P.filter(:,1)>-inf | handles.P.filter(:,2)<inf);
triggerInfo.filterNames = triggerInfo.filterNames(f);
triggerInfo.filterLimits = handles.P.filter(f,:);

str = get(handles.popup_TriggerType,'string');
tr_str = str{get(handles.popup_TriggerType,'value')};
str = get(handles.popup_TriggerSource,'string');
tr_str = ['[' tr_str '] ' str{get(handles.popup_TriggerSource,'value')}];
triggerInfo.trigName = tr_str;
triggerInfo.trigOptions = handles.P.trig;
str = get(handles.popup_TriggerAlignment,'string');
triggerInfo.trigAlignment = str{get(handles.popup_TriggerAlignment,'value')};
triggerInfo.trigSelection = handles.AllEventSelections;

W = {};
str = get(handles.popup_WarpingAlgorithm,'string');
W.algorithm = str{get(handles.popup_WarpingAlgorithm,'value')};
W.maxCorrShift = handles.corrMax;
pos = [handles.WarpIntervalLim(1):-1 1:handles.WarpIntervalLim(2)];
str = {'Mean','Median','Maximum','Custom'};
W.intervals.numBefore = handles.WarpNumBefore;
W.intervals.numAfter = handles.WarpNumAfter;
W.intervals.types = str(handles.WarpIntervalType);
W.intervals.customDurations = handles.WarpIntervalDuration;
W.intervals.customDurations(find(handles.WarpIntervalType<4)) = NaN;

f = find(pos<-handles.WarpNumBefore | pos>handles.WarpNumAfter);
W.intervals.types(f) = [];
W.intervals.customDurations(f) = [];
pos(f) = [];

for c = -1:-1:-handles.WarpNumBefore
    if isempty(find(pos==c))
        W.intervals.types = ['Mean' W.intervals.types];
        W.intervals.customDurations = [NaN W.intervals.customDurations];
    end
end
for c = 1:handles.WarpNumAfter
    if isempty(find(pos==c))
        W.intervals.types = [W.intervals.types 'Mean'];
        W.intervals.customDurations = [W.intervals.customDurations NaN];
    end
end

W.points = {};
for c = 1:length(handles.WarpPoints);
    str = get(handles.popup_TriggerSource,'string');
    W.points{c}.name = ['[' handles.WarpPoints{c}.type '] ' str{handles.WarpPoints{c}.source+1}];
    W.points{c}.alignment = handles.WarpPoints{c}.alignment;
    W.points{c}.options = handles.WarpPoints{c}.P;
end
triggerInfo.warpOptions = W;

str = get(handles.popup_PrimarySort,'string');
triggerInfo.sortOptions.primary.name = str{get(handles.popup_PrimarySort,'value')};
triggerInfo.sortOptions.primary.isDescending = get(handles.check_PrimaryDescending,'value');
triggerInfo.sortOptions.primary.groupLabels = get(handles.check_GroupLabels,'value');
str = get(handles.popup_SecondarySort,'string');
triggerInfo.sortOptions.secondary.name = str{get(handles.popup_SecondarySort,'value')};
triggerInfo.sortOptions.secondary.isDescending = get(handles.check_SecondaryDescending,'value');

str = get(handles.popup_StartReference,'string');
triggerInfo.windowOptions.startRef = str{get(handles.popup_StartReference,'value')};
triggerInfo.windowOptions.preStartRef = handles.P.preStartRef;
str = get(handles.popup_StopReference,'string');
triggerInfo.windowOptions.stopRef = str{get(handles.popup_StopReference,'value')};
triggerInfo.windowOptions.postStopRef = handles.P.postStopRef;

triggerInfo.windowOptions.excludePartialWindows = get(handles.check_ExcludeIncomplete,'value');
triggerInfo.windowOptions.excludeParialEvents = get(handles.check_ExcludePartialEvents,'value');

str = get(handles.popup_Correlation,'string');
triggerInfo.corrAlignment = str{get(handles.popup_Correlation,'value')};

if isfield(triggerInfo,'contLabel')
    triggerInfo = rmfield(triggerInfo,'contLabel');
end

triggerInfo.filteredEvents = handles.filteredEvents;
triggerInfo.sortedEvents = handles.sortedEvents;

trigInfo = orderfields(triggerInfo,[23:25 21:22 31 2 4:5 29 3 6:7 8:13 26 19:20 14:16 30 1 17:18 27:28 32]);

save([path file],'trigInfo');



% --------------------------------------------------------------------
function menu_ExportFigure_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ExportFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fig = figure;

ax = copyobj(handles.axes_Raster,fig);
if handles.HistShow(1) == 1
    h = .6;
else
    h = .85;
end
if handles.HistShow(2) == 1
    w = .6;
else
    w = .85;
end
set(ax,'position',[.1 .1 w h]);
set(ax,'buttondownfcn','');
set(get(ax,'children'),'buttondownfcn','');

if handles.HistShow(1) == 1
    ax = copyobj(handles.axes_PSTH,fig);
    set(ax,'position',[.1 .75 w .2]);
    set(ax,'buttondownfcn','');
    set(get(ax,'children'),'buttondownfcn','');
end

if handles.HistShow(2) == 1
    ax = copyobj(handles.axes_Hist,fig);
    set(ax,'position',[.75 .1 .2 h]);
    set(ax,'buttondownfcn','');
    set(get(ax,'children'),'buttondownfcn','');
end


% --- Executes during object creation, after setting all properties.
function push_GenerateRaster_CreateFcn(hObject, eventdata, handles)
% hObject    handle to push_GenerateRaster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


