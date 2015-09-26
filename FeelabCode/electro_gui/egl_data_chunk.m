function [data fs dateandtime label props] = egl_data_chunk(filename, loaddata)
error('under construction');
label = 'Voltage (mV)';

if loaddata == 1
    [data info] = daq_readDatafile_forEG(filename,1,[]);
else
    [data info] = daq_readDatafile_forEG(filename,1,0);
end

fs = info.fs;
dateandtime = info.absStartTime;
props.Names = info.propertyNames;
props.Types = info.propertyTypes;
props.Values = info.propertyValues;


if iscell(props.Types)
    dummy = zeros(size(props.Types));
    for c = 1:length(dummy)
        dummy(c) = props.Types{c};
    end
    props.Types = dummy;
end



function [out1, out2, out3, out4, out5, out6, out7, out8] = daq_readDatafile_forEG(filename, bUseNewOutput, dataRange)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read a data file created using Aaron's daq controller.
%
% Inputs: filename - string specifing the filename of the data file.
%        bNewOutput - (optional) returns output in more understandable format.
%        dataRange - (optional) empty([]) loads all samples, 0 load no samples, 
%                               [startSamp, endSamp] loads the specifed range. (1 is the first sample).  
%
% Old output format:
%   [HWChannels, data, time, startSampNumber, names, values, trigFileFormat]
% New output format:
%   [data, info]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%New Output Format
% out1, data: matrix in which each column contains data from the specified hardware
%             channel number in daqchannels.
% out2, info: Structure containing:
%                   absStartTime: time at which file started (matlab time) (only approximate for fileformats -1 and -2)
%                   startSampleNum: the number of the first sample in the file referenced to when data acq began.  (useful for resolving overlapping files) 
%                   numSamples: the number of samples per channel in the file.
%                   fs: the sampling rate in Hz. 
%                   daqchannels: the hardware channels recorded in the file
%                   propertyNames: cell array containing property names
%                   propertyTypes: cell array containing property types
%                                  (1=String, 2=Boolean, 3=List)
%                   propertyValues: cell array containing property values
%                   trigFileFormat: the datafile file format number.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Old Output Format
% out1, HWChannels:  the hardware channel numbers of the columns of the data
%             matrix.
% out2, data:  matrix in which each column contains data from the specified HW
%             channel number in HWChannels.
% out3, time: In file format -1 and -2, column vector containing the time relative to daq_Start each row of
%                                 data was taken.
%             In file format -3 and higher: a vector containing
%             [acquisitionStartTime (6 element datevec),
%             approxFileCreatedTime (6 element datevec), startSampTime (seconds since acquisition start), endSampTime (seconds), endSampNumber (integer)]
% out4, startSampNumber: start sample number.
% out5, names: cell array of property names.
% out6, values: cell array of property values.
% out7, trigFileFormat: the fileFormat of the datafile.
% out8, types: cell array of property types. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTES:
% As of file format '-4', multiple sessions of recording cannot be appended
% to the same file.
%
% As of file format '-2', if two saving sessions are appended into the 
% same file, this function will return the first session.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%NOTE:  DO NOT CHANGE THE FILE FORMAT, 
%%%%       WITHOUT INCREMENTING THE TRIGGER FILE FORMAT ID NUMBER!!!! 

if(~exist(filename,'file'))
    error('File does not exist');
end
if(~exist('bUseNewOutput','var'))
    bUseNewOutput = false;
end
if(~exist('dataRange','var'))
    dataRange = [];
end

%Init names and values to empty
names = {};
values = {};

%Open the file
fid = fopen(filename);
%Read first element in the file which is the file format
trigFileFormat = fread(fid, 1, 'float64');

if(trigFileFormat == -4)
    
    %Read absolute clock times in datevec format, 6 number [Y,M,D,H,M,S]. 
    acquisitionStartTime = fread(fid, 6, 'float64');  %Time the daq was started.
    approxFileCreatedTime = fread(fid, 6, 'float64'); %Approximate time this file was writtin.
    
    %Read the number of hardware channels
	numHWChannels = fread(fid, 1, 'float64'); 

    %Read the hardware indices of the recorded channels.
	HWChannels = fread(fid, numHWChannels, 'float64');
    
    %Read information for converting data from native format to doubles
    %double data= (native data)*(native scaling constant) + (native offset constant)
    for(nChan = 1:numHWChannels)
        nativeScale(nChan) =  fread(fid, 1, 'float64'); 
        nativeOffset(nChan) =  fread(fid, 1, 'float64'); 
    end
    
    %Read the name of the native data format.
    nLetter = 1;
    while(true)
        c = fread(fid, 1, 'float64');
        if(c == trigFileFormat)
            break;
        end
        nativeDataType(nLetter) = c;
        nLetter = nLetter + 1;
    end
    nativeDataType = char(nativeDataType);
    
    %reset fid position to just after data
    if(strcmp(nativeDataType,'double'))
        byteSize = 8;
    elseif(strcmp(nativeDataType,'int16'))
        byteSize = 2;
    elseif(strcmp(nativeDataType,'int32'))
        byteSize = 4;
    else
        error(['nativeDataType not checked for.  Add ', nativeDataType, ' to daq_readDatafile']);
    end
    
    %Read internal daq timing for first sample in file.
    startSampNumber = fread(fid, 1, 'float64'); %The sample number.  First sample after daq was started is sample #1.
    startSampTime = fread(fid, 1, 'float64'); %The time the sample number in seconds from first sample. The function getdata return a time for each sample.
            
    %Run through file backward until we reach the end of data marker
    fidDataStart = ftell(fid);
    fseek(fid, 0, 'eof');
    fidScan = ftell(fid);
    while(true)
        fidScan = fidScan - 1;
        fseek(fid, fidScan, 'bof');
        test = fread(fid, 3, nativeDataType);
        if(isequal(test, [-4;-4;-4]))
            break;
        end
        if(fidScan <= 1)
            error('Failed to find mark');
        end
    end
        
    %Read internal daq timing for last sample in file.
    endSampNumber = fread(fid, 1, 'float64');
    endSampTime = fread(fid, 1, 'float64');        

    %Read the requested data.
    if(length(dataRange)==1 && dataRange(1) == 0)
        %read no data.
        data = [];
    else          
        %read specifed sample range
        if(isempty(dataRange))
            dataRange = [1,endSampNumber-startSampNumber+1];
        end
        if((length(dataRange)==2) && (dataRange(1)>0 && dataRange(1)<=dataRange(2) && dataRange(2)<=(endSampNumber-startSampNumber+1)))
            fidNextPos = ftell(fid);         
            fseek(fid, fidDataStart + (dataRange(1)-1)*byteSize*numHWChannels, 'bof');
            data = fread(fid, (dataRange(2)-dataRange(1)+1)*numHWChannels, nativeDataType);

            %Reshape the datafile so that each column represents a channel.
            data = reshape(data, numHWChannels, length(data)/numHWChannels)';

            %Convert the daq native format to a double
            for(nChan = 1:numHWChannels)
                data(:,nChan) = data(:,nChan)*nativeScale(nChan) + nativeOffset(nChan);
            end   

            fseek(fid, fidNextPos, 'bof');    
        else
            error('Invalid dataRange specified.')
        end
    end

    %Read any name value pairs at end of file.
    names = {};
    values = {};
    types = {};
    numPairs = 0;
    while(~feof(fid))
        numPairs = numPairs + 1;
        strLen = fread(fid, 1, 'float64');
        if(isempty(strLen))
            break;
        end
        temp = fread(fid, strLen, 'char');
        names{numPairs} = char(temp');
        strLen = fread(fid, 1, 'float64');
        temp = fread(fid, strLen, 'char');
        values{numPairs} = char(temp');
        types{numPairs} = 1;
    end

    %close the file.
    fclose(fid);    
        
    %Setup output
    if(bUseNewOutput)
        info.absStartTime = datenum(acquisitionStartTime') + startSampTime/(24*60*60); 
        info.startSampleNum = startSampNumber;
        info.daqchannels = HWChannels;        
        info.numSamples = endSampNumber - startSampNumber + 1;
        info.fs = 1/ ((endSampTime - startSampTime) / (endSampNumber - startSampNumber));
        info.propertyNames = names;
        info.propertyValues = values;
        info.propertyTypes = types;
        info.trigFileFormat = trigFileFormat;
        out1 = data;
        out2 = info;
        [out3,out4,out5,out6,out7,out8] = deal([]);
    else
        %Create time array:
        time = [acquisitionStartTime', approxFileCreatedTime', startSampTime, endSampTime, endSampNumber];        
        out1 = HWChannels;
        out2 = data;
        out3 = time;
        out4 = startSampNumber;
        out5 = names;
        out6 = values;
        out7 = trigFileFormat;
        out8 = types;
    end
    
elseif(trigFileFormat == -3)
    %Read absolute clock times in datevec format, 6 number [Y,M,D,H,M,S]. 
    acquisitionStartTime = fread(fid, 6, 'float64'); %Time the daq was started.
    approxFileCreatedTime = fread(fid, 6, 'float64'); %Approximate time this file was writtin.
    
    %Read the number of hardware channels
	numHWChannels = fread(fid, 1, 'float64');

    %Read the hardware indices of the recorded channels.
	HWChannels = fread(fid, numHWChannels, 'float64');
    
    %Read information for converting data from native format to doubles
    %double data= (native data)*(native scaling constant) + (native offset constant)
    for(nChan = 1:numHWChannels)
        nativeScale(nChan) =  fread(fid, 1, 'float64');
        nativeOffset(nChan) =  fread(fid, 1, 'float64');
    end
    
    %Read the name of the native data format.
    nLetter = 1;
    while(true)
        c = fread(fid, 1, 'float64');
        if(c == trigFileFormat)
            break;
        end
        nativeDataType(nLetter) = c;
        nLetter = nLetter + 1;
    end
    nativeDataType = char(nativeDataType);
     
    %reset fid position to just after data
    if(strcmp(nativeDataType,'double'))
        byteSize = 8;
    elseif(strcmp(nativeDataType,'int16'))
        byteSize = 2;
    elseif(strcmp(nativeDataType,'int32'))
        byteSize = 4;
    else
        error(['nativeDataType not checked for.  Add ', nativeDataType, ' to daq_readDatafile']);
    end
    
    %Read internal daq timing for first sample in file.
    startSampNumber = fread(fid, 1, 'float64'); %The sample number.  First sample after daq was started is sample #1.
    startSampTime = fread(fid, 1, 'float64'); %The time the sample number in seconds from first sample. The function getdata return a time for each sample.

    %Skip to end of file
    fidDataStart = ftell(fid);
    fseek(fid, -16, 'eof');
    
    %Read internal daq timing for last sample in file.
    endSampNumber = fread(fid, 1, 'float64');
    endSampTime = fread(fid, 1, 'float64');    
    
    %Read the requested data.
    if(length(dataRange)==1 && dataRange(1) == 0)
        %read no data.
        data = [];
    else          
        %read specifed sample range
        if(isempty(dataRange))
            dataRange = [1,endSampNumber-startSampNumber+1];
        end
        if((length(dataRange)==2) && (dataRange(1)>0 && dataRange(1)<=dataRange(2) && dataRange(2)<=(endSampNumber-startSampNumber+1)))      
            fseek(fid, fidDataStart + (dataRange(1)-1)*byteSize*numHWChannels, 'bof');
            data = fread(fid, (dataRange(2)-dataRange(1)+1)*numHWChannels, nativeDataType);

            %Reshape the datafile so that each column represents a channel.
            data = reshape(data, numHWChannels, length(data)/numHWChannels)';

            %Convert the daq native format to a double
            for(nChan = 1:numHWChannels)
                data(:,nChan) = data(:,nChan)*nativeScale(nChan) + nativeOffset(nChan);
            end   
        else
            error('Invalid dataRange specified.')
        end
    end

    %close the file.
    fclose(fid);    
       
    %Setup output
    if(bUseNewOutput)
        info.absStartTime = datenum(acquisitionStartTime') + startSampTime/(24*60*60);
        info.startSampleNum = startSampNumber;
        info.daqchannels = HWChannels;
        info.numSamples = endSampNumber - startSampNumber + 1;
        info.fs = 1/ ((endSampTime - startSampTime) / (endSampNumber - startSampNumber));
        info.propertyNames = {};
        info.propertyValues = {};
        info.propertyTypes = {};
        info.trigFileFormat = trigFileFormat;
        out1 = data;
        out2 = info;
        [out3,out4,out5,out6,out7,out8] = deal([]);
    else
        %Create time array:
        time = [acquisitionStartTime', approxFileCreatedTime', startSampTime, endSampTime, endSampNumber];        
        out1 = HWChannels;
        out2 = data;
        out3 = time;
        out4 = startSampNumber;
        out5 = {};
        out6 = {};
        out7 = trigFileFormat;
        out8 = {};
    end
    
elseif(trigFileFormat == -2)
            
 	%Parse the first float64 as the number of channels
	startSampNumber = fread(fid, 1, 'float64');   
    
	%Parse the second float64 as the number of channels
	numHWChannels = fread(fid, 1, 'float64');
	
	%Read the hardware indices of the recorded channels.
	HWChannels = fread(fid, numHWChannels, 'float64'); 
	
    %Extract number of samples and sampling rate.
    fidDataStart = ftell(fid);
    fread(fid, numHWChannels, 'float64');
    startSampTime = fread(fid, 1, 'float64');
    fseek(fid,-16,'eof'); %go back two values: the -2 marker and last time sample.
    endSampTime = fread(fid, 1, 'float64');    
    fidDataEnd = ftell(fid);
    
    numSamples = ((fidDataEnd - fidDataStart)/8) / (numHWChannels+1);
    fs = 1/((endSampTime - startSampTime)/(numSamples-1));
    
    %Read the requested data.
    if(length(dataRange)==1 && dataRange(1) == 0)
        %read no data.
        data = [];
    else          
        %read specifed sample range
        if(isempty(dataRange))
            dataRange = [1,numSamples];
        end
        if((length(dataRange)==2) && (dataRange(1)>0 && dataRange(1)<=dataRange(2) && dataRange(2)<=numSamples))      
            fseek(fid, fidDataStart + (dataRange(1)-1)*8*(numHWChannels+1), 'bof');
            data = fread(fid, (dataRange(2)-dataRange(1)+1)*(numHWChannels+1), 'float64');
        else
            error('Invalid dataRange specified.')
        end
    end
	
    %Reshape the datafile so that each column represents a channel.
    data = reshape(data, numHWChannels+1, length(data)/(numHWChannels+1))';
    
	%Break off the last column as the time stamp for each sample.
	time = data(:,end);
	data = data(:,1:end-1);
    
    %close the file.
    fclose(fid);  
    
    %Setup output
    if(bUseNewOutput)
        [junk, sndx] = regexp(filename, '_d\d\d\d\d\d\d_');
        endx = regexp(filename, 'chan\d');
        strTimeCreated = filename(sndx(end)+1:endx(end)-1);
        info.absStartTime = datenum(strTimeCreated,'yyyymmddTHHMMSS'); %approximate        
        info.startSampleNum = startSampNumber;
        info.daqchannels = HWChannels;        
        info.numSamples = numSamples;
        info.fs = fs;
        info.propertyNames = {};
        info.propertyValues = {};
        info.propertyTypes = {};
        info.trigFileFormat = trigFileFormat;
        out1 = data;
        out2 = info;
        [out3,out4,out5,out6,out7,out8] = deal([]);
    else
        %Create time array:
        out1 = HWChannels;
        out2 = data;
        out3 = time;
        out4 = startSampNumber;
        out5 = {};
        out6 = {};
        out7 = trigFileFormat;
        out8 = {};
    end
    
elseif(trigFileFormat == -1)
    %read remainder of file.
    data = fread(fid, inf, 'float64');
    fclose(fid);    
    
 	%Parse the second float64 as startSample number.  Useful for orienting
 	%across files.
	startSampNumber = data(1);   
    
	%Parse the second float64 as the number of channels
	numHWChannels = data(2);
	
	%Read the hardware indices of the recorded channels.
	HWChannels = data(3:3+numHWChannels-1);
	
	%Reshape the datafile so that each column represents a channel.  (Time
	%is stored as the last channel, so add one).
	data = reshape(data(3+numHWChannels:end), numHWChannels+1, length(data(3+numHWChannels:end))/(numHWChannels+1))';
	
	%Break off the last column as the time stamp for each sample.
	time = data(:,end);
	data = data(:,1:end-1);
    
    %Extract requested region
    if(length(dataRange)==1 && dataRange(1)==0)
        dataclip = [];
        timeclip = [];
    elseif(length(dataRange)==2)
        dataclip = data([dataRange(1):dataRange(2)],:);
        timeclip = time([dataRange(1):dataRange(2)]);
    end
    
    %Setup output
    if(bUseNewOutput)
        [junk, sndx] = regexp(filename, '_d\d\d\d\d\d\d_');
        endx = regexp(filename, 'chan\d');
        strTimeCreated = filename(sndx(end)+1:endx(end)-1);
        info.absStartTime = datenum(strTimeCreated,'yyyymmddTHHMMSS'); %approximate
        info.startSampleNum = startSampNumber;
        info.daqchannels = HWChannels;
        info.numSamples = length(data);
        info.fs = 1 / ((time(end) - time(1)) / (length(data)-1));
        info.propertyNames = {};
        info.propertyValues = {};
        info.propertyTypes = {};
        info.trigFileFormat = trigFileFormat;
        out1 = dataclip;
        out2 = info;
        [out3,out4,out5,out6,out7,out8] = deal([]);
    else
        %Create time array:
        out1 = HWChannels;
        out2 = dataclip;
        out3 = timeclip;
        out4 = startSampNumber;
        out5 = {};
        out6 = {};
        out7 = trigFileFormat;
        out8 = {};
    end    
else
    error(['Unknown trigger-file format:', num2str(trigFileFormat)]);
end
    

