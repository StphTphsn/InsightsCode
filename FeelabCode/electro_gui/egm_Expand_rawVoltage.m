function handles = egm_Expand_rawVoltage(handles)
% ElectroGui macro
% Expands .mat files from the surgery rig acquisition setup and saves
% individual rawVoltage traces in separate files

[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a .mat file');

wh = whos('-file',[pathname filename]);
str = {};
for c = 1:length(wh)
    if strcmp(wh(c).class,'cell')
        str{end+1} = wh(c).name;
    end
end
[indx,ok] = listdlg('ListString',str,'InitialValue',1:length(str),'Name','Variables','PromptString','Select variables to expand');
if isempty(indx)
    return
end

cnt = 0;
for c = 1:length(indx)
    load([pathname filename],wh(indx(c)).name);
    alldata = eval(wh(indx(c)).name);
    for d = 1:length(alldata)
        cnt = cnt+1;
        annot = alldata{d};
        rawVoltage = annot.rawVoltage;
        annot = rmfield(annot,'rawVoltage');
        newfile = [filename(1:end-4) '_' wh(indx(c)).name '_' num2str(d) '.mat'];
        save([pathname newfile],'annot','rawVoltage');
    end
end

msgbox(['Wrote ' num2str(cnt) ' files.'],'File expanded');