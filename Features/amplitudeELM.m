function Amplitude = amplitudeELM(S,F); 
fRange = [1000 4000]; 
filtS = S(F>fRange(1)&F<fRange(2),:);
Amplitude = 10*log10(sum(filtS,1))+100; %100 db baseline... arbitrary, maybe change
