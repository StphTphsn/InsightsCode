function t_Insights_subsong_V2()
%% load inputs to GUI
% tSNE_Coord : [N,2] matrix containing tSNE coordinates of the N embedded
% points
% Spectro : [F, T] matrix containing the spectrogram that will be displayed
% by the GUI (not necessarily the one used for tSNE embedding). F is the
% number of features. T is the number of points in the Spectro (not necessarily equal to N)
% selected : [T,1] logical vector indicating the N points of the spectrogram
% that were selected for tSNE
addpath(genpath('Insights'))
%clear all;
%load('TestAll_row6','tSNE_Coord','selected','Spectro','FeatureInd');
%load('againstFee_ramprampTsne_row6','tSNE_Coord','selected','Spectro','FeatureInd');
% load('againstFee_ramprampTsne_row4','tSNE_Coord','selected','Spectro','FeatureInd');

load('againstFee_specplusramp_row12','tSNE_Coord','selected','Spectro','FeatureInd');
%load('forFee_rampTsne_row8','tSNE_Coord','selected','Spectro','FeatureInd');

Spectro(end,:) = cdfscore(conv(Spectro(end,:),gausswin(20), 'same'));
close all
tSNE_Coord=tSNE_Coord;
figure; imagesc(Spectro); set(gca, 'ydir', 'normal'); colormap hot; xlim([0 1000])
Spectro = Spectro; 
SpectroPlot=Spectro(FeatureInd.Spectrogram,:); 

% tmp hack
% FeatureInd.time = size(Spectro,1)+1;
% Spectro = [Spectro ; linspace(0,1,size(Spectro,2))];


selected = (selected==1);
Labels =selected'+1;
selectedInd = find(selected);
FeatureInd = FeatureInd;
clip_duration = 1000; % clip duration for the tryptic in ms 
bin_duration = 5; %in ms

%% draw figure

screensize = get(groot, 'Screensize');
sz = screensize;
f = figure('position', [1 300 sz(3) sz(4)*1/2]);
set(f, 'MenuBar', 'none');
set(f, 'ToolBar', 'none');
cmap = hot;cmap(1,:) = zeros(1,3);colormap(cmap)

%% draw color palet and current color

color_palet = [[0 0 0];[1 1 1]; pmkmp(8,'Swtth')];
current_color = 2;
nb_colors = size(color_palet,1);

paletPlot = subplot('position',[0.01 0.01 0.05 0.8]);
axis off;
for c = 2:size(color_palet,1)
    r = rectangle('position',[1 c 1 1],'FaceColor',color_palet(c,:),'EdgeColor','none');
    set(r,'ButtonDownFcn',{@paletClick});
end
rectangle('position',[1 2 1 size(color_palet,1)-1],'EdgeColor','k')

colorPlot = subplot('position',[0.01 0.85 0.05 0.08]);
axis off;
title('Color')
r_color =rectangle('position',[0 0 1 1],'FaceColor',color_palet(current_color,:));
% set(r,'ButtonDownFcn',{@colorClick});


%% draw feature palet

featPlot = subplot('position',[0.08 0.55 0.08 0.4]);hold on;
axis off;
feat = fields(FeatureInd);
nb_feat = length(feat);
for i = 1:nb_feat
    r = rectangle('position',[1 (nb_feat-i) 2 1],'FaceColor','w','EdgeColor','k');
    real_ind = eval(['FeatureInd.' feat{(nb_feat-i+1)} '(end)'])/size(Spectro,1);
%     plot([2 3],[(nb_feat-i+1) real_ind], 'color','k');
    t = text(1+0.1,(nb_feat-i+1/2),feat{(nb_feat-i+1)}(1:min(length(feat{(nb_feat-i+1)}),15)));
    set(r,'ButtonDownFcn',{@featClick});
    set(t,'ButtonDownFcn',{@featClick});
end
plot([2 3],[0 0], 'color','k');

ylim([0 nb_feat]);
%% draw clip tryptic

trypticPlot = subplot('position',[0.18 0.55 0.4 0.4]);hold on;
axis off;
nb_clips = 3;
clip = -round(clip_duration/2/bin_duration):round(clip_duration/2/bin_duration);
for i = 1:nb_clips
    slice = randi(size(SpectroPlot,2));
%     im = imagesc(1.1*i*length(clip)+clip,linspace(0,1,size(Spectro,1)),0);
        im = imagesc(1.1*(i-1)*length(clip)+(1:length(clip)),linspace(0,1,size(SpectroPlot,1)),...
            SpectroPlot(:,min(max(slice+clip,1),size(SpectroPlot,2))));
        plot([1.1*(i-1)*length(clip)+length(clip)/2 1.1*(i-1)*length(clip)+length(clip)/2],...
            [-0.1 1.1],'g','linewidth',.5);
    %set(im,'ButtonDownFcn',{@trypticClick});
end
ylim([-0.1 1.1]);
xlim([0 3.3*length(clip)])
current_clip = 1;

%% draw tSNE

tsnePlot = subplot('position',[0.6 0.01 0.30 0.95]);hold on;%axis off;
colors = color_palet(Labels(selected),:);
s_tSNE = scatter(tSNE_Coord(:,1), tSNE_Coord(:,2), 35,colors,'o','filled','MarkerEdgeColor','k');
xl = xlim; yl = ylim; 
p = plot(mean(xl), yl(1), 'v', 'markerfacecolor', 'r','markeredgecolor', 'r'); 
plot(mean(xl)*[1 1],yl(1)+[0 1], 'k'); 
%,1000,'filled','MarkerEdgeColor','k','linewidth',4);
set(gca, 'Xtick',[], 'Ytick',[]);
%set(gca,'Color',[0 0 0]);
set(tsnePlot,'ButtonDownFcn',{@tsneClick});
set(s_tSNE,'ButtonDownFcn',{@tsneClick});

%% draw color spectro
colorSpectro{2} = SpectroPlot(:,selected);
spectroPlot = subplot('position',[0.1 0.02 0.37 0.48]);hold on;axis off;
im = imagesc(colorSpectro{2});
set(im,'ButtonDownFcn',{@spectroClick});
        xlim([1 size(colorSpectro{2},2)]);
        ylim([1 size(colorSpectro{2},1)]);
        thisColorInd = find(Labels==1);
% xlim([0 size(colorSpectro{current_color},2)]);
% ylim([0 size(colorSpectro{current_color},1)]);
% set(spectroPlot,'ButtonDownFcn',{@tSNEclick});


%% draw spectro profiles


profilesPlot = subplot('position',[0.47 0.02 0.1 0.48]);hold on;%axis off;
set(gca, 'Xtick',[], 'Ytick',[]);
for color = 2:nb_colors
    if color ~= 2
        colorSpectro{color} = nan(size(SpectroPlot,1),1) ;
    end
    p_profiles{color} =plot(mean(colorSpectro{color},2),1:size(colorSpectro{color},1),'.',...
        'color',color_palet(color,:), 'markersize', 20);
    set(p_profiles{color},'ButtonDownFcn',{@profilesClick,color});
end
set(profilesPlot,'ButtonDownFcn',{@profilesClick});
xlim([0 1]);
ylim([1 size(SpectroPlot,1)])

%% color palet alive

    function paletClick(varargin)
        a = get(gca,'CurrentPoint');
        y = a(1,2)
        current_color = floor(y);
        r_color.FaceColor = color_palet(current_color,:);
    end

%% tSNE alive

    function tsneClick(varargin)
        a = get(gca,'CurrentPoint');
        x1 = a(1,1)
        y1 = a(1,2)
        set(f, 'WindowButtonUpFcn',{@tsneUp,x1,y1});
    end

    function tsneUp(~,~,x1,y1)
        set(f,'WindowButtonUpFcn','')
        a = get(gca,'CurrentPoint');
        x2 = a(1,1)
        y2 = a(1,2)
        ts = find(tSNE_Coord(:,1)>min(x1,x2) & tSNE_Coord(:,1)<max(x1,x2) ...
            & tSNE_Coord(:,2)>min(y1,y2) & tSNE_Coord(:,2)<max(y1,y2));
        Ts = selectedInd(ts);
        Labels(Ts) = current_color;
        colors(ts,1) = color_palet(current_color,1);
        colors(ts,2) = color_palet(current_color,2);
        colors(ts,3) = color_palet(current_color,3);
        s_tSNE.CData = colors;
        subplot(spectroPlot);
        cla;
        colorSpectro{current_color} = SpectroPlot(:,Labels==current_color);
        thisColorInd = find(Labels==current_color);
        im = imagesc(colorSpectro{current_color});
        xlim([1 size(colorSpectro{current_color},2)]);
        ylim([1 size(colorSpectro{current_color},1)]);
        set(im,'ButtonDownFcn',{@spectroClick});
        p_profiles{current_color}.XData = mean(colorSpectro{current_color},2);
    end

%% spectro profiles alive
    function profilesClick(~,~,color)
        if nargin == 2
            color = current_color;
        end
        if isnan(p_profiles{color}.XData(1))
            p_profiles{color}.XData = mean(colorSpectro{color},2);
        else
            p_profiles{color}.XData = nan(size(p_profiles{color}.XData));
        end
    end

%% color spectrum alive
    function spectroClick(varargin)

        a = get(gca,'CurrentPoint');
        x = round(a(1,1));
        slice = thisColorInd(x);
        subplot(trypticPlot); hold on;
        im = imagesc(1.1*(current_clip-1)*length(clip)+(1:length(clip)),linspace(0,1,size(SpectroPlot,1)),...
            SpectroPlot(:,min(max(slice+clip,1),size(SpectroPlot,2))));
        %set(im,'ButtonDownFcn',{@trypticClick});
                plot([1.1*(current_clip-1)*length(clip)+length(clip)/2 1.1*(current_clip-1)*length(clip)+length(clip)/2],...
            [-0.1 1.1],'g','linewidth',.5);
        current_clip = 1+mod(current_clip,nb_clips);
        
    end
%% feature palet alive
    function featClick(varargin)
        a = get(gca,'CurrentPoint');
        y = a(1,2);
        fe = ceil(y);
        row = 1-(fe-y);
        beg_ind = eval(['FeatureInd.' feat{fe} '(1)']);
        end_ind = eval(['FeatureInd.' feat{fe} '(end)']);
        chosen_ind = beg_ind + round(row*(end_ind - beg_ind));
        
        offsets = 100:-1:-100; % premotor is pos numbers
        subplot(tsnePlot); 
%         plot(.2*[offsets(1) offsets(end)], (min(s_tSNE.YData)+2)*[1 1], 'k'); 
%         plot(.2*offsets(1), min(s_tSNE.YData)+2, 'v', 'markersize', 5, 'markerfacecolor', 'r')
        for offseti = 1:length(offsets); 
            offset = offsets(offseti)
            trace=Spectro(chosen_ind,:);
            %trace = conv(Spectro(chosen_ind,:),gausswin(30), 'same');%smooth(Spectro(chosen_ind,:),10);
            trace = circshift(trace(:),offset);
            trace(trace<0)=0;
            trace = cdfscore(trace)'; 
            shade = trace(selectedInd);
            s_tSNE.CData = repmat(1-shade,1,3);
            p.XData = mean(xl)+diff(xl)*(-offset)/(2*max(abs(offsets))); 
            %s_tSNE.SizeData = 100-abs(offset);
            drawnow
            pause(.01);
            s_tSNE.Marker = 'o';
        end
    end


end

