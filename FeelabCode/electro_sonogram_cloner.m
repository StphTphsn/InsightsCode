function electro_sonogram_cloner(ax, wv, fs, varargin)
%Reproduces electro_gui spectrograms as a stand-alone function
%
%Three required arguments: the axis handle to plot in 'ax', the signal to be 
%plotted 'wv', and the sampling frequency 'fs'. It also accepts a number of
%optional name-value pairs: 'startTime' 
%(a double/int to set the time of the first sample), 'freqLim' (a 1x2 
%vector of the min and max frequncy to plot),
%'clim' (a 1x2 vector to scale the colormap), and 'background' 
%(a 1x3 vector specifying the background color).
%
%dependencies: egs_AAquick_sonogram, gl_parse_args
%Written by Galen Lynch 7/10/2014
options = struct('startTime', 0, 'freqLim', [500 7500], 'clim', [14.5 26], 'background', [0 0 0]);
options = gl_parse_args(options, varargin);
assert(isequal(size(options.freqLim), [1 2]), 'freqLim must be a 1x2 array');
assert(isequal(size(options.clim), [1 2]), 'clim must be a 1x2 array');
assert(isequal(size(options.background), [1 3]), 'background must be a 1x3 array');
xl = [options.startTime, nan];
xl(2) = xl(1) + length(wv)/fs;
set(ax, 'xlim', xl);
set(ax, 'ylim', options.freqLim);
egs_AAquick_sonogram(ax, wv, fs);
set(ax, 'ydir', 'normal')
cmap = jet(256);
cmap(1,:) = options.background;%set background to black
colormap(ax, cmap);
set(ax, 'CLim', options.clim);