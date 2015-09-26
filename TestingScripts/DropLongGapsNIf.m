function [newSnd, timeInds, labels, SylFileNum, SylSegNum] = DropLongGapsNIf(dbase, FileToLoad, snd, fs)
    fj = 1/86400; % 1/(# seconds in one day)
    DT = 12000; % keep gaps up to this size -- 300ms at 40kHz
    segtimes = round(dbase.SegmentTimes{FileToLoad});
    keep_ind = false(length(snd),1);
    lab = -2*ones(length(snd),1);
    SylFileNum = zeros(length(snd),1);
    SylSegNum = zeros(length(snd),1);
    ti = dbase.Times(FileToLoad) + (1:length(snd))/fs*fj;
    for seg = 1:size(segtimes,1)
        if (segtimes(seg,1)-DT >1 &&... % seg starts >DT bins from beginning of file
                segtimes(seg,2)+DT<=length(snd)... % seg ends >DT bins before end of file
                && dbase.SegmentIsSelected{FileToLoad}(seg)==1) % segment is selected
            if 1; %length(dbase.SegmentTitles{FileToLoad}{seg})==0 % unlabeled
                sylID = 1; % treating everything as unlabeled
            else % to use, need to define sylTypes
                sylID = strmatch(dbase.SegmentTitles{FileToLoad}{seg}, sylTypes);
            end
            keep_ind((segtimes(seg,1)-DT):(segtimes(seg,2)+DT))=true; % keep everything in window extending DT from seg
            lab(segtimes(seg,1)-1:segtimes(seg,2)) = ... % increment labels withing seg in a ramp
                linspace(0,1,length(segtimes(seg,1)-1:segtimes(seg,2)))+...
                sylID-1;
            SylFileNum(segtimes(seg,1)-1:segtimes(seg,2)) = ...
                FileToLoad*ones(1,length(segtimes(seg,1)-1:segtimes(seg,2))); 
            SylSegNum(segtimes(seg,1)-1:segtimes(seg,2)) = ...
                seg*ones(1,length(segtimes(seg,1)-1:segtimes(seg,2)));
        end
    end
    newSnd = snd(keep_ind);
    timeInds = ti(keep_ind);
    labels = lab(keep_ind);
    SylFileNum = SylFileNum(keep_ind); 
    SylSegNum = SylSegNum(keep_ind); 
end