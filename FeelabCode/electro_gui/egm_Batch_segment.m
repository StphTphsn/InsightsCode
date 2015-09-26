function handles = egm_Batch_segment(handles)
% ElectroGui macro
% Batch syllable segmentation for faster analysis
% Uses current segmentation algorithm and parameters
% Only works for segmentation based on sound amplitude

if isfield(handles,'AutomationELM')
    fls = 1:handles.TotalFileNumber;
else
    answer = inputdlg({'File range'},'File range',1,{['1:' num2str(handles.TotalFileNumber)]}); % default file range: all files
    if isempty(answer)
        return
    end

    fls = eval(answer{1});
end
for c = 1:length(handles.menu_Segmenter)
    if strcmp(get(handles.menu_Segmenter(c),'checked'),'on')
        alg = get(handles.menu_Segmenter(c),'label');
    end
end

figure(handles.figure_Main); % added by Tatsuo
subplot(handles.axes_Sonogram);
txt = text(mean(xlim),mean(ylim),'Segmenting... Click to quit.','horizontalalignment','center','fontsize',14,'color','r','backgroundcolor','w');
set(txt,'ButtonDownFcn','set(gco,''color'',''g''); drawnow;');
for j = 1:length(fls) % counter for files to be segmented
    cnt = j;
    c = fls(j); % file number
    if sum(get(txt,'color')==[0 1 0])==3
        cnt = cnt-1;
        break
    end
    
    [snd fs dt label props] = eval(['egl_' handles.sound_loader '([''' handles.path_name filesep handles.sound_files(c).name '''],1)']);
        
    % make snd a column vector
    if size(snd,2)>size(snd,1)
        snd = snd';
    end
    
    handles.DatesAndTimes(c) = dt; %%% Tatsuo
    handles.FileLength(c) = length(snd); %%% Tatsuo
    
    back = handles.sound; % temporary store current handles.sound into 'back'
    handles.sound = snd;
    amp = eg_CalculateAmplitude(handles);
    handles.sound = back; % put it back

    if strcmp(alg,'AA_segmenter')
        curr = handles.SoundThresholds(c);
    else
        if strcmp(get(handles.menu_AutoThreshold,'checked'),'on')
            handles.SoundThresholds(c) = eg_AutoThreshold(amp);
        else % no auto threshold
            handles.SoundThresholds(c) = handles.CurrentThreshold;
        end
        curr = handles.SoundThresholds(c);
    end

    %---- modified by Tatsuo
    if strcmp(alg,'AA_segmenter') % give raw sound instead of amplitude
        handles.SegmentTimes{c} = eval(['egg_' alg '(snd,fs,curr,handles.SegmenterParams)']);
    else
        handles.SegmentTimes{c} = eval(['egg_' alg '(amp,fs,curr,handles.SegmenterParams)']); % run segmenter
    end
    %---------------------------
    
    handles.SegmentTimes{c} = eval(['egg_' alg '(amp,fs,curr,handles.SegmenterParams)']);
    handles.SegmentTitles{c} = cell(1,size(handles.SegmentTimes{c},1));
    handles.SegmentSelection{c} = ones(1,size(handles.SegmentTimes{c},1));

    set(txt,'string',['Segmented file ' num2str(fls(j)) ' (' num2str(j) '/' num2str(length(fls)) '). Click to quit.']);
    drawnow;
end

delete(txt);
if isfield(handles,'AutomationELM')
else
    msgbox(['Segmented ' num2str(cnt) ' files.'],'Segmentation complete')
end

%%
function amp = eg_CalculateAmplitude(handles)

for c = 1:length(handles.menu_Filter)
    if strcmp(get(handles.menu_Filter(c),'checked'),'on')
        h = handles.menu_Filter(c);
        set(h,'userdata',handles.FilterParams);
        alg = get(handles.menu_Filter(c),'label');
    end
end

handles.filtered_sound = eval(['egf_' alg '(handles.sound,handles.fs,handles.FilterParams)']);

wind = round(handles.SmoothWindow*handles.fs);
amp = smooth(10*log10(handles.filtered_sound.^2+eps),wind);
amp = amp-min(amp(wind:length(amp)-wind));
amp(find(amp<0))=0;

%%
function threshold = eg_AutoThreshold(amp)

if mean(amp)<0
    amp = -amp;
    isneg=1;
else
    isneg=0;
end

% Code from Aaron Andalman
[noiseEst, soundEst, noiseStd, soundStd] = eg_estimateTwoMeans(amp);
if(noiseEst>soundEst)
    disc = max(amp)+eps;
else
    %Compute the optimal classifier between the two gaussians...
    p(1) = 1/(2*soundStd^2+eps) - 1/(2*noiseStd^2);
    p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2+eps);
    p(3) = (soundEst^2)/(2*soundStd^2+eps) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd+eps);
    disc = roots(p);
    disc = disc(find(disc>noiseEst & disc<soundEst));
    if(length(disc)==0)
        disc = max(amp)+eps;
    else
        disc = disc(1);
        disc = soundEst - 0.5 * (soundEst - disc);
    end
end
threshold = disc;

if ~isreal(threshold)
    threshold = max(amp)*1.1;
end

if isneg
    threshold = -threshold;
end

%%
% by Aaron Andalman
function [uNoise, uSound, sdNoise, sdSound] = eg_estimateTwoMeans(audioLogPow)

%Run EM algorithm on mixture of two gaussian model:

%set initial conditions
l = length(audioLogPow);
len = 1/l;
m = sort(audioLogPow);
uNoise = median(m(fix(1:length(m)/2)));
uSound = median(m(fix(length(m)/2:length(m))));
sdNoise = 5;
sdSound = 20;

%compute estimated log likelihood given these initial conditions...
prob = zeros(2,l);
prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
[estProb, class] = max(prob);
warning off
logEstLike = sum(log(estProb)) * len;
warning on
logOldEstLike = -Inf;

%maximize using Estimation Maximization
while(abs(logEstLike-logOldEstLike) > .005)
    logOldEstLike = logEstLike;

    %Which samples are noise and which are sound.
    nndx = find(class==1);
    sndx = find(class==2);

    %Maximize based on this classification.
    uNoise = mean(audioLogPow(nndx));
    sdNoise = std(audioLogPow(nndx));
    if ~isempty(sndx)
        uSound = mean(audioLogPow(sndx));
        sdSound = std(audioLogPow(sndx));
    else
        uSound = max(audioLogPow);
        sdSound = 0;
    end

    %Given new parameters, recompute log likelihood.
    prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2+eps)))./(sdNoise+eps);
    prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2+eps)))./(sdSound+eps)+eps;
    [estProb, class] = max(prob);
    logEstLike = sum(log(estProb+eps)) * len;
end