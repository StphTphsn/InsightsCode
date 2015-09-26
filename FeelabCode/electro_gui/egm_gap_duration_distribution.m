function handles = egm_gap_duration_distribution(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files','Array of bin edges (ms)'},'Duration distribution',1,{['1:' num2str(filenum)],'7:7:300'}); % input dialog box
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
gdurs(:,1) = durs(1:(end-1),2);
gdurs(:,2) = durs(2:end, 1);
durs = gdurs;
durs = durs(:,2)-durs(:,1); % calculating duration (samples)
durs = durs/handles.fs*1000; % converting duration to miliseconds

figure

y = histc(durs,lst)/length(durs); % converting to probability
if ~isempty(durs) % duration is not empty
    plot((lst(1:end-1)+lst(2:end))/2,y(1:end-1)); % x-axis is the value in between the edges
end
xlim([0 lst(end)]);

xlabel('Duration (ms)');
ylabel('Probability');