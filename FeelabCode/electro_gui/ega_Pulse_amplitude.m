function [amp label] = ega_Pulse_amplitude(a,fs,ev,indx,xlm)

if length(ev) ~= 2
    errordlg('Events must have two components: onsets and offsets!','Error');
    amp = zeros(size(ev{1}));
else
    for c = 1:length(ev{1})
        if ev{2}(c)>ev{1}(c)
            amp(c) = mean(a(ev{1}(c)+1:ev{2}(c)))*1000;
        else
            amp(c) = mean(a(ev{2}(c)+1:ev{1}(c)))*1000;
        end
    end
end
label = 'Pulse amplitude (µA)';