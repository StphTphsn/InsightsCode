function [snd lab] = egf_Unfiltered(a,fs,params)
% ElectroGui filter
% Does not filter sound

lab = 'Unfiltered';
if isstr(a) & strcmp(a,'params')
    snd.Names = {};
    snd.Values = {};
    return
end

snd = a;