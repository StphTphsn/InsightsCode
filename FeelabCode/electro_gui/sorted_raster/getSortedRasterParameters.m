function p = getSortedRasterParameters(handleOrGuidata)
%GETSOREDRASTERPARAMETERS Parameter struct for egm_Sorted_rasters
%
%This function returns a struct containing all the parameters that describe
%the current settings in the egm_Sorted_raster GUI. This parameter struct
%can be passed to the sorted_rasters function to recreate the raster. 
%
%Recommended use: Use egm_Sorted_rasters to automatically generate code and
%parameters to reproduce the currently displayed raster. Click the 'Matlab
%export' button in the 'Exporting panel' at the bottom of the GUI, and then
%choose 'Code'.
%
%Syntax:
%    PARAMS = GETSORTEDRASTERPARAMETERS(H)
%    PARAMS = GETSORTEDRASTERPARAMETERS(HANDLES)
%
%Output:
%    PARAMS     is a struct containing parameters from egm_Sorted_rasters.
%               For a full list of the parameters, see the list below
%
%Input:
%    H          is a handle to the egm_Sorted_rasters figure
%    HANDLES    is the guidata for egm_Sorted_rasters
%
%
%See also: SORTED_RASTERS, SORTEDRASTERPARAMETERS

if ishandle(handleOrGuidata)
    handles = guidata(handleOrGuidata);
elseif isstruct(handleOrGuidata) % is guidata
    handles = handleOrGuidata;
else
    error('Input must be handle to egm_Sorted_rasters.fig or its guidata')
end
    

% Miscellaneous
if get(handles.check_HoldOn, 'Value') == 1
    p.Hold = 'on';
else
    p.Hold = 'off';
end
p.FileRange = handles.FileRange;
p.BackgroundColor = handles.BackgroundColor;

% Sources
p.TriggerSource = getSource(handles.popup_TriggerSource);
p.EventSource   = getSource(handles.popup_EventSource);
p.TriggerType   = getSelectedString(handles.popup_TriggerType);
p.EventType     = getSelectedString(handles.popup_EventType);
p.Alignment     = getSelectedString(handles.popup_TriggerAlignment);

% Source options
p.TriggerSyllIncluded     = handles.P.trig.includeSyllList;
p.TriggerSyllExcluded     = handles.P.trig.ignoreSyllList;
p.TriggerMotifSequence    = handles.P.trig.motifSequences;
p.TriggerMotifMaxGap      = handles.P.trig.motifInterval;
p.TriggerBoutInterval     = handles.P.trig.boutInterval;
p.TriggerBoutMinDuration  = handles.P.trig.boutMinDuration;
p.TriggerBoutMinSyllCount = handles.P.trig.boutMinSyllables;
p.TriggerBurstMinFreq     = handles.P.trig.burstFrequency;
p.TriggerBurstMinCount    = handles.P.trig.burstMinSpikes;
p.TriggerPauseMinDuration = handles.P.trig.pauseMinDuration;
p.EventSyllIncluded       = handles.P.event.includeSyllList;
p.EventSyllExcluded       = handles.P.event.ignoreSyllList;
p.EventMotifSequence      = handles.P.event.motifSequences;
p.EventMotifMaxGap        = handles.P.event.motifInterval;
p.EventBoutInterval       = handles.P.event.boutInterval;
p.EventBoutMinDuration    = handles.P.event.boutMinDuration;
p.EventBoutMinSyllCount   = handles.P.event.boutMinSyllables;
p.EventBurstMinFreq       = handles.P.event.burstFrequency;
p.EventBurstMinCount      = handles.P.event.burstMinSpikes;
p.EventPauseMinDuration   = handles.P.event.pauseMinDuration;

% Filtering
p.FilterByTriggerDuration   = handles.P.filter( 1, :);
p.FilterByPrevTriggerOnset  = handles.P.filter( 2, :);
p.FilterByPrevTriggerOffset = handles.P.filter( 3, :);
p.FilterByNextTriggerOnset  = handles.P.filter( 4, :);
p.FilterByNextTriggerOffset = handles.P.filter( 5, :);
p.FilterByPrevEventOnset    = handles.P.filter( 6, :);
p.FilterByPrevEventOffset   = handles.P.filter( 7, :);
p.FilterByNextEventOnset    = handles.P.filter( 8, :);
p.FilterByNextEventOffset   = handles.P.filter( 9, :);
p.FilterByFirstEventOnset   = handles.P.filter(10, :);
p.FilterByFirstEventOffset  = handles.P.filter(11, :);
p.FilterByLastEventOnset    = handles.P.filter(12, :);
p.FilterByLastEventOffset   = handles.P.filter(13, :);
p.FilterByNumberOfEvents    = handles.P.filter(14, :);
p.FilterByIsInEvent         = handles.P.filter(15, :);

% Window
p.SkipSorting = get(handles.check_SkipSorting, 'Value');
p.LockLimitsToTrigger = get(handles.check_LockLimits, 'Value');
p.ExcludePartialWindows = get(handles.check_ExcludeIncomplete, 'Value');
p.ExcludePartialEvents = get(handles.check_ExcludePartialEvents, 'Value');
p.WindowLimits(1) = handles.P.preStartRef;
p.WindowLimits(2) = handles.P.postStopRef;
p.StartReference = getSelectedString(handles.popup_StartReference);
p.StopReference = getSelectedString(handles.popup_StopReference);

% Exporting
p.ExportHeightUnits = getSelectedString(handles.panel_ExportHeight);
p.ExportWidthUnits  = getSelectedString(handles.panel_ExportWidth);
p.ExportPSTHHeight = handles.ExportPSTHHeight;
p.ExportHistHeight = handles.ExportHistHeight;
p.ExportInterval   = handles.ExportInterval;
p.ExportResolution = handles.ExportResolution;
p.ExportWidth = getExportWidth(handles.fig_Main);
p.ExportHeight = getExportHeight(handles.fig_Main);

% Sorting
p.PrimarySortBy = getSelectedString(handles.popup_PrimarySort);
p.PrimarySortDirection = getPrimarySortDirection(handles.fig_Main);
p.PrimarySortGroupLabels = get(handles.check_GroupLabels, 'Value');
p.SecondarySortBy = getSelectedString(handles.popup_SecondarySort);
p.SecondarySortDirection = getSecondarySortDirection(handles.fig_Main);

% Raster
for ii = 1:length(get(handles.list_Plot, 'String'))
    p.RasterElements(ii) = getRasterElement(handles.fig_Main, ii);
end
p.RasterXLim = handles.PlotXLim;
p.RasterXLimAuto = get(handles.check_CopyWindow, 'Value');
p.RasterTrialHeight = getTrialHeight(handles);
p.RasterTrialHeightUnits = getSelectedString(handles.panel_TickUnits);
p.RasterTrialOverlap = handles.PlotOverlap;
p.RasterInchesPerSec = handles.PlotInPerSec;
p.RasterYAxis = getSelectedString(handles.panel_YAxis);

% PSTH
vals = getHistOptionDefaults(handles.fig_Main, 'psth');
p.PsthShow = handles.HistShow(1);
p.PsthBinSize = str2double(vals{1});
p.PsthYLim = [str2double(vals{3}), str2double(vals{4})];
p.PsthSmoothing = str2double(vals{2});
p.PsthYUnits = getSelectedString(handles.popup_PSTHUnits);
p.PsthCount = getSelectedString(handles.popup_PSTHCount);

% Vertical histogram
vals = getHistOptionDefaults(handles.fig_Main, 'vert');
p.VerticalHistogramShow = handles.HistShow(2);
p.VerticalHistogramBinSize = str2double(vals{1});
p.VerticalHistogramYLim = [str2double(vals{5}), str2double(vals{6})];
p.VerticalHistogramSmoothing = str2double(vals{2});
p.VerticalHistogramYUnits = getSelectedString(handles.popup_HistUnits);
p.VerticalHistogramCount = getSelectedString(handles.popup_HistCount);
p.VerticalHistogramROI = [str2double(vals{3}), str2double(vals{4})];

if get(handles.radio_PSTHManual, 'Value') == 1
    p.HistogramYLimMode = 'Manual';
else
    p.HistogramYLimMode = 'Auto';
end