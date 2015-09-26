function [smIFR label] = egf_IFRSmooth1to75(a,fs,params)
% ElectroGui function algorithm
% Inverts data
% @Maya Bronfeld

label = 'Smoothed firing rate (Hz)';
if isstr(a) & strcmp(a,'params')
    smIFR.Names = {};
    smIFR.Values = {};
    return
end

% calculate IFR
IFR = zeros(size(a));
f = find(a);
for c = 1:length(f)-1
    IFR(f(c):f(c+1)) = fs/(f(c+1)-f(c));
end

% builf low pass FIR filter
bandPassF = 25 ; %Hz %start bandpass frequency x
stopBandF = 75 ; %Hz %stop-band frequency
dBattenuate = 80 ; %dB % attenuation

% d=fdesign.lowpass(bandPassF/(fs/2), stopBandF/(fs/2),1, dBattenuate);
% hd=design(d,'equiripple') ; 
% % fvtool(hd) ; % for debugging only
% lpifr=filtfilt(hd.Numerator,1,IFR-mean(IFR));% apply LPF
% % lpifr=filtfilt(hd.Numerator,1,IFR);% apply LPF
% smIFR = lpifr;
% % % High-pass filter (over 1Hz) :
% % hp_b = [1 -1]; 
% % hp_a = [1 -.9988];
% % 
% % smIFR = filter(hp_b,hp_a,lpifr);

% High-pass filter (over 1Hz) :
hp_b = [1 -1]; 
hp_a = [1 -.9988];

smIFR = filter(hp_b,hp_a,IFR);% apply HPF

%low pass filter:
d=fdesign.lowpass(bandPassF/(fs/2), stopBandF/(fs/2),1, dBattenuate);
hd=design(d,'equiripple') ; 
% fvtool(hd) ; % for debugging only

smIFR=filtfilt(hd.Numerator,1,smIFR);% apply LPF

