
%% load data, preprocess, run tsne, and save data for gui
% for subsong, etc. (gui where you plot features, not label syllables)
edit LoadingSongs.m 
% relies on:
% edit FeatureLabels.m % labels song with lots of features, inc. fir. rate
% edit DropLongGaps.m
% edit create_straight_ramp.m % make ramp for each feature
% edit run_tSne
% etc.
edit t_Insights_subsong_V2.m % subsong/features gui

% for adult song that you want to label. Does recurrent tsne
edit ProcessAdultSongs.m
% relies on:
% edit FeatureLabelsAdult.m % labels song with features
% edit DropLongGaps.m
% edit create_realtime_ramp.m % make time ramp, according to length of each
% syllable
% edit recurrent_tSNE_3D % for lots of song, do tsne in steps of
% 100, seeded by the previous positions. Ignores the first and last 950 
% pts, because it takes the average position of each point over 10 tsnes
% etc.
edit GUI_AutoLabel.m % gui for labeling syllables
%% make spectrogram, spectral derivative, spectral features
edit spectrogramELM.m
edit spectrogramDerivELM.m % spectral derivative
edit fun_pitch.m % pitch and aperiodicity
edit pitchgoodnessELM.m
edit fun_gravity.m; % gravity center
edit amplitudeELM.m; 
edit entropyELM.m; 
edit fastWavelet_morlet_convolution_parallel; % wavelet spectrogram
%% testing dmitriy's subsong data, making spectrograms and sorted rasters
edit EmilyExploit.m
%% playing around with clustering, modularity, etc.
edit ClusteringBME.m
