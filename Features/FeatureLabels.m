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

%FM = FMELM(Sd);

Amplitude = amplitudeELM(SFast,F); % amplitude filtered 1-4kHz
Entropy = entropyELM(Sfilt); % Sfilt = S(F>1059&F<6353,:)
[gravity_center, deviation] = fun_gravity(SFast,F);
[yinPitch, aperiodicity] = fun_pitch(song,fs,TimeFast); 
yinPitch(isnan(yinPitch))= 0; 
aperiodicity(isnan(aperiodicity))= 0; 
PitchGoodness = pitchgoodnessELM(SFast, yinPitch,F); 

if isfield(data, 'units')
    units = data.units; 
    FiringRate = zeros(1,length(Time)); 
    spktimes = find(units); 
    for si = 1:length(spktimes)
        spkInd = min(length(Time),max(1,floor(spktimes(si)/fs/specDT)));
        FiringRate(spkInd) = FiringRate(spkInd)+1; 
    end
else
    FiringRate = nans(1,length(Time)); 
end


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
Ssmooth = S(F>1000&F<5000,:); 
Ssmooth = [Ssmooth zeros(size(Ssmooth,1),1)]; 
Ssmooth = conv2(log(Ssmooth), ones(2), 'valid'); 
newLabels = [newLabels; Ssmooth];
FeatureInd.Spectrogram = row+(1:size(Ssmooth,1)); 
row = row+1+size(Ssmooth,1);

% firing rate
newLabels = [newLabels; FiringRate];
FeatureInd.FiringRate = row; 

