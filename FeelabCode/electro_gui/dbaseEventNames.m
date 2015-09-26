function names = dbaseEventNames(dbase)
for ii = 1:length(dbase.EventSources)
    names{ii} = [dbase.EventSources{ii} ' - ' dbase.EventFunctions{ii} ...
                 ' - ' dbase.EventDetectors{ii}];
end