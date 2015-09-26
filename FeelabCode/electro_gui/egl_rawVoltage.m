function [data fs dateandtime label props] = egl_rawVoltage(filename, loaddata)
% ElectroGui file loader
% Reads data files recorded on the surgery rig acquisition setup
% Files must first be expanded using egm_Expand_rawVoltage

load(filename,'annot');
fs = 40000;
dateandtime = annot.time;
label = 'Voltage (mV)';

props.Names = {'Electrode type','Head angle','ML','AP','DV','Manipulation'};
props.Values = {annot.electrodeType annot.headAngle annot.ML annot.AP annot.DV annot.manip};
props.Types = [3 1 1 1 1 1];

if loaddata == 1
    load(filename,'rawVoltage')
    data = rawVoltage/annot.gain*1000;
else
    data = [];
end