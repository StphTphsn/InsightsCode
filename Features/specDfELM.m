function specDf = specDfELM(S);
specDf = diff(S); 
specDf = [specDf(1,:); specDf]; % so it's the same size as original S