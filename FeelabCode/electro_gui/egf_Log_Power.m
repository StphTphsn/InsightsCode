function [y label] = egf_Log_Power(a,fs,params)

label = 'Log Power';
if isstr(a) & strcmp(a,'params')
    y.Names = {'HighPass Order', 'HighPass Cutoff', 'Smooth Order', 'Smooth Cutoff'};
    y.Values = {'50','860','100','50'};
    return
end

persistent prstFilt3;
persistent prstFilt1;

%historic code used variable name audio instead of sig.
audio = a;
audio = audio - mean(audio);


%above 860Hz
if(isempty(prstFilt3) || (prstFilt3.fs ~= fs))
    prstFilt3.order = 50; %sufficient for 44100Hz of lower
    prstFilt3.win = hann(prstFilt3.order+1);
    prstFilt3.cutoff = 860; %Hz
    prstFilt3.fs = fs;
    prstFilt3.hpf = fir1(prstFilt3.order, prstFilt3.cutoff/(prstFilt3.fs/2), 'high', prstFilt3.win);
end
audio = filtfilt(prstFilt3.hpf, 1, audio);

%compute power
audioPow= audio.^2; 

%smooth the power, lpf:
if(isempty(prstFilt1) || (prstFilt1.fs ~= fs))
    prstFilt1.order = 100; 
    prstFilt1.win = hann(prstFilt1.order+1);
    prstFilt1.cutoff = 50; %Hz
    prstFilt1.fs = fs;
    prstFilt1.lpf = fir1(prstFilt1.order, prstFilt1.cutoff/(prstFilt1.fs/2), 'low', prstFilt1.win);
end
audioPow = filtfilt(prstFilt1.lpf, 1, audioPow);

%compute log Pow
y = log(audioPow + eps);
