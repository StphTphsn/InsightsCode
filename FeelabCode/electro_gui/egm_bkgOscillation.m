function handles = egm_bkgOscillation(handles)
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number

% user dialog to select analysis parameters and channel number:
answer = inputdlg({'Files','Select channel'},'',1,{num2str(filenum), '1'}); % input dialog box

if isempty(answer)% if user pushes the 'cancel'button'
    return
end
filenum = str2num(answer{1});
chanNum = str2num(answer{2}) ; % channel number
% load channel continuous data:
[chanData fs dt label props] = eval(['egl_AA_daq','([''' handles.path_name '\' handles.chan_files{chanNum}(filenum).name '''],1)']);

% rectify the signal:
recData = abs(chanData) ;  % rectified data - absolute value
recData = recData-mean(recData) ; % remove the mean
% recData = abs(hilbert(chanData)) ;  % rectified data - hilbert transform

% apply low pass filter on the rectified data:
cutFreq = 40 ; % Hz  % low pass cutoff frequency
fOrd = 4 ; % filter order
[bb,aa] = butter(fOrd, cutFreq/(fs/2),'low');% butterworth filter
yy = filter(bb,aa,recData) ; % apply low pass filter

% for debugging only:
% figure
% subplot(2,1,1)
% plot(chanData,'b') ; hold on; plot(recData+0.05,'r')
% plot(yy,'g')
% end debug segment

% get the PSD of the rectified signal
dataSpectgrm(yy,fs) 


function dataSpectgrm(data, sampleRate, startTime, maxfreq, colorRange)
% code taken from the acquisitionGUI library code, from function 'displayAudioSpecgram'
if(length(data) > 2000000)
    warning('displayAudioSpecgram: audio too long to take spectrogram.');
    return;
end

if(~exist('startTime'))
    startTime = 0;
end

if(~exist('maxfreq'))
    maxfreq = 100;
end

data = data - mean(data);% remove the mean
FFTSegmentSize = 2^15; %In number of samples; % bigger window gives better resolution in low frequencies
% FFTSegmentSize = 2048; %In number of samples;
% hanningWindowSize = FFTSegmentSize; %In number of samples.
fracOverlap = 0.8 ; % originally 0.9
segmentOverlap = round(FFTSegmentSize * fracOverlap); %In number of samples, cooresponds to fraction overlap given by 'fracOverlap'
% [b, freq, time] = specgram(data, FFTSegmentSize, sampleRate, hanningWindowSize, segmentOverlap);
[b, freq, time] = SPECTROGRAM(data, FFTSegmentSize, segmentOverlap,[1:100], sampleRate);
%b is a matrix of size length(freq) x length(time)
%If the sample rate is passed to specgram, then time is in seconds, and
%freq is in Hz.

%To plot the specgram we take the log of the power at each time and each
%frequency and display it as color
ndx = find(freq<maxfreq);
endTime = startTime + (length(data)/sampleRate);
stepTime = (endTime - startTime)/ (length(time)-1);

% min(min(20*log10(abs(b(ndx,:)) + .02)))
% max(max(20*log10(abs(b(ndx,:)) + .02)))

figure;
subplot(2,1,1)
if(~exist('colorRange'))
    imagesc(startTime:stepTime:endTime,freq(ndx),20*log10(abs(b(ndx,:)) + .02)); axis xy;
else
    imagesc(startTime:stepTime:endTime,freq(ndx),20*log10(abs(b(ndx,:)) + .02), colorRange); axis xy;
end

xlabel('time (s)');
ylabel('freq (Hz)');

sPSD = 20*log10(abs(b(ndx,:)) + .02) ; 
sPSD = sum(sPSD,2) ; 
subplot(2,1,2)
plot(freq(ndx),sPSD)