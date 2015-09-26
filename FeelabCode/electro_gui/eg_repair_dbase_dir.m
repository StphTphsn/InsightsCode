function eg_repair_dbase_dir(dbase_file)
% Changes dbase directory to the current directory of the dbase file

[new_path, name, ext, versn] = fileparts(dbase_file);
if isempty(new_path)
    new_path = pwd;
    warning('No path given. Assuming current directory.')
end
load(dbase_file, 'dbase');
dbase.PathName = new_path;
save(dbase_file, 'dbase')