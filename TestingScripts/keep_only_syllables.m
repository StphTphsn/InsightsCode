function [S, labelsKeep, times] = keep_only_syllables(S, labels, times, cuts)
fs = 40000;
specDT= 0.005;
labelsKeep = [];
for c = 1:size(cuts,2)
    lab = labels(cuts(1,c):cuts(2,c));
    lab = lab(mod(1:size(lab,1),round(fs*specDT))==0);
    labelsKeep = [labelsKeep; lab];
end
a = diff(labelsKeep);
labelsKeep([true; (a(1:end-1)>0 & a(2:end)<0); true])=0;
S(:,labelsKeep==-2)=[];
labelsKeep(labelsKeep==-2)=[];
times(labelsKeep==-2)=[];
labelsKeep = labelsKeep';