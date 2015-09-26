function handles = egm_Syllable_duration_distribution2(handles)
% ElectroGui macro
% Plots the syllable distribution of all analyzed files

filenum = str2num(get(handles.edit_FileNumber,'string'));
answer = inputdlg({'Files','Array of bin edges (ms)','# Bins to Smooth'},'Duration distribution',1,{['1:' num2str(filenum)],'7:7:700','3'});
if isempty(answer)
    return
end
fls = eval(answer{1});
lst = str2num(answer{2});
s=eval(answer{3});

durs = zeros(0,2);
for c = fls
    f = find(handles.SegmentSelection{c} == 1);
    durs = [durs; handles.SegmentTimes{c}(f,:)];
end

durs = durs(:,2)-durs(:,1);
durs = durs/handles.fs*1000;

figure

y = histc(durs,lst)/length(durs);
if ~isempty(durs)
    plot((lst(1:end-1)+lst(2:end))/2,smooth(y(1:end-1),s));
end
xlim([0 lst(end)]);

xlabel('Duration (ms)');
ylabel('Probability');