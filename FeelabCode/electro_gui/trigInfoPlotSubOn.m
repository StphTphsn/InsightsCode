function trigInfo=trigInfoPlotSubOn(trigInfo);

%This function plots the subsong onset raster, sorted by prev gap, and
%gives hist dep on gap dur
bplot=1;
gap=[.015 .08 .3];
gap=[.015 .49 .5];
num=300;%how many sylls to plot for the raster
binsize=median(diff(trigInfo.edges));
[x ndx]=sort(trigInfo.prevTrigOffset);
rndx=randperm(length(trigInfo.eventOnsets{1}));
edges=trigInfo.edges;
rd{1}=0;rd{2}=0;rd{3}=0;count{1}=0;count{2}=0;count{3}=0;
cy{1}=[.4,.4,.4];cy{2}='r';cy{3}='green';
cy{1}='r';cy{2}='k';cy{3}='k';cy{4}='k';
%below make histogram
%if ~isfield(trigInfo.hst,'gap15');
for y=1:length(trigInfo.eventOnsets{1})
    i=ndx(y);
    prev=-trigInfo.prevTrigOffset(i);
    spks=trigInfo.eventOnsets{1,1}{1,i};
    if -prev<=gap(1)
        count{1}=count{1}+1;
        temprd{1}=histc(spks,edges);rd{1}=rd{1}+temprd{1};
    end
    if -prev>gap(1) && prev<=gap(2)
        count{2}=count{2}+1;
        temprd{2}=histc(spks,edges);rd{2}=rd{2}+temprd{2};
    end
    if -prev>gap(2)
        count{3}=count{3}+1;
        temprd{3}=histc(spks,edges);rd{3}=rd{3}+temprd{3};
    end
end
%     trigInfo.hst.gap15=rd{1}/count{1}/binsize;
%     trigInfo.hst.gap15_80=rd{2}/count{2}/binsize;
%     trigInfo.hst.gap80=rd{3}/count{3}/binsize;
trigInfo.hst.gap15=rd{1}/count{1}/binsize;
%trigInfo.hst.gap20_500=rd{2}/count{2}/binsize;
%end

%randomly select num sylls
rcount=0;
num=min([length(rndx) num]);
for i=rndx
    if ~isempty(trigInfo.eventOnsets{1,1}{1,i}) && rcount<=num;
        rcount=rcount+1;
        rndspks{rcount}=trigInfo.eventOnsets{1,1}{1,i};
        rndprev(rcount)=-trigInfo.prevTrigOffset(i);
    end
end

%below plot raster
if bplot
    figure;lineheight=1;
    [x ndx]=sort(-rndprev);
    clear prev;
    for y=1:length(ndx);
        i=ndx(y);
        prev=rndprev(i);
        spks=rndspks{i};
        if -prev<=gap(1)
            subplot(2,1,2); hold on; line([prev',prev'],[y, y+lineheight],'color',cy{1},'linewidth',3);
        end
        if -prev>gap(1) && prev<=gap(2)
            subplot(2,1,2); hold on; line([prev',prev'],[y, y+lineheight],'color',cy{2},'linewidth',3);
        end
        if -prev>gap(2)
            subplot(2,1,2); hold on; line([prev',prev'],[y, y+lineheight],'color',cy{3},'linewidth',3);
        end
        if ~isempty(spks)
            for j=1:length(spks)
                subplot(2,1,2); hold on; line([spks(j)',spks(j)'],[y,y+lineheight]);
            end
        end
    end
    subplot(2,1,2); hold on; line([0,0],[0,num],'color','k');
    subplot(2,1,2); ylim([0,num]);xlim([-.3,.3]);
    title([trigInfo.title]);
    subplot(2,1,1);stairs(edges,trigInfo.hst.all);
    clear rd
    % rd{1}=trigInfo.hst.gap15;
    % rd{2}=trigInfo.hst.gap15_80;
    % rd{3}=trigInfo.hst.gap80;
    rd{1}=trigInfo.hst.gap20;
    rd{4}=trigInfo.hst.gap20_500;
    
    s=3;
    for z=[1 4];
        if ~isempty(rd{z}) && isempty(find(isnan(rd{z})))
            subplot(2,1,1);hold on; stairs(edges,smooth(rd{z},s),'color',cy{z});xlim([-.3,.3]);
        end
    end
    
    mn=min([min(trigInfo.hst.all(1:end-1)) min(trigInfo.hst.gap15(1:end-1)) min(trigInfo.hst.gap15_80(1:end-1)) min(trigInfo.hst.gap80(1:end-1))]);
    mx=max([max(trigInfo.hst.all(1:end-1)) max(trigInfo.hst.gap15(1:end-1)) max(trigInfo.hst.gap15_80(1:end-1)) max(trigInfo.hst.gap80(1:end-1))]);
    
    subplot(2,1,1);hold on; line([0,0],[0,mx+10],'color','k');xlim([-.3,.3]);
    subplot(2,1,1);ylim([mn-10, mx+10]);
    subplot(2,1,1);set(gca,'xtick',[-.3:.1:.3]);set(gca,'xticklabel',[-.3:.1:.3]);
    subplot(2,1,2);set(gca,'xtick',[-.3:.1:.3]);set(gca,'xticklabel',[-.3:.1:.3]);
    
end
%below plot rate in 20 ms prior to onset vs gapdur scatterplot
% figure;
% for i=1:length(trigInfo.eventOnsets{1})
%         prev=-trigInfo.prevTrigOffset(i);
%     spks=trigInfo.eventOnsets{1,1}{1,i};
%     numspks=length(find(spks>=-.02 & spks<0));
%     rate=numspks/.02;
%     hold on; plot(prev,rate,'o');
% end
% xlabel('Gap duration (s)');ylabel('Rate at syll onset (Hz)');

