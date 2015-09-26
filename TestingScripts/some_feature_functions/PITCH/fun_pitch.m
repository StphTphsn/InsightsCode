function [pitch, aperiodicity] = fun_pitch(raw_sound, sampling_frequency,Time)
R = yin(raw_sound,sampling_frequency);
pitch = interp1(R.hop*(0:length(R.f0)-1)/R.sr, R.f0,Time); 
aperiodicity = interp1(R.hop*(0:length(R.f0)-1)/R.sr, R.ap,Time); 
% pitch = interp1(R.hop*(0:length(R.f0)-1),R.f0,(0:length(raw_sound)-1))';
% pitch = pitch(mod(0:length(pitch)-1,dt*sampling_frequency)==0);
