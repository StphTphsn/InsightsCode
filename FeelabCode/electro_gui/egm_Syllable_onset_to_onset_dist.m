function handles = egm_Syllable_onset_to_onset_dist(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files
 
filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Array of bin edges (ms)'},'Duration distribution',1,{['1:' num2str(filenum)],'10:10:1000'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
lst = str2num(answer{2}); % array of histogram bin edges (ms)

durs = zeros(0,2);
for c = fls % array of files
    f = find(handles.SegmentSelection{c} == 1);
    durs = [durs; handles.SegmentTimes{c}(f,:)]; % gathering all the onsets and offsets
end

durs = diff(durs(:,1)); %durs(:,2)-durs(:,1); % calculating duration (samples)
durs = durs/handles.fs*1000; % converting duration to miliseconds

figure; hold all

y = histc(durs,lst)/length(durs); % converting to probability
if ~isempty(durs) % duration is not empty
    plot((lst(1:end-1)+lst(2:end))/2,y(1:end-1)); % x-axis is the value in between the edges
end
xlim([0 lst(end)]);

xlabel('Onset-to-onset interval(ms)');
ylabel('Probability');
set(gcf, 'Color', [1 1 1], 'papersize', [4 3], 'paperposition', [0 0 4 3])
