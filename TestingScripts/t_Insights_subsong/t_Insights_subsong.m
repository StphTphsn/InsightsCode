function t_Insights_subsong()
%clear all; close all; clc;


%load('tSNE_PURPLE_sub','tSNE_Coord','selected','Spectro');
load('Test','tSNE_Coord','selected','Spectro');
%load('tSNE_PURPLE_sub','tSNE_Coord','selected','Spectro');
tSNE_Coord=tSNE_Coord;
Spectro=Spectro;
Labels = 2*ones(size(Spectro,2),1);
selected = selected;
%selected = selected;

color_pallet = [[0 0 0]; [1 1 1]; pmkmp(14,'Swtth')];
current_color = 3;

grid_size = floor(sqrt(size(color_pallet,1)));
ju = repmat(1:grid_size,grid_size,1);
xc = ju(:);
ju = ju';
yc = ju(:);
color_pallet = color_pallet(1:grid_size^2,:);

screensize = get( groot, 'Screensize' );
f = figure('position', 0.9*screensize);
%set(f, 'MenuBar', 'none');
%set(f, 'ToolBar', 'none');

colors = [];
calculate_colors();

subTSNE = subplot('position',[0 0.55 0.3 0.45]);

subPALET = subplot('position',[0.32 0.75 0.15 0.2]);
axis off;
for c = 1:size(color_pallet,1)
    s3 = rectangle('position',[xc(c)-1/2 yc(c)-1/2 1 1],'FaceColor',color_pallet(c,:));
    set(s3,'ButtonDownFcn',{@paletClick});
end
xlim([0.5 grid_size+0.5])
ylim([0.5 grid_size+0.5])


subCOLOR = subplot('position',[0.32 0.55 0.15 0.15]);
axis off;
title('Current Color')
rectangle('position',[0 0 1 1],'FaceColor',color_pallet(current_color,:));



subSPECTRO = subplot('position',[0 0 1 0.5]);hold on;
axis off;
p2 =imagesc(flipud(Spectro));
rBG = rectangle('position',[0 size(Spectro,1) size(Spectro,2) 30], 'FaceColor',[0.5 0.5 0.5]);
set(rBG,'ButtonDownFcn',{@spectroClick});
spectroLims = [0 2000];
xlim([spectroLims]);
ylim([0 size(Spectro,1)+40]);
cmap = hot;cmap(1,:) = zeros(1,3);colormap(cmap)
set(subSPECTRO,'ButtonDownFcn',{@spectroClick});
set(p2,'ButtonDownFcn',{@spectroClick});
selectedInd = find(selected);
Ts = selectedInd;
        for j = 1:length(Ts)
            t = Ts(j);
            r5{t} = rectangle('position',[t-1/2 size(Spectro,1) 1 30],...
                'FaceColor',colors(t,:),'LineStyle','none');
            set(r5{t},'ButtonDownFcn',{@spectroClick});
        end

rePlot(selectedInd);

subColorSPECTRO = subplot('position',[0.48 0.51 0.51 0.49]);hold on;
axis off;

ColorSpectro = cell(size(color_pallet,1),1);

set(f, 'WindowKeyPressFcn', @spectroScroll);
    function spectroScroll(src, evt)
        subplot(subSPECTRO);
        if strcmp(evt.Key, 'rightarrow')==1
            spectroLims = spectroLims+500;
            
        elseif strcmp(evt.Key, 'leftarrow')==1
            spectroLims = spectroLims-500;
            
        end
        xlim([spectroLims]);
        
    end

    function tSNEclick(varargin)
        a = get(gca,'CurrentPoint');
        x1 = a(1,1)
        y1 = a(1,2)
        %         subplot(subTSNE); hold on;
        %         xl = xlim;
        %         yl = ylim;
        %         plot([x1 x1],[yl(1) yl(2)], 'color','w')
        %         plot([xl(1) xl(2)],[y1 y1], 'color','w')
        set(f, 'WindowButtonUpFcn',{@tSNEup,x1,y1});
        %         X = tSNE_Coord(:,1)-x;
        %         Y = tSNE_Coord(:,2)-y;
        %         [~,t]=min(X.^2 + Y.^2);
        %reLabel(t)
    end

    function tSNEup(~,~,x1,y1)
        set(f,'WindowButtonUpFcn','')
        a = get(gca,'CurrentPoint');
        x2 = a(1,1)
        y2 = a(1,2)
        ts = find(tSNE_Coord(:,1)>x1 & tSNE_Coord(:,1)<x2 & tSNE_Coord(:,2)<y1 & tSNE_Coord(:,2)>y2);
        Ts = selectedInd(ts);
        reLabel(Ts);
    end

    function paletClick(varargin)
        a = get(gca,'CurrentPoint');
        x = a(1,1)
        y = a(1,2)
        X = xc-x;
        Y = yc-y;
        [~,theColor]=min(X.^2 + Y.^2);
        current_color = theColor;
        subplot(subCOLOR);
        rectangle('position',[0 0 1 1],'FaceColor',color_pallet(current_color,:));
        %refreshColorSpectrum()
    end

    function refreshColorSpectrum()
        subplot(subColorSPECTRO);hold on;
        cla
        ColorSpectro{current_color} = [];
        inds = find(Labels == current_color);
        for i = 1:length(inds)
            ColorSpectro{current_color} = [ColorSpectro{current_color} Spectro(:,max(inds(i)-5,1):min(inds(i)+5,size(Spectro,2)))];
        end
        cs = imagesc(flipud(ColorSpectro{current_color}));
        cr = rectangle('position',[0 size(ColorSpectro{current_color},1) size(ColorSpectro{current_color},2) 30], 'FaceColor',color_pallet(current_color,:));
        xlim([0 size(ColorSpectro{current_color},2)]);
        ylim([0 size(ColorSpectro{current_color},1)+30]);
        set(cr,'ButtonDownFcn',{@colorSpectroClick});
        set(cs,'ButtonDownFcn',{@colorSpectroClick});
    end

    function spectroClick(varargin)
        a = get(gca,'CurrentPoint');
        x1 = a(1,1)
        set(f, 'WindowButtonUpFcn',{@spectroUp,x1});
    end

    function colorSpectroClick(varargin)
        refreshColorSpectrum();
    end
    function spectroUp(~,~,x1)
        set(f,'WindowButtonUpFcn','')
        a = get(gca,'CurrentPoint');
        x2 = a(1,1)
        Ts = intersect(round(x1):round(x2), selectedInd);
        reLabel(Ts);
    end


    function reLabel(Ts)
        for i = 1:length(Ts)
            t = Ts(i);
            Labels(t) = current_color;
        end
        
        
        calculate_colors();
        rePlot(Ts);
        refreshColorSpectrum()
    end

    function calculate_colors()
        col = color_pallet(Labels,:);
        colors = col;
    end

    function rePlot(Ts)
        figure(f);
        subplot(subTSNE);
        
        p1 = scatter(tSNE_Coord(:,1), tSNE_Coord(:,2), 20,colors(selected,:),'s','filled');
        set(gca, 'Xtick',[], 'Ytick',[]);
        set(gca,'Color',[0 0 0]);
        set(subTSNE,'ButtonDownFcn',{@tSNEclick});
        set(p1,'ButtonDownFcn',{@tSNEclick});
        
        subplot(subSPECTRO);hold on;
        axis off;
        for i = 1:length(Ts)
            t = Ts(i);
            
%             r5 = rectangle('position',[t-1/2 size(Spectro,1) 1 30],...
%                 'FaceColor',colors(t,:),'LineStyle','none');
%             set(r5,'ButtonDownFcn',{@spectroClick});
             r5{t}.FaceColor = colors(t,:);
        end
        
    end


end







%colors = zeros(length(labels),3);
%for t = 1:length(labels)
%l = labels(t);
%end
