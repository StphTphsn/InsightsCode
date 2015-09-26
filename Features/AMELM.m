function AM = AMELM(S,F); 
fRange = [1000 4000]; 
filtS = S(F>fRange(1)&F<fRange(2),:);
specDt = specDtELM(filtS);
AM=sum(specDt,1)./amplitudeELM(S,F);
