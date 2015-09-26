function segs = egg_AA_segmenter(a,fs,th,params)
% ElectroGui segmenter
% based on aSAP_segSyllablesFromRawAudio written by Aaron Andalman
% made compatible with electro_gui by Tatsuo Okubo

if isstr(a) & strcmp(a,'params')
    segs.Names = {'Mic (0:normal 1:Piezo 2:SAP 3:no filters)','Debug segmentation? (1:yes, 0:no)','TriggerAbs','ThresholdAbs',...
        'Use noise ratio? (1:yes, 0:no)','noiseThres','noiseFrac','entropyThres','entropyFrac','fMinIntervalDuration'};
    segs.Values = {'0','0','-6','-8','0','0','0.1','-0.2','0.5','0.007'};
    return
end

%%
% load filters 
switch eval(cell2mat(params.Values(1)))
    case 0 % Normal mic
        load AAsegmentFiltersNormal.mat % notchFilt, noiseFilt for Normal mic
    case 1 % Piezo mic
        load AAsegmentFiltersPiezo.mat % notchFilt, noiseFilt for Piezo mic
    case 2 % SAP with normal mic (change Fs=44100 when using SAP)
        load AAsegmentFiltersSAP.mat % notchFilt, noiseFilt for SAP and normal mic;
    case 3 % no filters
        notchFilt = [];
end
P.bDebug = logical(eval(cell2mat(params.Values(2)))); % false convert to logical!
P.triggerAbs = eval(params.Values{3}); %-8; %if using fixed thresholds. Syllable events to consider (red).
P.thresholdAbs = eval(params.Values{4}); %-9.5; %if using fixed thresholds. Determine the edges (blue)
P.bUseNoiseRatio = logical(eval(cell2mat(params.Values(5)))); % true
P.noiseThres = eval(params.Values{6}); %0;
P.noiseFrac = eval(params.Values{7}); %0.1;
P.entropyThres = eval(params.Values{8});%-0.8;
P.entropyFrac = eval(params.Values{9});%0.3;
P.method = 'fixed'; % fixed threshold, or 'mixure' for automated threshold
P.fMinIntervalDuration = eval(params.Values{10});

[syllStartTimes,syllEndTimes]=aSAP_segSyllablesFromRawAudio(a,fs,'bDebug',P.bDebug,...
'notchFilt',notchFilt,'noiseFilt',noiseFilt,'noiseThres',P.noiseThres','noiseFrac',P.noiseFrac,'bUseNoiseRatio',P.bUseNoiseRatio,...
'method',P.method,'thresholdAbs',P.thresholdAbs,'triggerAbs',P.triggerAbs,...
'entropyThres',P.entropyThres,'entropyFrac',P.entropyFrac,'fMinIntervalDuration',P.fMinIntervalDuration);

segs = [(syllStartTimes)',(syllEndTimes)'];