function handles = defaults_emackev(handles)
% Default settings

% GENERAL SETTINGS
handles.TooLong = 400000; % Number of points for a file to be considered too long for loading automatically
handles.FileString = '*.dat';%'*chan#.dat'; % File search string; use # to indicate channel number
handles.DefaultFileLoader = 'AA_daq'; % Default file loader. Choose from egl_* files.
handles.DefaultChannelNumber = 7; % Default number of channels

% SONOGRAM SETTINGS
handles.SonogramAutoCalculate = 1; % Automatically calculate and plot the sonogram when a file is loaded or axes changed?
handles.FreqLim = [500 7500]; % Frequency axis limits (Hz)
handles.AllowFrequencyZoom = 0; % Allow user to zoom along the frequency axis by dragging a box over the sonogram?
handles.SonogramClim = [18 28]; % Minimum and maximum color saturation values for power spectra
handles.DerivativeSlope = 0; % Brighness of spectral derivatives - values are divided by 10^slope
handles.DerivativeOffset = 0; % Minimum saturation value for spectral derivatives
handles.BackgroundColors = [0 0 0; 0.5 0.5 0.5]; % Background colors for sonograms. 1st row - for power spectra; 2nd row - for spectral derivatives
handles.DefaultSonogramPlotter = 'AAquick_sonogram'; % Algorithm to use for plotting sonograms. Choose from egs_* files.
handles.OverlayTop = 0; % Overlay the top plot over the sonogram?
handles.OverlayBottom = 0; % Overlay the bottom plot over the sonogram?

% AMPLITUDE SETTINGS
handles.DefaultFilter = 'BandPass860to8600'; % Filter to use for calculating sound amplitudes. Choose from egf_* files.
handles.AmplitudeLims = [0 50]; % Y-axis limits for the amplitude plot
handles.SmoothWindow = 0.0025; % Smoothing window (sec) for calculating amplitude
handles.AmplitudeColor = [0 0 0]; % Color of the amplitude plot
handles.AmplitudeThresholdColor = [1 0 0]; % Color of the threshold line on the amplitude plot
handles.AmplitudeDontPlot = 0; % Should the amplitude plot and segmentation be omitted?

% SEGMENTATION SETTINGS
handles.AmplitudeSource = 0; % What should be used as the curve for segmentation? 0 - sound amplitude; 1 - top plot; 2 - bottom plot
handles.AmplitudeAutoThreshold = 1; % Should the threshold for segmentation be chosen automatically, or carry over the current threshold?
handles.DefaultSegmenter = 'DA_segmenter'; % Algorithm to use for segmentation. Choose from egg_* files.
handles.AutoSegment = 1; % Automatically segment when a new file is loaded or a different threshold is chosen?

% CHANNEL PLOT SETTINGS
% Settings with two numbers or rows refer to the top and bottom plot respectively
handles.PeakDetect = [0 0]; % Use peak detection for plotting?
handles.AutoYZoom = [1 1]; % Allow user to zoom vertically by dragging a box over the plot?
handles.AutoYLimits = [1 1]; % Choose y-limits automatically for each file, or carry over the current limits?
handles.ChanLimits = [-1 1; -1 1]; % Initial y-limits for the channel plots, if AutoYLimits is off
handles.ChannelColor = [0 0 1; 0 0 1]; % Colors of the channel plots
handles.ChannelThresholdColor = [1 0 0; 1 0 0]; % Colors of the threshold lines on the channel plots
handles.ChannelLineWidth = [1 1]; % Line widths of the channel plots

% EVENT SETTINGS
% Settings with two numbers or rows refer to the top and bottom plot respectively
handles.EventsAutoDetect = [1 1]; % Should events be detected automatically when a file is loaded?
handles.EventsDisplayMode = 1; % What should be displayed in the event browser? 1 - function values around each event; 2 - scatterplot of event features
handles.EventsAutoDisplay = 1; % Should events be updated automatically in the event browser each time they are changed?
handles.SearchBefore = [0.001 0.001]; % When selecting events by dragging a box over a channel plot, tolerance in the negative time direction (sec)
handles.SearchAfter = [0.001 0.001];% When selecting events by dragging a box over a channel plot, tolerance in the positive time direction (sec)
handles.EventLims = [0.001 0.003]; % Time axes limits for the event browser
handles.DefaultEventFeatureX = 'AP_amplitude'; % Event feature to plot allong the x-axis of the event browser in the Features mode.
handles.DefaultEventFeatureY = 'AP_width'; % Event feature to plot allong the y-axis of the event browser in the Features mode.

% SOUND SETTINGS
handles.SoundWeights = [2 1 1]; % Relative weights of the sound, the top plot, and the bottom plot, respectively
handles.SoundClippers = [.25 .25]; % The absolute level below which sounds are clipped (i.e., assigned zero value)
handles.SoundSpeed = 1; % Speed of sound playback (1 = normal speed)
handles.DefaultMix = [0 0 0]; % Include in the sound mix? Sound, top plot, and bottom plot, respectively
handles.FilterSound = 1; % Play filtered sound or raw sound?
handles.PlayReverse = 0; % Play sound in reverse?

% EXPORTING OPTIONS
handles.template.Plot = {'Sonogram'}; % List of plots to include in a figure
handles.template.Height = [1]; % Heights assigned to each of the figure plots (inches)
handles.template.Interval = [0.1]; % Vertical intervals following each of the figure plots (inches)
handles.template.YScaleType = [0]; % Type of a y-scale to use on each of the figure plots. 0 - none; 1 - scalebar; 2 - axis
handles.template.AutoYLimits = [1]; % Choose automatic y-limits for each of the figure plots, or use limits currently in the gui?
handles.AnimationType = 'Progress bar'; % Type of an animation to use when exporting a figure
handles.ScalebarWidth = 0.5; % Preferred length of time-axis scalebars (inches). A value as close to this as possible will be chosen.
handles.ScalebarHeight = 0.2; % Preferred length of vertical-axis scalebars (inches). A value as close to this as possible will be chosen.
handles.VerticalScalebarPosition = -0.1; % Location of vertical-axis scalebars. Negative value are to the left of the figure; positive to the right.
handles.ExportSonogramWidth = 2.5; % Figure width for exporting (inches/sec)
handles.ExportSonogramHeight = 0.95; % Sonogram height for exporting (inches)
handles.ExportSonogramResolution = 600; % Resolution (dpi) for exported sonogram images
handles.ExportReplotSonogram = 1; % Replot sonogram at the specified resolution when exporting, or use the current screen resolution (lower quality)?
handles.ExportSonogramIncludeLabel = 1; % Include timestamp label with exported objects?
handles.ExportSonogramIncludeClip = 1; % Sound clip to include with exported objects. 0 - none; 1 - sound only; 2 - sound mix
handles.SegmentFileFormat = 'Syll\l_Num\i2_File\n4_\dT\t'; % File name format for exporting syllable segments

% ANIMATION SETTINGS
handles.AnimationPlots = [0 0 0 0 0 0]; % Plot animation over sound wave, sonogram, segments, amplitude, top plot, and bottom plot, respectively
handles.ProgressBarColor = [0 1 0];
handles.SonogramFollowerPower = 10;

% WORKSHEET SETTINGS
handles.WorksheetMargin = 0.5; % Margin (inches) from the edge of the page
handles.WorksheetTitleHeight = 0.3; % Vertical space (inches) to allocate to the title bar, if included
handles.WorksheetVerticalInterval = 0.25; % Vertical space between images
handles.WorksheetHorizontalInterval = 0.25; % Horizontal space between images
handles.WorksheetIncludeTitle = 1; % Include a title on top of the worksheet?
handles.WorksheetChronological = 0; % Sort worksheet entries chronologically?
handles.WorksheetOnePerLine = 0; % Allow only one entry per line of the worksheet?
handles.WorksheetOrientation = 'landscape'; % Orientation of the worksheet pages
