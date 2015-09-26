function [data fs dateandtime label props] = egl_AA_daq_mat(filename, loaddata)

label = 'Voltage (mV)';

load(filename);

fs = info.fs;
dateandtime = info.absStartTime;
props.Names = info.propertyNames;
props.Types = info.propertyTypes;
props.Values = info.propertyValues;