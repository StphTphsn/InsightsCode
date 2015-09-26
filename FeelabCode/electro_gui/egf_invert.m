function [inv label] = egf_Invert(a,fs,params)
% ElectroGui function algorithm
% Inverts data

label = 'Inverted data';
if isstr(a) & strcmp(a,'params')
    inv.Names = {};
    inv.Values = {};
    return
end

inv = -a;