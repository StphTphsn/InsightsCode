function specDt = specDtELM(S);
specDt = diff(S')'; 
specDt = [specDt(:,1) specDt]; % so it's the same size as original S