function smIFR = IFR_smooth(IFR)
% Low pass filter: equiripple band pass at 25 Hz stop band at 75 Hz,
% attenuate by 80bD

Fs = 40000 ; % sampling frequency

% IFR = IFR(1:10:end) ; % subsample by a factor of 10

% low pass FIR filter
bandPassF = 25 ; %Hz
stopBandF = 75 ; %Hz, stop-band frequency
dBattenuate = 80 ; %dB

% ord = 200; % the order of the filter - ????

% d=fdesign.lowpass('n,fp,fst,ast',ord,bandPassF/(Fs/10/2),stopBandF/(Fs/10/2),dBattenuate);
d=fdesign.lowpass(bandPassF/(Fs/2), stopBandF/(Fs/2),1, dBattenuate);
hd=design(d,'equiripple') ; 
% fvtool(hd) ; % for debugging only
lpifr=filtfilt(hd.Numerator,1,IFR-mean(IFR));% apply LPF
smIFR=lpifr;
% % High-pass filter:
% hp_b = [1 -1]; 
% hp_a = [1 -.9988];
% 
% smIFR = filter(hp_b,hp_a,lpifr);
% % smIFR = filtfilt(hp_b,hp_a,lpifr);