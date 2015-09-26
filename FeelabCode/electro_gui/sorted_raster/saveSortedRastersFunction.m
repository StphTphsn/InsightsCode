function saveSortedRastersFunction(rasterParameters, filenameFull)
% rasterParameters Cell array of parameter structs, each created by
%                  getSortedRasterParameters()
% filenameFull     OPTIONAL filename for the function. If filenameFull is
%                  omitted, the user will be prompted to choose a filename.



if nargin < 2 % If filname not given as argument, prompt for a file name
    [filename, pathname] = uiputfile('*.m', 'Save function as');
    if isscalar(filename) && filename == 0 % user pressed cancel
        return
    end
    filenameFull = fullfile(pathname, filename);
end
[pathname, funcname, ~] = fileparts(filenameFull);
% filenameFull   is the name of the file with path (e.g.
%                'C:\code\mySortedRaster.m')
% funcname       is the name of the function (e.g. 'mySortedRaster')

%% Save parameters
pFilename = cell(size(rasterParameters));
for ii = 1:length(rasterParameters)
    p = rasterParameters{ii}; %#ok
    pFilename{ii} = [funcname int2str(ii) '.mat'];
    if exist(pFilename{ii}, 'file') == 2
        error('File already exists: %s', pFilename{ii})
    end
    save(fullfile(pathname, pFilename{ii}), 'p')
end

%% Write M-file
fh = fopen(filenameFull, 'w');
try
    fprintf(fh, 'function figureHandle = %s(dbase)\n\n', funcname);
    fprintf(fh, 'pathname = fileparts(mfilename(''fullpath''));\n\n');
    for ii = 1:length(rasterParameters)
        
        % Input argument to sorted_rasters() -- If this is the first call, pass the
        % dbase. On subsequent calls, pass the handle to the gui.
        if ii == 1
            argin = 'dbase';
        else
            argin = 'guiHandle';
        end
        
        % Output mode -- If this is the last call, get the finished raster.
        % Otherwise, get the handle to the gui so we can pass it along.
        if ii == length(rasterParameters)
            outmode = 'raster';
            argout = 'figureHandle';
        else
            outmode = 'gui';
            argout = 'guiHandle';
        end
        
        % This is the code for making one raster
        fprintf(fh, 'load(fullfile(pathname, ''%s''), ''p'')\n', pFilename{ii});
        fprintf(fh, 'p.Output = ''%s'';\n', outmode);
        fprintf(fh, '%s = sorted_rasters(%s, p);\n\n', argout, argin);
    end
catch err
    fclose(fh);
    rethrow(err)
end

fclose(fh);
open(filenameFull)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example output file:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function figureHandle = FIXME_filename(dbase)
%
% load(FIXME_paramfile1, 'p')
% p.Output = 'gui';
% guiHandle = sorted_rasters(dbase, p)
%
% load(FIXME_paramfile2, 'p')
% p.Output = 'gui';
% guiHandle = sorted_rasters(guiHandle, p);
%
% load(FIXME_paramfile3, 'p')
% p.Output = 'raster';
% figureHandle = sorted_rasters(guiHandle, p);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%