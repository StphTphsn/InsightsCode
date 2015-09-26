clear all; close all; clc

pathname = '/Users/elm/Dropbox (MIT)/bouts/'; 
load(fullfile(pathname,'to3965_2013-11-03_labeled_100.mat')); 
%filenum = 12; 

%for tsne
fracKeep = .3; 
labelsKeep = []; 
AKeep = []; 

% decide frequency ranges to use
% for raw spectrum
maxF = 4000; minF = 1000; numPeriods = 100; 
minT = 1 ./ maxF; maxT = 1 ./ minF;
Ts = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
f{1} = fliplr(1./Ts);
% for ampl spectrum
maxF = 50; minF = 1; numPeriods = 50; 
minT = 1 ./ maxF; maxT = 1 ./ minF;
Ts = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
f{2} = fliplr(1./Ts);

omega0{1} = 50;
omega0{2} = 1; 
specDT = .005; 
tic
for filenum = 1:20
    % load the sound file
    load(fullfile(pathname,dbase.SoundFiles(filenum).name)); 
    s = rec.Data; 
    fs = rec.Fs; 
    
    % pull out syllable labels
    sylTypes = {'A' 'B' 'C' 'D' 'E' 'F'};%unique(dbase.SegmentTitles{1}(cellfun(@(X) length(X)~=0, dbase.SegmentTitles{1}))); 
    sylColors = lines(numel(sylTypes)); 
    labels = zeros(length(s), 3); 
    for syli = 1:numel(dbase.SegmentTitles{filenum})
        sylind = dbase.SegmentTimes{filenum}(syli,1): ...
            dbase.SegmentTimes{filenum}(syli,2);
        if length(dbase.SegmentTitles{filenum}{syli})>0
            sylID = strmatch(dbase.SegmentTitles{filenum}{syli}, sylTypes); 
            labels(sylind,:) = repmat(sylColors(sylID,:),length(sylind),1); 
        end
    end

    % envelope to avoid windowing effects
    rampdur = ceil(.01*fs); 
    ramp = (cos((1:rampdur)*ceil(pi/rampdur)))/2;
    envelope = ones(length(s),1); 
    envelope(1:rampdur) = fliplr(ramp); 
    envelope((end-rampdur+1):end) = ramp; 
    s = s.*envelope;

    % pull out raw signal, and rms power
    x{1} = s; 
    dt = 1/fs;
    tmp = (sqrt(conv(x{1}.^2, gausswin(.01*fs), 'same')));
    tmp = log(tmp);
    tmp = sigmf(tmp, [1/(std(tmp).^2), mean(tmp)])-.5; 
    x{2} = tmp; 

    % calculate wavelet specgram, of raw and amp env
    for r = 1:2
        [amp,W] = fastWavelet_morlet_convolution_parallel(x{r},f{r},omega0{r},dt);
        amp = amp(:,mod(1:size(amp,2),round(fs*specDT))==0); 
        amp = amp(:,round(rampdur*specDT):(end-round(rampdur*specDT))); 
        amp = log(amp); 
        sigTH = [-6 -3.5]*(r==1:2)'; %prctile(amp(:),80); % set it so it's the same for all files
        sigSP = [1.5 .3]*(r==1:2)'; %prctile(amp(:),80)-prctile(amp(:),60)); % set same for all files
        ampPlot{r} = sigmf(amp, ...
            [1/sigSP sigTH]);
            %[1/(std(amp(:))) mean(amp(:))]); 
    %     figure(r)
    %     surf((1:size(amp,2))*specDT, f{r}, ampPlot{r}, 'edgecolor', 'none'); 
    %     cmap = jet; 
    %     cmap(1,:) = zeros(1,3); 
    %     colormap(cmap)
    %     axis tight; view(0,90)
    %     shg
    end

    %plot specgram
    figure(4), set(gcf, 'color', [0 0 0], ...
        'position', [34         433        1274         219]); 
    clf; hold on; axis off
    A = [ampPlot{2}; ampPlot{1}];
    imagesc(A); set(gca, 'ydir', 'normal')
    for syli = 1:numel(dbase.SegmentTitles{filenum})
        sylind = dbase.SegmentTimes{filenum}(syli,1): ...
            dbase.SegmentTimes{filenum}(syli,2);
        if length(dbase.SegmentTitles{filenum}{syli})>0
            sylID = strmatch(dbase.SegmentTitles{filenum}{syli}, sylTypes); 
            syltimes = dbase.SegmentTimes{filenum}(syli,:)/(fs*specDT);
            patch([syltimes(1) syltimes(2) syltimes(2) syltimes(1) syltimes(1)],...
                [1 1 0 0 1]*5+numPeriods, sylColors(sylID,:))
            text(dbase.SegmentTimes{filenum}(syli,1)/(fs*specDT), 160, ...
                dbase.SegmentTitles{filenum}{syli},'color', sylColors(sylID,:))
        end
    end
    shg

    % Save some data for embedding
    labelsDS = labels(mod(1:length(rec.Data),round(fs*specDT))==0,:);
    indtest = rand(1,size(A,2))>(1-fracKeep); 
    Atest = A(:,indtest); 
    AKeep = [AKeep Atest];
    labelsKeep = [labelsKeep; labelsDS(indtest,:)]; 
    filenum
    t(filenum)=toc
    pause(5);
end
%% save data 
%save tmpWksp1 -v7.3
%%
shg; clf
ydata = tsne(AKeep', labelsKeep, 2);%, initial_dims, perplexity)

%%
indOnlySyl = sum(labelsKeep,2)~=0; 
shg
tsne(AKeep(:,indOnlySyl)', labelsKeep(indOnlySyl,:), 2);

%%
axesObjs = get(gcf, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children'); %handles to low-level graphics objects in axes
ydata(:,1) = get(dataObjs, 'XData')';  %data from low-level grahics objects
ydata(:,2) = get(dataObjs, 'YData')';
%%

% minT = 1 ./ parameters.maxF;
% maxT = 1 ./ parameters.minF;
% Ts = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
% f = fliplr(1./Ts);
% %