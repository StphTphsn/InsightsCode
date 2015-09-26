function [songs, labels, spikes, times, syl_nb, cuts] = load_songs_tot(folder, bouts)
pathname = '/Users/mbl/Desktop/MCN/PROJECT/DATA/tot';

load(fullfile(pathname, 'Labeled_songs',folder));

if nargin<2
    bouts = 1:length(dbase.SegmentTimes);
end

songs = [];
spikes = [];

labels = [];

DT = 12000;
        fj = 1/86400;
times = [];
syl_nb = 0;
lims_1 = [1];
lims_2 = [];
sylTypes = {'O' 'A' 'B' 'C' 'D' 'E' 'F' 'a' 'b' 'c' 'd' 'e' 'f'};
%sylColors = [1 1 1 ; 0 0 1; 1 0 0; 0 1 0; 1 1 0; 1 0 1; 0 1 1; lines(6)]; 


for file_i = bouts
    if (length(dbase.SegmentTimes{file_i}) ~=0)
        load(fullfile(pathname,[folder(8:17) '_Bouts/' dbase.SoundFiles(file_i).name]));
        s = rec.Data;
        fs = rec.Fs;
        segtimes = dbase.SegmentTimes{file_i};
        keep_ind = false(length(s),1);
        lab = -2*ones(length(s),1);
        ti = dbase.Times(file_i)+ (1:length(s))/fs*fj;
        for seg = 1:size(segtimes,1)
            if (segtimes(seg,1)-DT >1 && segtimes(seg,2)+DT<=length(s) && dbase.SegmentIsSelected{file_i}(seg)==1)
                if length(dbase.SegmentTitles{file_i}{seg})==0
                    sylID =1;
                else
                    sylID = strmatch(dbase.SegmentTitles{file_i}{seg}, sylTypes);
                end
                
                syl_nb = syl_nb+1;
                keep_ind(segtimes(seg,1)-DT:segtimes(seg,2)+DT)=true;
                lab(segtimes(seg,1)-1:segtimes(seg,2)) = ...
                    linspace(0,1,length(segtimes(seg,1)-1:segtimes(seg,2)))+...
                    sylID-1;
            end
        end
        s_trunc = s(keep_ind);
        ti_trunc = ti(keep_ind);
        lab = lab(keep_ind);

        songs = [songs; s_trunc];
        times = [times; ti_trunc'];
        labels = [labels; lab];
        lims_1 = [lims_1 length(songs)+1];
        lims_2 = [lims_2 length(songs)];
    end
end

lims_1  = lims_1(1:end-1);

cuts = [lims_1; lims_2];