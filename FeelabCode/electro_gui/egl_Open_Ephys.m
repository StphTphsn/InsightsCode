function [data, fs, dateandtime, label, props] = egl_Open_Ephys(filename, loaddata)

label = 'Voltage (mV)';

[data, ~, info] = load_open_ephys_data(filename);
data = data.*info.header.bitVolts;
fs = info.header.sampleRate;
dateandtime = datenum(info.header.date_created, 'dd-mmm-yyyy HHMMSS');
props.Names = {'Comment'};%made up properties because I don't understand what they should be
props.Types = 1;
props.Values = {''};