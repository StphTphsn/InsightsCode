function [y label] = egf_SAP_AM(a,fs,params);

label = 'SAP_Pitch chose'; 
if ischar(a) & strcmp(a,'params')
    y.Names = {};
    y.Values = {};
    return
end

[F L] = SAPfeatures_YM(a,fs);
ind = strmatch(label(5:end), L); 
y = F(:,ind); 