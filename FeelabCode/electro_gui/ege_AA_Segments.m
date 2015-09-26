function [events labels] = ege_AA_Segments(data,fs,thres,params)
% ElectroGui event detector
% Finds segments.

labels = {'Segment Start','Segment Stop'};
if isstr(data) & strcmp(data,'params')
    events.Names = {'Edge Threshold', 'Minimum duration (ms)','Maximum duration (s)', 'Minimum interval (ms)'};
    events.Values = {'10','7','1','7'};
    return
end

edge_thres = str2num(params.Values{1});
min_dur = str2num(params.Values{2})/1000;
max_dur = str2num(params.Values{3});
min_stop = str2num(params.Values{4})/1000;

%Find threshold crossings:
trigCross = find(data(1:end-1)<thres & data(2:end)>=thres);
syllUpCross = find(data(1:end-1)<edge_thres & data(2:end)>=edge_thres);
syllDownCross = find(data(1:end-1)>edge_thres & data(2:end)<=edge_thres);

%Eliminated unpaired crossings.
if(length(syllUpCross) > 0 & length(syllDownCross) > 0)
    if(syllUpCross(1) > syllDownCross(1))
        syllUpCross = syllUpCross(2:end);
    end
end
if(length(syllUpCross) > 0 & length(syllDownCross) > 0)
    if(syllDownCross(end) < syllUpCross(end))
        syllDownCross = syllDownCross(1:end-1);
    end
end

%Determine which syllable crossing represent a syllable.
bKeep = false(length(syllUpCross),1);
for(nSyll = 1:length(syllUpCross))
    bKeep(nSyll) = any(syllUpCross(nSyll)<trigCross & syllDownCross(nSyll)>trigCross);
end
syllUpCross = syllUpCross(bKeep);
syllDownCross = syllDownCross(bKeep);

if(length(syllUpCross) > 1)
    bndx = [syllUpCross(2:end)- syllDownCross(1:end-1) > min_stop*fs; true];
    syllUpCross = syllUpCross(bndx);
    syllDownCross = syllDownCross(bndx);
end
        
%Remove syllables that are too short or long
bndx = syllDownCross - syllUpCross > min_dur*fs;
bndx = bndx & (syllDownCross - syllUpCross < max_dur*fs);
syllUpCross = syllUpCross(bndx);
syllDownCross = syllDownCross(bndx);

events{1} = syllUpCross;
events{2} = syllDownCross;
