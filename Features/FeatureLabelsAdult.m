function [newLabels FeatureInd] = FeatureLabels(data, specDT)
song = data.song;

fs = data.fs;
labels = data.labels; 
labels = labels(mod(1:length(labels), fs*specDT)==0)'; 

%%%%%%%%%%%%Calculate spectrogram%%%%%%%%%%%%
[S,Time,F] = spectrogramELM(song,fs,specDT,0);

% spectrogram and spectrogram deriv faster, for feature calculations
fasterDT = .001; 
[SFast,TimeFast,F] = spectrogramELM(song,fs,fasterDT,0); 
[Sd,TimeF,F] = spectrogramDerivELM(song,fs,fasterDT,0); 
Sfilt = SFast(F>1000&F<6000,:);
Sdfilt = Sd(:,F>1000&F<6000,:);
ConvertTimeFastToSlow = round(interp1(TimeFast, 1:length(TimeFast), Time)*100)/100; 

%[feat, labs] = SAPfeatures(song,fs,fasterDT)

Amplitude = amplitudeELM(SFast,F); % amplitude filtered 1-4kHz
Entropy = entropyELM(Sfilt); % Sfilt = S(F>1059&F<6353,:)
[gravity_center, deviation] = fun_gravity(SFast,F);
[yinPitch, aperiodicity] = fun_pitch(song,fs,TimeFast); 
yinPitch(isnan(yinPitch))= 0; 
aperiodicity(isnan(aperiodicity))= 0; 
PitchGoodness = pitchgoodnessELM(SFast, yinPitch,F); 

FeatureLabs = {'TimeFromOnset', ...
    'Amplitude', 'Entropy', 'GravityCenter', 'SpectralWidth', 'PitchGoodness', ...
    'YinPitch', 'Aperiodicity'};
FeatureCell = {labels ...
    Amplitude Entropy gravity_center deviation PitchGoodness ...
    yinPitch aperiodicity};

% time from onset
newLabels = labels; 
FeatureInd.TimeFromOnset = 1; 

% sound features
FeSpFr = 5:1:30; 
row = 1; 
for fi = 2:8 % for each feature, make a row for that feature, and rows for wavelet spectrogram of the feature.
    dsFeature = smooth(FeatureCell{fi}, specDT/fasterDT)';
    dsFeature = dsFeature(ConvertTimeFastToSlow); 
    newLabels = [newLabels; dsFeature];
    row = row+1;
    FeatureInd.(FeatureLabs{fi}) = row; 
    FeatureInd.([FeatureLabs{fi},'_Spectrum']) = [];
    for omega = 1
        [amp,W] = fastWavelet_morlet_convolution_parallel(FeatureCell{fi},FeSpFr,omega,fasterDT);
        amp = amp(:,ConvertTimeFastToSlow);
        newLabels = [newLabels; amp];
        FeatureInd.([FeatureLabs{fi},'_Spectrum']) = [FeatureInd.([FeatureLabs{fi},'_Spectrum']) row+(1:length(FeSpFr))]; 
        row = row+length(FeSpFr); 
    end
end

% spectrogram
smwin = 4; 
Ssmooth = S(F>1000&F<5000,:); 
Ssmooth = log(Ssmooth) - min(log(Ssmooth(:))); 
ms = median(Ssmooth(:)); 
Ssmooth = [ms*ones(size(Ssmooth,1), smwin) Ssmooth ms*ones(size(Ssmooth,1), smwin)]; 
Ssmooth = conv2(Ssmooth, ones(1,2*smwin+1), 'valid'); %gausswin(2*smwin+1)'
row = size(newLabels,1); 
newLabels = [newLabels; Ssmooth];
FeatureInd.Spectrogram = row+(1:size(Ssmooth,1)); 

row = size(newLabels,1); 
newLabels = [newLabels; S];
FeatureInd.ForGuiSpectrogram = row+(1:size(S,1)); 