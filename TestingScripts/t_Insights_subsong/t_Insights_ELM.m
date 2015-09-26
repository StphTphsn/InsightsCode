%load('TEST_PAPER_GUI', 'tSNE_Coord','Spectro','Labels','beg_ind_syl','end_ind_syl');
function t_Insights_ELM()
%clear all
%close all
%load('againstFee_specplusramp_row13', 'tSNE_Coord','Spectro','FeatureInd','selected');
%load(['againstFee_specplusramp_row' num2str(11)],'tSNE_Coord','Spectro','FeatureInd','selected')

[FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
load(fullfile(PathName, FileName), 'tSNE_Coord','Spectro','FeatureInd','selected');
display(['loaded ' fullfile(PathName, FileName)])

Win = [1 1000]; % which points to show

TimeFromOnset = [Spectro(FeatureInd.TimeFromOnset,:)];
TimeFromOnset = TimeFromOnset-min(TimeFromOnset);
beg_ind_syl = find(TimeFromOnset(1:end-1)==0 & TimeFromOnset(2:end)>0);
end_ind_syl = find(TimeFromOnset(1:end-1)>0 & TimeFromOnset(2:end)==0);
Labels = ones(length(beg_ind_syl),1);
warning = ones(size(Labels));
selected = selected;
Results = struct(); 
fns = Spectro(FeatureInd.SylFileNum,:);
sns = Spectro(FeatureInd.SylSegNum,:); 
Results.FileNum = fns(beg_ind_syl); % keep track of dbase file numbers
Results.SegNum = sns(beg_ind_syl); % keep track of dbase segment numbers
Spectro = Spectro(FeatureInd.ForGuiSpectrogram,:); % Spectro is now just the spectrogram
r_Label = cell(1);        
bag = []; % bag will hold all the rectangles plotted on top of the spectrogram
       
% figure;
% hold on;
% plot(TimeFromOnset);
% plot(selected,'r');
sLabels = zeros(size(Spectro,2),1);
sNumber = zeros(size(Spectro,2),1);
for syl = 1:length(Labels)
    sLabels(beg_ind_syl(syl):end_ind_syl(syl)) = Labels(syl);
    sNumber(beg_ind_syl(syl):end_ind_syl(syl))  = syl;
end

tLabels = sLabels(selected==1);
% tLabels = tLabels(1:1000);

lowLabels = (TimeFromOnset<=0.3);
tlowLabels = lowLabels(selected==1);
tNumber = sNumber(selected==1);
tTimeFromOffset = TimeFromOnset(selected==1);
noLinesLog = [tTimeFromOffset(2:end)<tTimeFromOffset(1:end-1) false];
noLines = ones(size(noLinesLog));
noLines(noLinesLog) = nan;
contrast = 1/2+(1-repmat(TimeFromOnset(selected==1)',1,3))/2;
mask = ones(size(noLines))';


%mask(noLines) = nan;

% tlowLabels = tlowLabels(1:1000);




%% Draw figure

screensize = get(groot, 'Screensize');
sz = screensize;
xs = sz(4)*0.8;
ys = sz(4)*0.85;
f = figure('position', [50 100 xs ys]);
set(f, 'MenuBar', 'none');
set(f, 'ToolBar', 'none');
cmap = hot;cmap(1,:) = zeros(1,3);colormap(cmap)

%% Draw Color Palet
junk = pmkmp(11,'Swtth');
color_palet = [[1 1 1]; .5*[1 1 1]; [junk(1:4,:); junk(7:11,:)]];
% color 1 means unlabeled; color 2 means want to flag/unselect that syllable.
current_color = 1;
nb_colors = size(color_palet,1);

paletPlot = subplot('position',[0.01 0.3 0.08 0.6]);
axis off;
for c = 1:size(color_palet,1)
    r = rectangle('position',[1 c 1 1],'FaceColor',color_palet(c,:),'EdgeColor','none');
    set(r,'ButtonDownFcn',{@paletClick});
end
rectangle('position',[1 1 1 size(color_palet,1)],'EdgeColor','k')

colorPlot = subplot('position',[0.01 0.9 0.08 0.06]);
axis off;
title('Color')
r_color =rectangle('position',[0 0 1 1],'FaceColor',color_palet(current_color,:),'linewidth',4);
% set(r,'ButtonDownFcn',{@colorClick});

centroids = cell(nb_colors,1);

colormask{1} = ones(size(noLines))'; % one for each color lines
for col = 2:nb_colors
    colormask{col} = nan(size(noLines))';
end

%% Draw t-SNE embedding

% [newdata, R, t] = AxelRot([X1 Y1 Z1]', 100, [-1 1 1], [0 0 0]);
% plot(newdata(1,:), newdata(2,:),'.')
% X1 = newdata(1,:)'; Y1 = newdata(2,:)'; Z1 = newdata(3,:)';

tsnePlot = subplot('position',[0.15 0.3 0.7 0.65]);hold on;%axis off;

angleRot = 0;
tSNE_Colors = contrast.*color_palet(tLabels,:);

Win_Coord = [];
p_tSNE = [];
tsneRefresh();
% for color = 2:nb_colors
%     p_centroid{color-1} = plot(nan,nan,...
%         'color',color_palet(color,:),'linewidth',3);
% end
% p_centroid{nb_colors}= [];

    function tsneRefresh()
        cla;
        mask(:) = 1;
        Win_Coord = tSNE_Coord(Win(1):Win(2),:); % which points to show
        for col = 1:nb_colors
            % one plot per color, so can easily change xdata & ydata
            p_tSNE{col} = plot(colormask{col}(Win(1):Win(2)).*... % mask where you shouldn't plot that color
                noLines(Win(1):Win(2))'.*Win_Coord(:,1), ... % mask at beginnings and ends so you don't see those lines
                Win_Coord(:,2), 'linewidth',0.1,'color',color_palet(col,:));
        end
        s_tSNE = scatter(Win_Coord(:,1), Win_Coord(:,2), 50,tSNE_Colors(Win(1):Win(2),:),'o','filled','MarkerEdgeColor','k');
%         for color = 3:nb_colors % all colors except 1 (unlabeled) and 2 (unselected)
%             p_centroid{color} = plot(nan,nan,...
%                 'color',color_palet(color,:),'linewidth',3); % no longer plotting centroids
%         end
        drawnow
    end
u = [0 1 0];
%plot([-u(1) u(1)], [-u(2) u(2)], 'r', 'linewidth',3)
xlim([-20 20])
ylim([-20 20])

set(gca, 'Xtick',[], 'Ytick',[]);
set(gca,'Color',[0 0 0]);
set(tsnePlot,'ButtonDownFcn',{@tsneClick});
set(s_tSNE,'ButtonDownFcn',{@tsneClick});

%% Draw Spectro

spectro_Colors = color_palet(Labels,:);
pos1 = [0.01 0.15 0.98 0.12];
spectroPlot1 = subplot('position',pos1);hold on;axis off;
pos2 = [0.01 0.02 0.98 0.12];
spectroPlot2 = subplot('position',pos2);hold on;axis off;
spectroRefresh();


    function spectroRefresh()
        
        
        sWin = [find(cumsum(selected) == Win(1),1,'first') find(cumsum(selected) == Win(2),1,'first')]; % to find indices of spectrogram that correspond to the tsne points
        Win_Spectro  = Spectro(:,sWin(1):sWin(2)); 
        lim = round(0.5*size(Win_Spectro,2));
        for slice = 1:2
            switch slice
                case 1
                    T = 1:lim;
                    %pos = [0.01 0.15 0.98 0.12];
                    subplot(spectroPlot1);
        cla;
                    
                case 2
                    T = lim+1:2*lim-1;
                    %pos = [0.01 0.02 0.98 0.12];
                    subplot(spectroPlot2);
        cla;
            end
            Spectroslice = Win_Spectro(:,T);
            bag = unique(tNumber(Win(1):Win(2))); % tnumber assigns each tsne point to a syllable #. Bag is the bag of syllables that need rectangles plotted.
            
            im = imagesc(T, 1:size(Spectroslice,1),Spectroslice);
            set(im, 'ButtonDownFcn',{@spectroClick}); %ELM
            rectangle('position',[-sWin(1) size(Spectro,1) size(Spectro,2) round(size(Spectro,1)/5)],...
                'FaceColor',[0.5 0.5 0.5],'LineStyle','none');
            for i = 1:length(bag) % plot each rectangle, store its handle 
                syl = bag(i);
                if warning(syl)==1 % bad classification (good = 1/3), put box around rectangle
                    r_Label{slice,syl} = rectangle('position',[beg_ind_syl(syl)-sWin(1) size(Spectro,1) end_ind_syl(syl)-beg_ind_syl(syl) round(size(Spectro,1)/5)],...
                    'FaceColor',spectro_Colors(syl,:),'LineStyle','none');
                else
                     r_Label{slice,syl} = rectangle('position',[beg_ind_syl(syl)-sWin(1) size(Spectro,1) end_ind_syl(syl)-beg_ind_syl(syl) round(size(Spectro,1)/5)],...
                    'FaceColor',spectro_Colors(syl,:),'Linewidth',2);   
                end
                
            end
            xlim([T(1) T(end)]);
            ylim([1 size(Spectro,1)+round(size(Spectro,1)/5)]);
            drawnow;
        end
    end

%% Live Color Palet (live = when you click on it)

    function paletClick(varargin)
        a = get(gca,'CurrentPoint');
        y = a(1,2);
        if current_color == floor(y) % if you double clicked on a color
            %mask(tLabels == current_color,:)=0;
            %tSNE_Colors = mask.*contrast.*color_palet(tLabels,:);
            %tSNE_Colors = contrast.*color_palet(tLabels,:);
            %s_tSNE.CData = tSNE_Colors;
            ind = find(tLabels == current_color);
            if ~isempty(ind)
                if isnan(mask(ind(1))) % toggle between masking and unmasking the colors
                    mask(tLabels == current_color) = 1;
                else
                    mask(tLabels == current_color) = nan;
                end
                s_tSNE.XData = mask(Win(1):Win(2)).*Win_Coord(:,1);
                for col = 1:nb_colors
                    p_tSNE{col}.XData = colormask{col}(Win(1):Win(2)).*noLines(Win(1):Win(2))'.*mask(Win(1):Win(2)).*Win_Coord(:,1);
                end
            end
        end
        current_color = floor(y); % change the current color
        r_color.FaceColor = color_palet(current_color,:);
    end

%% Live TSNE

set(f, 'WindowKeyPressFcn', @tsneRotate);
    function tsneRotate(src, evt) 
        if strcmp(evt.Key, 'rightarrow')==1
            angleRot = 6;
            [new_Coord] = AxelRot(Win_Coord', angleRot, u, [0 0 0]);
        elseif strcmp(evt.Key, 'leftarrow')==1
            angleRot = -6;
            [new_Coord] = AxelRot(Win_Coord', angleRot, u, [0 0 0]);
            
        elseif strcmp(evt.Key, 'uparrow')==1
            utwist = [-u(2) u(1) 0];
            angleRot = 6;
            [new_Coord] = AxelRot(Win_Coord', angleRot, utwist, [0 0 0]);
            
        elseif strcmp(evt.Key, 'downarrow')==1
            utwist = [-u(2) u(1) 0];
            angleRot = -6;
            [new_Coord] = AxelRot(Win_Coord', angleRot, utwist, [0 0 0]);
            
            
        end
        Win_Coord = new_Coord';
        s_tSNE.XData = mask(Win(1):Win(2)).*Win_Coord(:,1);
        s_tSNE.YData = Win_Coord(:,2);
        for col = 1:nb_colors
            p_tSNE{col}.XData = colormask{col}(Win(1):Win(2)).*noLines(Win(1):Win(2))'.*mask(Win(1):Win(2)).*Win_Coord(:,1);
            p_tSNE{col}.YData = Win_Coord(:,2);
        end
        
        
        
    end
    function spectroClick(varargin)
        a = get(gca,'CurrentPoint');
        x1 = a(1,1);
        y1 = a(1,2);
        set(f, 'WindowButtonUpFcn',{@spectroUp,x1,y1});
    end
    function spectroUp(~,~,x1,y1)
        set(f,'WindowButtonUpFcn','')
        a = get(gca,'CurrentPoint');
        x2 = a(1,1);
        y2 = a(1,2);
        
        for i  = 1:length(bag)
            syl_nb = bag(i) % change to for each syllable rectangle in the spectrogram
            a = get(r_Label{1,syl_nb},'position'); 
            cx = a(1); 
            w = a(3);
            % did the line on the spectrogram cross those syllables?
            if  (cx > min(x1,x2) & cx < max(x1,x2)) |...
                    ((cx + w) > min(x1,x2) & (cx + w) < max(x1,x2))
                tLabels(tNumber == syl_nb) = current_color;
                r_Label{1,syl_nb}.FaceColor = color_palet(current_color,:);
                r_Label{2,syl_nb}.FaceColor = color_palet(current_color,:);
                r_Label{1,syl_nb}.LineStyle = 'none';
                r_Label{2,syl_nb}.LineStyle = 'none';
                spectro_Colors(syl_nb,:) = color_palet(current_color,:);
                prev_color = Labels(syl_nb);
                Labels(syl_nb) = current_color;
                warning(syl_nb) = 1;
                refreshCentroid(syl_nb,prev_color); 
                for col = 1:nb_colors
                    colormask{col}(tNumber == syl_nb) = nan;
                end
                colormask{current_color}(tNumber == syl_nb) = 1;
                for col = 1:nb_colors
                    p_tSNE{col}.XData = colormask{col}(Win(1):Win(2)).*noLines(Win(1):Win(2))'.*mask(Win(1):Win(2)).*Win_Coord(:,1);
                    p_tSNE{col}.YData = Win_Coord(:,2);
                end
            end
        end
        tSNE_Colors = contrast.*color_palet(tLabels,:);
        s_tSNE.CData = tSNE_Colors(Win(1):Win(2),:);
    end

    function tsneClick(varargin) % to start dragging net
        a = get(gca,'CurrentPoint');
        x1 = a(1,1);
        y1 = a(1,2);
        set(f, 'WindowButtonUpFcn',{@tsneUp,x1,y1});
    end

    function tsneUp(~,~,x1,y1) % when you finish dragging net
        set(f,'WindowButtonUpFcn','')
        a = get(gca,'CurrentPoint');
        x2 = a(1,1);
        y2 = a(1,2);
        
        for seg = 1:size(Win_Coord,1)-1
            xa = Win_Coord(seg,1);
            xb = Win_Coord(seg+1,1);
            ya = Win_Coord(seg,2);
            yb = Win_Coord(seg+1,2);
            crit1  = test_crit(x1,x2,y1,y2,xa,xb,ya,yb); % do the segments cross?!!!??
            crit2  = test_crit(xa,xb,ya,yb,x1,x2,y1,y2); % both criteria must be met!!
            if (crit1<0 && crit2<0 && ... % next line just checks if the lines are actually plotted
                    ~isnan(mask(seg+Win(1)-1)) && ~isnan(noLines(seg+Win(1)))&& ~isnan(noLines(seg+Win(1)-1)))
                syl_nb = tNumber(seg+Win(1)-1);
                tLabels(tNumber == syl_nb) = current_color;
                r_Label{1,syl_nb}.FaceColor = color_palet(current_color,:);
                r_Label{2,syl_nb}.FaceColor = color_palet(current_color,:);
                r_Label{1,syl_nb}.LineStyle = 'none';
                r_Label{2,syl_nb}.LineStyle = 'none';
                spectro_Colors(syl_nb,:) = color_palet(current_color,:);
                prev_color = Labels(syl_nb);
                Labels(syl_nb) = current_color;
                warning(syl_nb) = 1;
                refreshCentroid(syl_nb,prev_color); 
                for col = 1:nb_colors
                    colormask{col}(tNumber == syl_nb) = nan;
                end
                colormask{current_color}(tNumber == syl_nb) = 1;
                for col = 1:nb_colors
                    p_tSNE{col}.XData = colormask{col}(Win(1):Win(2)).*noLines(Win(1):Win(2))'.*mask(Win(1):Win(2)).*Win_Coord(:,1);
                    p_tSNE{col}.YData = Win_Coord(:,2);
                end
            end
        end
        %tSNE_Colors = mask.*contrast.*color_palet(tLabels,:);
        tSNE_Colors = contrast.*color_palet(tLabels,:);
        s_tSNE.CData = tSNE_Colors(Win(1):Win(2),:);
    end

    function crit = test_crit(x1,x2,y1,y2,xa,xb,ya,yb)
        phi = -atan((yb-ya)/(xb-xa));
        Y1 = (x1-xa)*sin(phi) + (y1-ya)*cos(phi);
        Y2 = (x2-xa)*sin(phi) + (y2-ya)*cos(phi);
        crit = sign(Y1*Y2);
    end

%% Auto-Complete buttons
btn = uicontrol('Style', 'pushbutton', 'String', '>',...
    'Position', [xs-85 2*ys/3 50 20],...
    'Callback', @autoForward);
btn = uicontrol('Style', 'pushbutton', 'String', '<',...
    'Position', [xs-85 2*ys/3-30 50 20],...
    'Callback', @autoBackward);
btn = uicontrol('Style', 'pushbutton', 'String', 'Guess',...
    'Position', [xs-85 2*ys/3-100 50 20],...
    'Callback', @autoGuess);

btn = uicontrol('Style', 'pushbutton', 'String', 'Finish',...
    'Position', [xs-85 2*ys/3-150 50 20],...
    'Callback', @autoFinish);

btn = uicontrol('Style', 'pushbutton', 'String', 'Stop!',...
    'Position', [xs-85 2*ys/3-200 50 20],...
    'Callback', @autoStop);

btn = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [xs-85 2*ys/3-250 50 20],...
    'Callback', @autoSave);

    function autoForward(~,~)
        Win = Win+min(500,size(tSNE_Coord,1)-Win(2));
        autoJump();
    end
    function autoBackward(~,~)
        Win = Win-min(500,Win(1)-1);
        autoJump();
    end
    function autoJump()
        subplot(tsnePlot);
        tsneRefresh();
        spectroRefresh();
    end
stop = false;
    function autoFinish(~,~)
        stop = false;
        while(Win(2)<size(tSNE_Coord,1) && stop == false)
            Win = Win+min(500,size(tSNE_Coord,1)-Win(2));
            autoJump();
            autoGuess(1,1);
            pause(.2);
            'ok'
        end
    end
    function autoSave(~,~)
        Results.Labels = Labels; 
        Results.Warning = warning~=1; % warning is 1/3 if there is a warning, 1 if there isn't a warning 
        [filename, pathname] = uiputfile('Tsne_labels.mat',...
                       'Save the labeling results!');
        save(fullfile(pathname, filename),'Results');
        display(['saved ' fullfile(pathname, filename)]); 
    end
    function autoStop(~,~)
        stop = true;
    end
    
    function autoGuess(~,~)
        bag = unique(tNumber(Win(1):Win(2)));
        for s = 1:length(bag)
            syl_nb = bag(s);
            y1 = tSNE_Coord(tNumber == syl_nb,1);
            y2 = tSNE_Coord(tNumber == syl_nb,2);
            y3 = tSNE_Coord(tNumber == syl_nb,3);
            x = 1:length(y1);
            trajX = interp1(x,y1,linspace(1,x(end),30));
            trajY = interp1(x,y2,linspace(1,x(end),30));
            trajZ = interp1(x,y3,linspace(1,x(end),30));
            traj = [trajX trajY trajZ]; 
            if Labels(syl_nb) == 1 % if unlabeled
                dist = nan(nb_colors-2,1); 
                for color = 3:nb_colors
                    if (~isempty(centroids{color}))
                        cent = centroids{color}(max(1,end-8):end,1:end-1); 
                        centX = mean(cent(:,1:30),1); centY = mean(cent(:,31:60),1); centZ = mean(cent(:,61:90),1); 
%                         dist(color) = (max(xcorr(centX,trajX))/max(xcorr(centX)) + ...
%                             max(xcorr(centY,trajY))/max(xcorr(centY)) + ...
%                             max(xcorr(centZ,trajZ))/max(xcorr(centZ))); 

                         dist(color-2) = sum(sqrt((trajX-mean(centX,1)).^2 + (trajY-mean(centY,1)).^2 + (trajZ-mean(centZ,1)).^2)); 
%                         dist(color) = sum((traj - mean(centroids{color}(max(1,end-5):end,1:end-1),1)).^2);
                    end
                end
                [score, ind_col] = sort(dist,'ascend');
                bestguess = ind_col(1)+2; 
                Labels(syl_nb) = bestguess;
                current_color = Labels(syl_nb); % in order to refresh the centroid properly
                tLabels(tNumber == syl_nb) = bestguess;
                tSNE_Colors = contrast.*color_palet(tLabels,:);
                s_tSNE.CData = tSNE_Colors(Win(1):Win(2),:);
                spectro_Colors(syl_nb,:) = color_palet(bestguess,:);
                if (score(1)/score(2)) < 1/2
                    refreshCentroid(syl_nb, 1);
                else
                    warning(syl_nb) = 1/3;
                end
                r_Label{1,syl_nb}.FaceColor = color_palet(bestguess,:);
                r_Label{2,syl_nb}.FaceColor = color_palet(bestguess,:);
                if warning(syl_nb) ~=1
                    r_Label{1,syl_nb}.LineStyle = '-';
                    r_Label{1,syl_nb}.LineWidth = 2;
                    r_Label{2,syl_nb}.LineStyle = '-';
                    r_Label{2,syl_nb}.LineWidth = 2;
                    
                end
                
                for col = 1:nb_colors
                    colormask{col}(tNumber == syl_nb) = nan;
                end
                colormask{bestguess}(tNumber == syl_nb) = 1;
                for col = 1:nb_colors
                    p_tSNE{col}.XData = colormask{col}(Win(1):Win(2)).*noLines(Win(1):Win(2))'.*mask(Win(1):Win(2)).*Win_Coord(:,1);
                    p_tSNE{col}.YData = Win_Coord(:,2);
                end
            end
            
            drawnow
        end
    end

    function refreshCentroid(syl_nb, prev_color)
        prev_color
        current_color
        if (prev_color ~= current_color)
            if (prev_color > 2)
                centroids{prev_color}(centroids{prev_color}(:,end)==syl_nb,:) = [];
%                  p_centroid{prev_color-1}.XData = mean(centroids{prev_color-1}(:,1:29),1);
%                  p_centroid{prev_color-1}.YData = mean(centroids{prev_color-1}(:,31:59),1);
            end
            
            if (current_color > 2)
                y1 = tSNE_Coord(tNumber == syl_nb,1);
                y2 = tSNE_Coord(tNumber == syl_nb,2);
                y3 = tSNE_Coord(tNumber == syl_nb,3);
                
                x = 1:length(y1);
                centro = [interp1(x,y1,linspace(1,x(end),30)) ...
                    interp1(x,y2,linspace(1,x(end),30)) ...
                    interp1(x,y3,linspace(1,x(end),30))];
                centroids{current_color}= [ centroids{current_color}; [centro syl_nb]];
%                 p_centroid{current_color-1}.XData = mean(centroids{current_color-1}(:,1:29),1);
%                 p_centroid{current_color-1}.YData = mean(centroids{current_color-1}(:,31:59),1);
%                 drawnow
            end
        end
    end


end


