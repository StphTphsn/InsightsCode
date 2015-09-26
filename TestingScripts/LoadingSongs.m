%%
clear all; close all; clc
addpath(genpath('dummy/../..'));

%% read a row of data from pathsToData.xlsx

for row = 12%[5 7:10]%6 5
    clearvars -except row
row
if length(regexp(pwd, 'emackev')) > 0
    XLS = importdata('C:\Users\emackev\Documents\MATLAB\Insights\pathsToData.xlsx');
    Columns = XLS.Sheet1(1,:);
    folder = char(XLS.Sheet1(row,strmatch('PathnameELM', Columns)));
else
    XLS = importdata('C:\Users\feelab\Documents\MATLAB\pathsToData.xlsx');
    Columns = XLS.Sheet1(1,:);
    folder = char(XLS.Sheet1(row,strmatch('PathnameStephane', Columns)));
end

BG = XLS.Sheet1(row,strmatch('GoodBouts', Columns)); 
GoodBoutInd = eval(BG{1}); 

AnalysisFile = fullfile(folder, char(XLS.Sheet1(row,strmatch('AnalysisFile', Columns))));
load(AnalysisFile);
%spk = dbase.EventTimes{2}(1,:); save('C:\Users\emackev\Dropbox (MIT)\Wavelets-tSNE\4202Jan18_s346\spk', 'spk') % for 4202Jan18_s346
%spk = dbase.EventTimes{1}(1,:); save('C:\Users\emackev\Dropbox (MIT)\Wavelets-tSNE\4493May6_s26\spk', 'spk') % for 4202Jan18_s346

SongFolder = fullfile(folder, char(XLS.Sheet1(row,strmatch('SongFoldername', Columns))));

% store spikes in variable spk
SpikesFile = fullfile(folder, char(XLS.Sheet1(row,strmatch('SpikesFile', Columns))));
if length(SpikesFile) > length(folder)
    load(SpikesFile);
    dbase.EventTimes = spk;
end

% load bouts, compute features, and concatenate
AllLabels = [];
for FileToLoad = GoodBoutInd; 
    FileToLoad
    % load one bout
    if isfield(dbase, 'SoundLoader')
        [sndOrig fsOrig dt label props] = ...
            eval(['egl_' dbase.SoundLoader...
            '([''' SongFolder filesep ...
            dbase.SoundFiles(FileToLoad).name '''],1)']);
    else %dmitriy's lman data
        b=sprintf('%6.6d',FileToLoad);
        [sndOrig,fsOrig] = wavread(fullfile(SongFolder, ['sound' b '.wav']));
        dbase.Times = dbase.DateAndTime;
        dbase.SegmentIsSelected = dbase.IsSelected;
    end
    
    % resample data
    fs = 40000;
    if fs~=fsOrig
        snd1 = interp1((1:length(sndOrig))/fsOrig, sndOrig, (1/fs):(1/fs):(length(sndOrig)/fsOrig))';
        dbase.SegmentTimes{FileToLoad} = dbase.SegmentTimes{FileToLoad}*fs/fsOrig;
    else
        snd1 = sndOrig;
    end
    specDT = .005;
    
    % drop long gaps
    [snd, timeInds, labels, spk] = DropLongGaps(dbase, FileToLoad, snd1, fs);
    %figure(12); clf; plot(snd); hold on; plot(spk); drawnow; 
    % compute features
    
    data.song = snd;
    data.fs = fs;
    data.labels = labels;
    data.units = spk;
    if length(snd)>0
        [newLabels FeatureInd] = FeatureLabels(data, specDT);
        AllLabels = [AllLabels newLabels];
    end
end
%% checking pitch goodness
% figure(1); clf;
% h = subplot(2,1,1);
% imagesc(ForGUI); %
% set(gca, 'ydir', 'normal')
% colormap hot
% 
% g = subplot(2,1,2);
% hold on
% plot(AllLabels(FeatureInd.PitchGoodness,:));
% linkaxes([h g], 'x')

%% save stuff
save(['PG_allthefeatures_' num2str(row) '.mat'], '-v7.3'); 

%% cdfscore everything

FeatureInd

AllLabelsCDF = AllLabels; %AllLabelsCDF(isnan(AllLabelsCDF)) = .1;

indForTsne = [2:FeatureInd.FiringRate-1];
%set all features to 0 during the gaps
AllLabelsCDF(indForTsne,AllLabels(1,:)==-2) = 0;


% take cdfscore
AllLabelsCDF(indForTsne,:) = cdfscore(AllLabelsCDF(indForTsne,:)')';
RampTsne = [];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.Amplitude,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.Entropy,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.PitchGoodness,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.YinPitch,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.GravityCenter,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.SpectralWidth,:))];
RampRamp = create_straight_ramp(AllLabelsCDF(FeatureInd.TimeFromOnset,:)); 

%figure;imagesc(RampTsne);colorbar;



ForGUI = cdfscore(AllLabelsCDF')';
ForGUI(FeatureInd.Spectrogram,:) = cdfscore(AllLabels(FeatureInd.Spectrogram,:)',[70 100])'; 


figure(1); clf;
h = subplot(2,1,1);
imagesc(ForGUI); %
set(gca, 'ydir', 'normal')
colormap hot

g = subplot(2,1,2);
hold on
L = fieldnames(FeatureInd);
plotLabelsInd = [];
nl = 1;
Leg = {};
for i = 2:length(L)
    if length(FeatureInd.(L{i})) == 1
        plotLabelsInd(end+1) = FeatureInd.(L{i});
        plot(AllLabelsCDF(FeatureInd.(L{i}),:));
        Leg{nl} = L{i}
        nl = nl+1;
    end
end
legend(Leg)
linkaxes([h g], 'x')
%%  Subsampling
ToTsne = AllLabelsCDF;
%ToTsne(1:6,:) = ToTsne(1:6,:)*100;

logNoGaps = AllLabelsCDF(1,:)~=-2;
offsets = -200:200; 
%indSubSample = indNoGaps&(mod(1:length(indNoGaps), 20)==1);

indFired = find(AllLabels(FeatureInd.FiringRate,:)>0);
indFired1 = []; 
for oi = 1:length(offsets)
    indFired1 = [indFired1 indFired+offsets(oi)]; 
end
indFired1 = unique(indFired1); 
indFired = [indFired1 randi(length(logNoGaps),length(indFired1),1)'];
indFired = unique(indFired); 
indFired = sort(indFired);

indFired(indFired>length(logNoGaps)|indFired<1)=[];
logFired = zeros(1,length(logNoGaps)); 
logFired(indFired) = 1; 
logSubSample = logNoGaps&logFired;
indSubSample = find(logSubSample);
nmod = max(10,round(length(indSubSample)/2000)); 
indSubSample = indSubSample(mod(1:length(indSubSample),nmod)==0); 
logSubSample = zeros(length(logSubSample),1);
logSubSample(indSubSample)=1;

ToTsneAll = ToTsne(:,indSubSample);
ToTsneRamp = RampTsne(:,indSubSample); 
RampRamp = RampRamp(:,indSubSample); 

%% Only raw features
%attempts = {'raw','rawboost', 'spec','nospec','noamp','noent','nogood','nograv','nowidth', 'nopitch'}
attempts = {'spec','ramprampTsne', 'rampTsne','all'}%, 'raw', 'spec','nospec', 'nopitch'};

parameters = setRunParameters;
parameters.training_perplexity = parameters.training_perplexity*2;
parameters.perplexity = parameters.perplexity*2;
for i =1:length(attempts)
    attempt = attempts{i};
    ToTSNE2 = ToTsneAll;
    switch attempt
        case 'rampTsne'
            ToTSNE2 = ToTsneRamp; 
            IndKeep = 1:size(ToTSNE2,1); 
        case 'ramprampTsne'
            ToTSNE2 = [ToTsneRamp; 50*RampRamp];
            IndKeep = 1:size(ToTSNE2,1); 
        case 'all'
%             IndKeep = [FeatureInd.Amplitude FeatureInd.Entropy FeatureInd.GravityCenter...
%                 FeatureInd.SpectralWidth FeatureInd.PitchGoodness FeatureInd.YinPitch];
%             ToTSNE2(IndKeep,:) = 10*ToTSNE2(IndKeep,:);
            ToTSNE2 = [ToTsneAll(FeatureInd.Spectrogram,:); ToTsneRamp; 50*RampRamp];
            IndKeep = 1:size(ToTSNE2,1);        
        case 'raw'
            IndKeep = [FeatureInd.Amplitude FeatureInd.Entropy FeatureInd.GravityCenter...
                FeatureInd.SpectralWidth FeatureInd.PitchGoodness FeatureInd.YinPitch];
        case 'specfeat'
            IndKeep = [FeatureInd.Amplitude_Spectrum FeatureInd.Entropy_Spectrum FeatureInd.GravityCenter_Spectrum...
                FeatureInd.SpectralWidth_Spectrum FeatureInd.PitchGoodness_Spectrum FeatureInd.YinPitch_Spectrum];
        case 'rawboost'
            IndKeep = [FeatureInd.Amplitude FeatureInd.Entropy FeatureInd.GravityCenter...
                FeatureInd.SpectralWidth FeatureInd.PitchGoodness FeatureInd.YinPitch];
            ToTSNE2(IndKeep,:) = 10*ToTSNE2(IndKeep,:);
            IndKeep = [FeatureInd.Amplitude FeatureInd.Entropy FeatureInd.GravityCenter...
                FeatureInd.SpectralWidth FeatureInd.PitchGoodness FeatureInd.YinPitch...
                FeatureInd.Amplitude_Spectrum FeatureInd.Entropy_Spectrum FeatureInd.GravityCenter_Spectrum...
                FeatureInd.SpectralWidth_Spectrum FeatureInd.PitchGoodness_Spectrum];
        case 'spec'
            IndKeep = FeatureInd.Spectrogram;
        case 'nospec'
            IndKeep = setdiff(1:size(ToTsneAll,1), FeatureInd.Spectrogram);
        case 'noamp'
            IndKeep = setdiff(1:size(ToTsneAll,1), [FeatureInd.Amplitude FeatureInd.Amplitude_Spectrum]);
        case 'noent'
            IndKeep = setdiff(1:size(ToTsneAll,1), [FeatureInd.Entropy FeatureInd.Entropy_Spectrum]);
        case 'nogood'
            IndKeep = setdiff(1:size(ToTsneAll,1), [FeatureInd.PitchGoodness FeatureInd.PitchGoodness_Spectrum]);
        case 'nograv'
            IndKeep = setdiff(1:size(ToTsneAll,1), [FeatureInd.GravityCenter FeatureInd.GravityCenter_Spectrum]);
        case 'nowidth'
            IndKeep = setdiff(1:size(ToTsneAll,1), [FeatureInd.SpectralWidth FeatureInd.SpectralWidth_Spectrum]);
        case 'nopitch'
            IndKeep = [FeatureInd.Amplitude FeatureInd.Entropy FeatureInd.GravityCenter...
                FeatureInd.SpectralWidth FeatureInd.PitchGoodness]; 
    end
    
    [yData,betas,P,errors] = run_tSne(ToTSNE2(IndKeep,:)', parameters);
    Spectro = ForGUI;
    tSNE_Coord = yData;
    selected = logSubSample;
    save(['againstFee_' attempt '_row' num2str(row)], 'Spectro','tSNE_Coord','selected', 'FeatureInd')
    figure(i); clf; plot(yData(:,1), yData(:,2),'.'); shg; title(attempt); drawnow; 
end


end
