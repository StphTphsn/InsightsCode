function [newLabels FeatureInd] = FeatureLabelsNIf(data, specDT)
song = data.song;
fs = data.fs;
labels = data.labels; 
labels = labels(:,mod(1:length(labels), fs*specDT)==0); 

% time from onset, file num and seg num
newLabels = labels; 
FeatureInd.TimeFromOnset = 1; 
FeatureInd.SylFileNum = 2; 
FeatureInd.SylSegNum = 3; 

% spectrogram (smoothed and filtered)
[S,Time,F] = spectrogramELM(song,fs,specDT,0);
smwin = 4; 
Ssmooth = S(F>1000&F<5000,:); 
Ssmooth = log(Ssmooth) - min(log(Ssmooth(:))); 
ms = median(Ssmooth(:)); 
Ssmooth = [ms*ones(size(Ssmooth,1), smwin) Ssmooth ms*ones(size(Ssmooth,1), smwin)]; 
Ssmooth = conv2(Ssmooth, ones(1,2*smwin+1), 'valid'); %gausswin(2*smwin+1)'
row = size(newLabels,1); 
newLabels = [newLabels; Ssmooth];
FeatureInd.Spectrogram = row+(1:size(Ssmooth,1)); 

% unsmoothed spectrogram to plot in gui
row = size(newLabels,1); 
newLabels = [newLabels; S];
FeatureInd.ForGuiSpectrogram = row+(1:size(S,1)); 

% time ramp 
RealTime = newLabels(FeatureInd.TimeFromOnset,:);
beg_ind_syl = find(RealTime(1:end-1)==-2 & RealTime(2:end)>=0)+1;
end_ind_syl = find(RealTime(1:end-1)>=0 & RealTime(2:end)==-2);
junk_sorting = sort(end_ind_syl-beg_ind_syl,'descend');
if length(beg_ind_syl)>0
    length_biggest_syllable = junk_sorting(1); % previously junk_sorting(2), not sure why
else
    length_biggest_syllable = 0; 
end
RampRamp = create_realtime_ramp(beg_ind_syl,end_ind_syl,length_biggest_syllable,size(Ssmooth,2));
row = size(newLabels,1); 
newLabels = [newLabels; RampRamp];
FeatureInd.Ramp = row+(1:size(RampRamp,1)); 
