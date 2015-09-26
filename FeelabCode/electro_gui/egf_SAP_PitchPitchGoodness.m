function [y label] = egf_SAP_PitchPitchGoodness(a,fs,params);

label = 'SAP_PitchPitchGoodness'; 
if ischar(a) & strcmp(a,'params')
    y.Names = {};
    y.Values = {};
    return
end

[F L] = SAPfeatures_YM(a,fs);
ind = strmatch('Pitch', L, 'exact'); 
indg = strmatch('Pitch goodness', L, 'exact'); 

y = F(:,ind).*(F(:,indg)>100); 