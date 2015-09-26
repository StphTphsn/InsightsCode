function [data fs dateandtime label props] = egl_Surgery_Rig_daq(filename, loaddata)

label = 'Voltage (mV)';

load(filename)

if loaddata == 1
    data = rec.Data;
else
    data = [];
end

fs = rec.Fs;
dateandtime = rec.Time;
props = rec.Properties;