function varargout = egm_cross_correlation(varargin)
% EGM_CROSS_CORRELATION MATLAB code for egm_cross_correlation.fig
%      EGM_CROSS_CORRELATION, by itself, creates a new EGM_CROSS_CORRELATION or raises the existing
%      singleton*.
%
%      H = EGM_CROSS_CORRELATION returns the handle to a new EGM_CROSS_CORRELATION or the handle to
%      the existing singleton*.
%
%      EGM_CROSS_CORRELATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EGM_CROSS_CORRELATION.M with the given input arguments.
%
%      EGM_CROSS_CORRELATION('Property','Value',...) creates a new EGM_CROSS_CORRELATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before egm_cross_correlation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to egm_cross_correlation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help egm_cross_correlation

% Last Modified by GUIDE v2.5 28-Mar-2014 16:37:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @egm_cross_correlation_OpeningFcn, ...
                   'gui_OutputFcn',  @egm_cross_correlation_OutputFcn, ...
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


% --- Executes just before egm_cross_correlation is made visible.
function egm_cross_correlation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to egm_cross_correlation (see VARARGIN)

% Copy ElectroGui handles
handles.egh = varargin{1};
handles.BackupHandles = handles.egh;

handles.FileRange = 1:handles.egh.TotalFileNumber;

dbase = handles.egh.dbase; 

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

handles.filenum = str2num(get(handles.egh.edit_FileNumber,'string')); % get current file number
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

str = {'Sound' '1' '2' '3' '4' '5' '6' '7'}; 
set(handles.popupmenu1, 'string', str)
set(handles.popupmenu2, 'string', str)

% setting default max lag
handles.maxlag = 3;
set(handles.edit1, 'String', num2str(handles.maxlag));

% setting default smoothing window
handles.smoothwin = .0025; 
set(handles.edit3, 'String', num2str(handles.smoothwin)); 

% make option to calculate for multiple files
set(handles.edit2, 'String', num2str(handles.filenum)); 
handles.filerange = handles.filenum; 

% Choose default command line output for egm_cross_correlation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes egm_cross_correlation wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = egm_cross_correlation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.BackupHandles;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
%set(handles.popupmenu1,'value',1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

%set(handles.popupmenu2,'value',1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fs = handles.egh.fs;
lims = get(handles.egh.axes_Sonogram, 'xlim');
if lims(1) < 1/fs;
    lims(1) = 1/fs;
end
if lims(2)*fs > numel(handles.egh.sound)
    lims(2) = numel(handles.egh.sound)/fs
end

indxA = get(handles.popupmenu1, 'value')-1;
indxB = get(handles.popupmenu2, 'value')-1;
maxlag = round(fs)*handles.maxlag; 
CC = zeros(length(-maxlag:maxlag),1); 
for filei = handles.filerange
    % load channel A
    if indxA == 0
        [A fsA dt label props] = eval(['egl_' handles.egh.sound_loader ...
            '([''' handles.egh.path_name filesep handles.egh.sound_files(filei).name '''],1)']);
    else
        [A fsA dt label props] = eval(['egl_' handles.egh.chan_loader{indxA} ...
            '([''' handles.egh.path_name filesep handles.egh.chan_files{indxA}(filei).name '''],1)']);
    end

    % load channel B
    if indxB == 0
        [B fsB dt label props] = eval(['egl_' handles.egh.sound_loader ...
            '([''' handles.egh.path_name filesep handles.egh.sound_files(filei).name '''],1)']);
    else
        [B fsB dt label props] = eval(['egl_' handles.egh.chan_loader{indxB} ...
            '([''' handles.egh.path_name filesep handles.egh.chan_files{indxB}(filei).name '''],1)']);
    end

    % ind_time = lims(1):1/fs:lims(2);
    % song = handles.egh.sound(round(ind_time*fs));
    % units = handles.egh.chan1(round(ind_time*fs));
    %[handles.(['chan',num2str(axnum)]) fs dt handles.(['Label',num2str(axnum)]) props] = eval(['egl_' handles.chan_loader{chan} '([''' handles.path_name filesep handles.chan_files{chan}(filenum).name '''],1)']);
    % time = 0:1/fs:(lims(2)-lims(1));
    A = (log(conv(A.^2, gausswin(ceil(handles.egh.fs*handles.smoothwin)), 'same')));
    A = A - mean(A); 
    B = (log(conv(B.^2, gausswin(ceil(handles.egh.fs*handles.smoothwin)), 'same')));
    B = B - mean(B); 
    [C, lags] = xcorr(A,B, maxlag, 'coeff'); 
    CC = CC + C/length(handles.filerange); 
end
figure; plot(lags/fs,CC, 'k');
xlabel('Lag (s)');
ylabel('Correlation (au)'); 

%[funct triggerInfo.contLabel fxs] = getContinuousFunction(handles, 0,indx,1)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

handles.maxlag = str2double(get(hObject,'String')); 
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(handles.edit1, 'String', '3')
% 
% % --- Executes on selection change in listbox2.
% function listbox2_Callback(hObject, eventdata, handles)
% % hObject    handle to listbox2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from listbox2
% 
% 
% % --- Executes during object creation, after setting all properties.
% function listbox2_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to listbox2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: listbox controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
temp = get(hObject,'String')
handles.filerange = eval(temp); 
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.smoothwin = str2double(get(hObject,'String')); 
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
