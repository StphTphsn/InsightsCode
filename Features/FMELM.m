function FM = FMELM(Sd); 
specDt = squeeze(Sd(1,:,:));
specDf = squeeze(Sd(2,:,:));
FM = atan(max(specDt.^2,[],1)./...
    max(specDf.^2+eps,[],1))*180/pi; 