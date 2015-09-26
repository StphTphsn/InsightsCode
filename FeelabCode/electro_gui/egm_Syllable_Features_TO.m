function handles = egm_Syllable_Features_TO(handles)
%%% electro_gui macro for automatically clustering segmented syllable
%%% using SAP features
%%% Be sure to have SAP features (any one is fine) displayed on either axis 1 or 2.
%%% Tatsuo Okubo
%%% 2009/07/02

% Get information about which functions are currently displayed in ElectroGui
axs = [];
if get(handles.popup_Channel1,'value') > 1
    axs = 1;
end
if get(handles.popup_Channel2,'value') > 1
    axs = [axs 2];
end
if isempty(axs)
    errordlg('Display SAP features first!','Error');
    return
end

chan = handles.BackupChan{1}; % SAP feature values. Note that length is different
lab = handles.BackupLabel{1}; % SAP feature labels

filenum = str2num(get(handles.edit_FileNumber,'string')); % get file number
answer = inputdlg({'Files'},'SAP features',1,{['1:' num2str(handles.TotalFileNumber)]}); % input dialog box
if isempty(answer)
    error('No file specified.')
    return
end
fls = eval(answer{1}); % array of files to be analyzed, convert from string to number

Stack = []; % stack of SAP features of all the syllables segmented

for n = fls; % file number
    f = find(handles.SegmentSelection{n}==1); % index of selected syllables
    for c = 1:length(f) % syllable number
        for j = 1:length(lab) % for all SAP features
            t1 = max([1 round(handles.SegmentTimes{n}(f(c),1)*length(chan{j})/length(handles.sound))]); % syllable onset time in SAPfeature index
            t2 = min([length(chan{j}) round(handles.SegmentTimes{n}(f(c),2)*length(chan{j})/length(handles.sound))]); % syllable offset time in SAPfeature index
            
            if t1>t2
                pause
            end
            
            handles.SegmentSAP{n}{c}(j) = mean(chan{j}(t1:t2)); % mean value during the syllable
            
            MeanSAP(1,j) = mean(chan{j}(t1:t2));
        end
        Duration = (handles.SegmentTimes{n}(f(c),2) - handles.SegmentTimes{n}(f(c),1))./handles.fs;
        Features = [MeanSAP,Duration];
        Stack = [Stack; Features];
    end
end

[coef score latent] = princomp(Stack); % PCA to reduce dimension
figure(3230)
scatter3(score(:,1),score(:,2),score(:,3)); % 3 PCs
xlabel('PC 1')
ylabel('PC 2')
zlabel('PC 3')
grid on

figure(3231)
hist3([score(:,1),score(:,2)])

return