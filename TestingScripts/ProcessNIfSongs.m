%%
clear all; close all; clc
addpath(genpath('Insights')); 

% load NIf spreadsheet 
tic; 
XLS = importdata('C:\Users\emackev\Dropbox (MIT)\MackeviciusLabPresentations\NIfUnits.xlsx'); 
XLS.data.Sheet1 = [NaN*ones(1, size(XLS.data.Sheet1,2)); XLS.data.Sheet1]; % add row corresponding to title row, so indices line up.
Columns = XLS.textdata.Sheet1(1,:);
toc

% logicals for choosing what rows to run
SINGING = XLS.data.Sheet1(:,strmatch('singing?', Columns))==1; 
TUTORING = XLS.data.Sheet1(:,strmatch('tutoring?', Columns))==1;
ASUBSONG = XLS.data.Sheet1(:,strmatch('art subsong?', Columns))==1;
SINGLEUNIT = XLS.data.Sheet1(:,strmatch('quality (1 = bad multi, 2 = ok, 3 = single, 4 = good single)', Columns))>=3; 
CTEST = XLS.data.Sheet1(:,strmatch('ctest?', Columns))==1;
PUTPROJ = XLS.data.Sheet1(:,strmatch('Put Proj?', Columns))==1;
HASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))>0;
UNITINHASH = XLS.data.Sheet1(:,strmatch('hash? (2  = unit)', Columns))==2;
hashLat = XLS.data.Sheet1(:,strmatch('latency (ms)', Columns));
hashLatJitt = XLS.data.Sheet1(:,strmatch('LatJitt (us)', Columns));
SYLSEL = XLS.data.Sheet1(:,strmatch('maybe Syl selective?', Columns))==1;

% Age
birthday = [0; cellfun(@(X) datenum(X), XLS.textdata.Sheet1(2:end,strmatch('birthday', Columns)))];
day = [0; cellfun(@(X) datenum(X(1:end-4)), XLS.textdata.Sheet1(2:end,strmatch('day', Columns)))];
Age = day - birthday; 

% Histology
Electrode = XLS.data.Sheet1(:,strmatch('electrode #', Columns));
GoodHistvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('hist. confidence', Columns)), 'uniformoutput', 0); 
GoodHistvec(2:end+1) = GoodHistvec(1:end); % to make rows line up (first row is section headings)
Dvec = cellfun(@(X) eval(X), XLS.textdata.Sheet1(2:end,strmatch('[D_E1, D_E2, D_E3]', Columns)), 'uniformoutput', 0); 
Dvec(2:end+1) = Dvec(1:end); % to make rows line up (first row is section headings)

for rowi = 2:size(XLS.textdata.Sheet1,1)
    goodHist(rowi) = GoodHistvec{rowi}(Electrode(rowi)); 
    elecPosition(rowi) = Dvec{rowi}(Electrode(rowi)); 
end

% for coloring by bird id
birdID = XLS.data.Sheet1(:,strmatch('bird', Columns)); 
[~,~,birdnum] = unique(birdID); 

SUBSONG = zeros(size(XLS.data.Sheet1,1),1); SUBSONG(strmatch('subsong', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
PROTOSYLLABLE = zeros(size(XLS.data.Sheet1,1),1); PROTOSYLLABLE(strmatch('protosyllable', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
DIFF = zeros(size(XLS.data.Sheet1,1),1); DIFF(strmatch('diff', XLS.textdata.Sheet1(:,strmatch('song stage', Columns))))=1;
%% 
for row = find((SINGING|TUTORING)&PUTPROJ)' % read a row of data from pathsToData.xlsx
    clearvars -except row XLS Columns SINGING TUTORING PUTPROJ
try

% getting the relevant info from NIfUnits spreadsheet
bird = num2str(XLS.data.Sheet1(row,strmatch('bird', Columns)));
day = XLS.textdata.Sheet1{row,strmatch('day', Columns)};
depth = XLS.textdata.Sheet1{row,strmatch('folder', Columns)};
feeboxFolder = XLS.textdata.Sheet1{row,strmatch('which feebox', Columns)};
if strmatch('feebox4',feeboxFolder) % feebox 4 is actually on feebox 6 now
    feeboxFolder = 'Z:\emackev\AcqGui\';
end
if strmatch('feebox5',feeboxFolder)
    feeboxFolder = 'Y:\AcqGui\';
end
filename = ['analysis' depth(2:end)];

rowstr = ['row' num2str(row) '_' num2str(bird) '_' day '_' depth ]; 
if SINGING(row)
    rowstr = [rowstr '_singing']
end
if TUTORING(row)
    rowstr = [rowstr '_tutoring']; 
end
if PUTPROJ(row)
    rowstr = [rowstr '_putproj']; 
end
display(['Working on ', rowstr])

% load analysis file
load(fullfile(feeboxFolder, bird, day, depth, filename));
fs = dbase.Fs;
nFiles = length(dbase.SegmentTimes); 

% load bouts, compute features, and concatenate
AllLabels = [];
for FileToLoad = 1:min(150,nFiles); 
    display(['Processing file ', num2str(FileToLoad)]); 
    % load one bout
    [sndOrig fsOrig dt label props] = ...
        eval(['egl_' dbase.SoundLoader...
        '([''' fullfile(feeboxFolder, bird, day, depth, ...
        dbase.SoundFiles(FileToLoad).name) '''],1)']);
    
    % resample data
    fs = 40000;
    if round(fs)~=round(fsOrig)
        warning('resampling song'); 
        snd1 = interp1((1:length(sndOrig))/fsOrig, sndOrig, (1/fs):(1/fs):(length(sndOrig)/fsOrig))';
        dbase.SegmentTimes{FileToLoad} = dbase.SegmentTimes{FileToLoad}*fs/fsOrig;
    else
        snd1 = sndOrig;
    end
    specDT = .005;
    
    % drop long gaps
    [snd, timeInds, labels, SylFileNum, SylSegNum] = ...
        DropLongGapsNIf(dbase, FileToLoad, snd1, fs);

    % compute spectrogram
    data.song = snd;
    data.fs = fs;
    data.labels = [labels'; SylFileNum'; SylSegNum'];
    if length(snd)>0
        [newLabels FeatureInd] = FeatureLabelsNIf(data, specDT);
        AllLabels = [AllLabels newLabels];
    end
end

%% save stuff
save(['NIf_specplusramp_' rowstr '.mat'], '-v7.3'); 
display(['saved NIf_specplusramp_' rowstr '.mat'])

%% preprocess for tsne gui (tsne based on smoothed spectrogram & syllable ramp)

indForTsne = [FeatureInd.Spectrogram FeatureInd.Ramp];

% balance weighting of spectrogram vs ramp
rampfac = .25; % relative weight of ramp compared to spectrogram
specmed = AllLabels(FeatureInd.Spectrogram,:); specmed = std(specmed(:)); 
rampmed = AllLabels(FeatureInd.Ramp,:); rampmed = rampmed(rampmed>0); rampmed = std(rampmed(:)); 
AllLabels(FeatureInd.Ramp,:) = AllLabels(FeatureInd.Ramp,:)*rampfac*specmed/rampmed; 

% nicer spectrogram for gui
ForGUI = AllLabels; 
ForGUI(FeatureInd.ForGuiSpectrogram,:) = cdfscore(AllLabels(FeatureInd.ForGuiSpectrogram,:)',[70 100])'; 

% cut out the gaps
labels = AllLabels(FeatureInd.TimeFromOnset,:); 
logNoGaps = (labels~=-2) & ...
    (labels>0) & (labels<1); % don't embed gaps, or points in the very beginning/end of syllables
logSubSample = logNoGaps; 
ToTsne = AllLabels(indForTsne,logNoGaps);

%% tsne
parameters = setRunParameters;
parameters.training_perplexity = 2*parameters.training_perplexity;
parameters.perplexity = 2*parameters.perplexity;
parameters.num_tsne_dim = 3; 
if size(ToTsne,2)<2000 % just do normal tsne, not recurrent tsne
    tic
    [yData,betas,P,errors] = run_tSne(ToTsne', parameters);
    display(['tSne on ' rowstr ...
        ' took ' num2str(toc) 's, on ' num2str(size(ToTsne,2)) ' slices']); 
    Spectro = ForGUI;
    selected = logSubSample;
    Spectro(FeatureInd.TimeFromOnset,~selected) = 0; 
    tSNE_Coord = yData; 
    figure; clf; plot3(yData(:,1), yData(:,2), yData(:,3),'.'); title(rowstr); shg; drawnow; 
else % do recurrent tsne
    % padding tsne, because recurrent tsne skips first and last 950 pts
    nSkipped = 950; 
    indTsne = [size(ToTsne,2)-(1:(nSkipped+50)) ...
        1:size(ToTsne,2) ...
        1:nSkipped]; % adding 50 because there's at most 50 slices slop, and recurrent tsne starts from the end.
    ToTsne = ToTsne(:,indTsne); 

    tic
    [X,Y,Z,nb_iter,size_step,window_size] = recurrent_tSNE_3D(ToTsne, parameters);
    display(['recurrent tSne on ' rowstr ...
        ' took ' num2str(toc) 's, on ' num2str(size(ToTsne,2)) ' slices']); 

    % need to unwrap
    X1 = flipud(X); Y1 = flipud(Y); Z1 = flipud(Z); 
    tSNE_Coord = [flipud(X1(:)) flipud(Y1(:)) flipud(Z1(:))];
    logSubSample((sum(logSubSample)-cumsum(logSubSample))>=size(tSNE_Coord,1))=0; % accounting for slop in recurrent tsne rounding
    selected = logSubSample;
    Spectro = ForGUI;
    Spectro(FeatureInd.TimeFromOnset,~selected) = 0; 
    figure; clf; plot3(X(:), Y(:), Z(:),'.'); title(rowstr); shg; drawnow; 
end

save(['NIf_' rowstr], 'Spectro','tSNE_Coord','selected', 'FeatureInd')
display(['saved NIf_' rowstr])
emailme(['tsne''d ' rowstr ' ' num2str(nFiles) ' files, ' num2str(size(ToTsne,2)) ' slices'])

%% preliminary clustering... maybe

% Data = AllLabels(FeatureInd.ForGuiSpec...
% % subtract mean, divide by std
% Data = bsxfun(@minus, Data, mean(Data,1));
% Data = bsxfun(@rdivide, Data, std(Data,1));
% % Data = cdfscore(Data, [70 100]); 
% 
% % create distance matrix, in format they want
% D = pdist(Data, 'correlation'); 
% xx = [squareform(repmat(1:nt,nt,1).*~eye(nt))' ...
%     squareform(repmat((1:nt)',1,nt).*~eye(nt))' ...
%     D']; 
% 
% perform clustering
% [NCLUST, halo] = cluster_dp(xx);
% %tic; [COMTY ending] = cluster_jl_cpp(squareform(D),1,1,0,0); toc
% %
% figure; hold on
% surf(Data', 'edgecolor', 'none'); view(0,90); colormap parula
% plotpts = 100*ones(1,nt)
% Colors = jet(NCLUST); 
% for ci = 1:NCLUST
%     plotptsc = plotpts; 
%     plotptsc(halo~=ci) = nan; 
%     plot3(1:nt, plotptsc, 1000*ones(1,nt),'s', 'markersize', 5, 'markerfacecolor', Colors(ci,:), 'markeredgecolor', Colors(ci,:))
% end
% xlim([200 500])


catch exception
    display([exception])
    display(row)
    emailme(['error on row ' rowstr ' ' exception])
end
end