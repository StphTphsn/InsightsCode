function [features labels] = egf_AApitch(TS,fs,par);
% based on AA's estimate pitch using cepstrum

labels = {'Pitch' ,'Pitch goodness', 'Entropy'};
if isstr(TS) & strcmp(TS,'params')
    features.Names = {};
    features.Values = {};
    return
end

[pitch pitchGoodness harmonicPower time entropy]=estimatePitch(TS,fs);
features={pitch,pitchGoodness,entropy};