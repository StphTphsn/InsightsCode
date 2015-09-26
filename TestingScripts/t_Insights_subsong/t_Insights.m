function t_Insights()
%clear all; close all; clc;


%load('tSNE_DATA','tSNE_Coord','Labels','Spectro');
load('tSNE_PURPLE','tSNE_Coord','Labels','Spectro');
Labels = Labels;
tSNE_Coord=tSNE_Coord;
Spectro=Spectro;

color_pallet = [[0 0 0]; [1 1 1]; pmkmp(256,'Swtth')];
current_color = 20;

grid_size = floor(sqrt(size(color_pallet,1)));
ju = repmat(1:grid_size,grid_size,1);
xc = ju(:);
ju = ju';
yc = ju(:);
color_pallet = color_pallet(1:grid_size^2,:);

screensize = get( groot, 'Screensize' );
f = figure('position', 1*screensize);
%set(f, 'MenuBar', 'none');
%set(f, 'ToolBar', 'none');

colors = [];
calculate_colors();

subplot('position',[0.6 0.5 0.3 0.5]);
for c = 1:size(color_pallet,1)
    s3 = rectangle('position',[xc(c)-1/2 yc(c)-1/2 1 1],'FaceColor',color_pallet(c,:));
    set(s3,'ButtonDownFcn',{@paletClick});
end
h3 = subplot('position',[0.4 0.6 0.1 0.1]);
title('Current Color')
rectangle('position',[0 0 1 1],'FaceColor',color_pallet(current_color,:));



s2 = subplot('position',[0 0 1 0.5]);hold on;
p2 =imagesc(flipud(Spectro));

rePlot(1);



    function tSNEclick(varargin)
        a = get(gca,'CurrentPoint');
        x = a(1,1)
        y = a(1,2)
        X = tSNE_Coord(:,1)-x;
        Y = tSNE_Coord(:,2)-y;
        [~,t]=min(X.^2 + Y.^2);
        reLabel(t)
    end

    function paletClick(varargin)
        a = get(gca,'CurrentPoint');
        x = a(1,1)
        y = a(1,2)
        X = xc-x;
        Y = yc-y;
        [~,theColor]=min(X.^2 + Y.^2);
        current_color = theColor;
        subplot(h3);
        rectangle('position',[0 0 1 1],'FaceColor',color_pallet(current_color,:));
    end

    function spectroClick(varargin)
        a = get(gca,'CurrentPoint');
        x = a(1,1)
        y = a(1,2)
        t = round(x);
        reLabel(t)
    end

    function reLabel(t)
        up = find(Labels(t:length(Labels)) - round(Labels(t:length(Labels)))==0,1,'first') + t -1;
        down = find(Labels(1:t)- round(Labels(1:t))==0,1,'last')+1;
        Labels(down:up) = Labels(down:up) - ceil(Labels(down:up)) + current_color -1;
        %figure;plot(Labels)
        calculate_colors();
        rePlot(t);
    end

    function calculate_colors()
        col = color_pallet(ceil(Labels)+1,:);
        integ = fix(Labels);
        fract = abs(Labels - integ);
        contrast = 1-fract/2;
        contrast = repmat(contrast,1,3);
        colors = contrast .*col;
    end

    function rePlot(t)
        figure(f);
        s1 = subplot('position',[0 0.55 0.3 0.45]);
        p1 = scatter(tSNE_Coord(:,1), tSNE_Coord(:,2), 100,colors,'s','filled');
        set(gca,'Color',[0 0 0]);
        set(s1,'ButtonDownFcn',{@tSNEclick});
        set(p1,'ButtonDownFcn',{@tSNEclick});
        
        
        s2 = subplot('position',[0 0 1 0.5]);hold on;
        cla;
        p2 =imagesc(flipud(Spectro));
        lims = find(Labels- round(Labels)==0);
        rectangle('position',[0 size(Spectro,1) size(Spectro,2) 30], 'FaceColor','k');
        for syl = 1:length(lims)-1
            r5 = rectangle('position',[lims(syl)+1 size(Spectro,1) lims(syl+1)-lims(syl)-1 30], 'FaceColor',colors(lims(syl)+1,:));
            set(r5,'ButtonDownFcn',{@spectroClick});
        end
%        circle('Center',[t size(Spectro,1)+35],'Diameter',5,'FaceColor','r');
        
        %r2 =scatter(1:length(Labels), size(Spectro,1)*ones(length(Labels),1)+10, 100,colors,'s','filled');
        xlim([0 length(Labels)]);
        ylim([0 size(Spectro,1)+40]);
        cmap = hot;
        cmap(1,:) = zeros(1,3);
        colormap(cmap)
        set(s2,'ButtonDownFcn',{@spectroClick});
        set(p2,'ButtonDownFcn',{@spectroClick});
        %set(r2,'ButtonDownFcn',{@spectroClick});
        
    end


end







%colors = zeros(length(labels),3);
%for t = 1:length(labels)
%l = labels(t);
%end
