clear all; 

pathname = 'C:\Users\emackev\Dropbox (MIT)\Wavelets-tSNE\4202Jan18_s346\'; %'/Users/elm/Dropbox (MIT)/bouts/'; 
folder = '2013-11-03_Bouts'
load(fullfile(pathname,'analysis346')); 
[song,fs] = egl_AA_daq(fullfile(pathname,dbase.SoundFiles(5).name),1);

labels = {'AM', 'FM' ,'Entropy' , 'Amplitude' , 'Pitch goodness' , 'Pitch' ,...
    'Pitch chose', 'Pitch weight','Gravity center', 'Spectral s.d.','time'};

winstep =.005;  

%%%%%%%%%%%%Calculate spectrogram%%%%%%%%%%%%
[S,Time,F] = spectrogramELM(song,fs,winstep,1); 
imagesc(cdfscore(S',[50 100])')
set(gca, 'ydir', 'normal');colormap jet; shg

[feat, labels] = SAPfeatures(song,fs, winstep); 
%%
labels = {'AM', 'FM' ,'Entropy' , 'Amplitude' , 'Pitch goodness' , 'Pitch' ,...
    'Pitch chose', 'Pitch weight','Gravity center', 'Spectral s.d.','time'};

%%%%%%%%%%%%Amplitude%%%%%%%%%%%% 
Amplitude = amplitudeELM(S,F);
clf; plot(Amplitude);shg
hold on; plot(feat{4}, 'r');shg
%%
%%%%%%%%%%%%Entropy%%%%%%%%%%%%
Entropy = entropyELM(S); 
plot(Entropy);shg
hold on; plot(feat{3}, 'r');shg
% clf; hold on; plot(Time,cdfscore(Entropy, [0 50])*5, 'k'); shg
% 
% hold on; plot(Time,Entropy+5, 'r'); shg
%%
%%%%%%%%%%%%AM%%%%%%%%%%%%
AM = AMELM(S,F); 
clf; plot(cdfscore(AM, [80 100]));shg
clf; plot(cdfscore(AM, [0 20]));shg
hold on; plot(feat{1}, 'r');shg
%%
%%%%%%%%%%%%FM%%%%%%%%%%%%
FM = FMELM(S); 
clf; plot(FM);shg 
hold on; plot(feat{2}, 'r');shg
plot(cdfscore(Amplitude), 'g')
