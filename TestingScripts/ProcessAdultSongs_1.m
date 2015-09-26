%%
clear all; close all; clc
addpath(genpath('dummy/../..'));

%% read a row of data from pathsToData.xlsx
for row = 18%[15 14 13 11 12]; %1:13%[5 7:10]%6 5
    try 
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
for FileToLoad = GoodBoutInd(1:min(500,end)); 
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
        [newLabels FeatureInd] = FeatureLabelsAdult(data, specDT);
        AllLabels = [AllLabels newLabels];
    end
end

%% save stuff
%save(['rec_allthefeatures_' num2str(row) '.mat'], '-v7.3'); 

%% cdfscore everything

FeatureInd

AllLabelsCDF = AllLabels; 

indForTsne = [2:size(AllLabelsCDF,1)];
%set all features to 0 during the gaps
AllLabelsCDF(indForTsne,AllLabels(1,:)==-2) = 0;

% take cdfscore
AllLabelsCDF(indForTsne,:) = AllLabelsCDF(indForTsne,:); %cdfscore(AllLabelsCDF(indForTsne,:)')';

% make ramp of features, and time ramp
RampTsne = [];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.Amplitude,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.Entropy,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.PitchGoodness,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.YinPitch,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.GravityCenter,:))];
RampTsne = [RampTsne; create_straight_ramp(AllLabelsCDF(FeatureInd.SpectralWidth,:))];
RealTime = AllLabelsCDF(FeatureInd.TimeFromOnset,:);
beg_ind_syl = find(RealTime(1:end-1)==-2 & RealTime(2:end)>=0)+1;
end_ind_syl = find(RealTime(1:end-1)>=0 & RealTime(2:end)==-2);
junk_sorting = sort(end_ind_syl-beg_ind_syl,'descend');
length_biggest_syllable = junk_sorting(2);

RampRamp = create_realtime_ramp(beg_ind_syl,end_ind_syl,length_biggest_syllable,size(AllLabels,2));

%figure;imagesc(RampTsne);colorbar;

% nicer spectrogram for gui
ForGUI = cdfscore(AllLabelsCDF')'; %%% consider not CDFscoring label vector
ForGUI(FeatureInd.ForGuiSpectrogram,:) = cdfscore(AllLabels(FeatureInd.ForGuiSpectrogram,:)',[70 100])'; 

%% cut out the gaps
ToTsne = AllLabelsCDF;

logNoGaps = (AllLabelsCDF(1,:)~=-2) & ...
    (AllLabelsCDF(1,:)>0) & (AllLabelsCDF(1,:)<1); % don't embed gaps, or points in the very beginning/end of syllables

logSubSample = logNoGaps; 
%logSubSample(cumsum(logNoGaps)>2000) = 0; % only attempt to embed 2000 points


ToTsneAll = ToTsne(:,logSubSample);
ToTsneRamp = RampTsne(:,logSubSample); 
RampRamp = RampRamp(:,logSubSample); 

%% Only raw features
%attempts = {'raw','rawboost', 'spec','nospec','noamp','noent','nogood','nograv','nowidth', 'nopitch'}
attempts = {'specplusramp'}%,'ramprampTsne','spec', 'rampTsne'}; %,'ramprampTsne', 'rampTsne','all'}%, 'raw', 'spec','nospec', 'nopitch'};

parameters = setRunParameters;
parameters.training_perplexity = 2*parameters.training_perplexity;
parameters.perplexity = 2*parameters.perplexity;
parameters.num_tsne_dim = 3; 
for i =1:length(attempts)
    attempt = attempts{i};
    ToTSNE2 = ToTsneAll;
    switch attempt
        case 'rampTsne'
            ToTSNE2 = ToTsneRamp; 
            IndKeep = 1:size(ToTSNE2,1); 
        case 'ramprampTsne'
            ToTSNE2 = [ToTsneRamp; 10*RampRamp];
            IndKeep = 1:size(ToTSNE2,1);      
        case 'specfeat'
            IndKeep = [FeatureInd.Amplitude_Spectrum FeatureInd.Entropy_Spectrum FeatureInd.GravityCenter_Spectrum...
                FeatureInd.SpectralWidth_Spectrum FeatureInd.PitchGoodness_Spectrum FeatureInd.YinPitch_Spectrum];
        case 'spec'
            IndKeep = FeatureInd.Spectrogram;
        case 'specplusramp'
            med = ToTsneAll(FeatureInd.Spectrogram,:); med = median(med(med>0)); 
            ToTSNE2 = [ToTsneAll([FeatureInd.Spectrogram],:); ...
                med*.1*RampRamp];
            IndKeep = 1:size(ToTSNE2,1);  
    end
    tic
    [yData,betas,P,errors] = run_tSne(ToTSNE2(IndKeep,:)', parameters);
    %[X,Y,Z,nb_iter,size_step,window_size] = recurrent_tSNE_3D(ToTSNE2(IndKeep,:), parameters);
%     X1 = flipud(X); Y1 = flipud(Y); Z1 = flipud(Z); 
%     toc
%     Spectro = ForGUI;
%     tSNE_Coord = [flipud(X1(:)) flipud(Y1(:)) flipud(Z1(:))];
%     logSubSample(cumsum(logSubSample)>(sum(logSubSample)-950))=0; 
%     logSubSample((sum(logSubSample)-cumsum(logSubSample))>=size(tSNE_Coord,1))=0;
    Spectro = ForGUI;
    selected = logSubSample;
    Spectro(FeatureInd.TimeFromOnset,~selected) = 0; 
    tSNE_Coord = yData; 
    %save(['againstFee_' attempt '_row' num2str(row)], 'Spectro','tSNE_Coord','selected', 'FeatureInd')
    %figure; clf; plot3(X(:), Y(:), Z(:),'.'); shg; title([attempt]); drawnow; 
    figure; clf; plot3(yData(:,1), yData(:,2), yData(:,3),'.'); shg; title([attempt]); drawnow; 
end

    catch exception
        exception
    end
end
