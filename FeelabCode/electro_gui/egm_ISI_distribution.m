function handles = egm_ISI_distribution(handles)
% ElectroGui macro
% Plots the inter-spike-interval distribution of all analyzed files

filenum = str2num(get(handles.edit_FileNumber,'string')); % get current file number
answer = inputdlg({'Files (multiple files in [] )','Array of bin edges (ms)', 'log xaxis?'},'ISI distribution',1,{[num2str(filenum)],'logspace(-3,3.75,100)', '1'}); % input dialog box
if isempty(answer)
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number
lst = str2num(answer{2}); % array of histogram bin edges (ms)
logaxis = str2num(answer{3});
%EventInd = str2num(answer{4});
ISIs = zeros(0,1);

% user dialog to select data (added by Maya):
str=[] ; 
ind = ones(1,2) ; 
for c = 1:length(handles.EventTimes)
    [param labels] = eval(['ege_' handles.EventDetectors{c} '(''params'')']);
    for d = 1:length(labels)
        str{end+1} = [handles.EventSources{c} ' - ' handles.EventFunctions{c} ' - ' labels{d}];
        ind(length(str),1) = c;
        ind(length(str),2) = d;
    end
end

[iSelect,OK] = listdlg('PromptString','Please select spike source','ListString',str, 'ListSize',[300 300],'SelectionMode','single' ) ;

if ~OK % if user pushes the 'cancel'button' 
    return
end

for ff = fls % array of files
    spiketimes = handles.EventTimes{ind(iSelect,1)}{ind(iSelect,2),ff}; % 
    ss =handles.EventSelected{ind(iSelect,1)}{ind(iSelect,2),ff}; % 
    spiketimes = spiketimes(logical(ss)) ;  % remove unselected events % maya
    ISIs = [ISIs; diff(spiketimes)]; 
end


ISIs = ISIs/handles.fs*1000; % converting duration to miliseconds

figure

y = histc(ISIs,lst);% /length(ISIs); % converting to probability
if ~isempty(ISIs) % duration is not empty
    bar((lst(1:end-1)+lst(2:end))/2,y(1:end-1)); % x-axis is the value in between the edges
end
if logaxis
    set(gca, 'xscale', 'log')
end
xmin = find(y); xmin = xmin(1); xmin = lst(xmin);
xlim([xmin lst(end)]);
ylim([0 max(y)*1.2]);
xlabel('ISI (ms)');
ylabel('Count'); 