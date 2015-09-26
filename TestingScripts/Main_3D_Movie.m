%% Create 3D movie of development of the repertoire of a songbird

close all; clc;
addpath(genpath('dummy/..'));
folder = 'to3965_2013-11-03_labeled_100.mat';
fs = 40000;

%% load data

bouts = 1:10;
[songs, labels, spikes, times, syl_nb, cuts] = load_songs_tot(folder,bouts);
figure;plot(songs);
figure;plot(times);
drawnow;
%% compute spectrograms

S = compute_spectrograms(songs, cuts);

figure;
imagesc(S);
cmap = hot;
cmap(1,:) = zeros(1,3);
colormap(cmap)
drawnow;
%% keep only the syllables

[Skeep, labelsKeep, timesKeep] = keep_only_syllables(S, labels, times, cuts);
figure;
imagesc(Skeep);
cmap = hot;
cmap(1,:) = zeros(1,3);
colormap(cmap)
drawnow;
%% include ramp

ramp = create_ramp(labelsKeep);

Sramp = [Skeep; ramp];

figure;
imagesc(Sramp);
cmap = hot;
cmap(1,:) = zeros(1,3);
colormap(cmap)
drawnow;

%% compute recurrent tSNE

[X2, Y2, Z2 ,L2, T2, nb_iter,step_size,window_size] = recurrent_tSNE_3D(Sramp,labelsKeep, timesKeep);

%% smooth trajectories

magic_factor = window_size/step_size;

X_aligned = zeros(window_size,nb_iter- magic_factor+1);
Y_aligned = zeros(window_size,nb_iter- magic_factor+1);
Z_aligned = zeros(window_size,nb_iter- magic_factor+1);
L_aligned = zeros(window_size,nb_iter- magic_factor+1);
T_aligned = zeros(window_size,nb_iter- magic_factor+1);

for i = 1:magic_factor
    X_aligned(i+(0:step_size-1)*magic_factor,:) = X2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    Y_aligned(i+(0:step_size-1)*magic_factor,:) = Y2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    Z_aligned(i+(0:step_size-1)*magic_factor,:) = Z2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    L_aligned(i+(0:step_size-1)*magic_factor,:) = L2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
        T_aligned(i+(0:step_size-1)*magic_factor,:) = T2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    
end


X_smooth = zeros(step_size,nb_iter- magic_factor+1);
Y_smooth = zeros(step_size,nb_iter- magic_factor+1);
Z_smooth = zeros(step_size,nb_iter- magic_factor+1);
L_smooth = zeros(step_size,nb_iter- magic_factor+1);
T_smooth = zeros(step_size,nb_iter- magic_factor+1);
for i = 1:step_size
    X_smooth(i,:) = mean(X_aligned((i-1)*magic_factor+(1:magic_factor), :));
    Y_smooth(i,:) = mean(Y_aligned((i-1)*magic_factor+(1:magic_factor), :));
    Z_smooth(i,:) = mean(Z_aligned((i-1)*magic_factor+(1:magic_factor), :));
    L_smooth(i,:) = mean(L_aligned((i-1)*magic_factor+(1:magic_factor), :));
        T_smooth(i,:) = mean(T_aligned((i-1)*magic_factor+(1:magic_factor), :));
end


figure;imagesc(X_smooth);colorbar;
figure;imagesc(L_smooth);colorbar;

%% 3D movie

X1 = X_smooth(:);
X1 = X1-mean(X1);
Y1 = Y_smooth(:);
Y1 = Y1-mean(Y1);
Z1 = Z_smooth(:);
Z1 = Z1-mean(Z1);

L1 = L_smooth(:);

T1 = T_smooth(:);

figure; 
%%
[newdata, R, t] = AxelRot([X1 Y1 Z1]', 100, [-1 1 1], [0 0 0]);
plot(newdata(1,:), newdata(2,:),'.')
X1 = newdata(1,:)'; Y1 = newdata(2,:)'; Z1 = newdata(3,:)'; 
%%

sylColors = [0 0 0; 1 1 1 ; 0 0 1; 1 0 0; 0 1 0; 1 1 0; 1 0 1; 0 1 1];

figure('position',[0 0 800 800]); hold on;

angleRot = 0; 
u = [1 1 0]; 

sliding_window = 1:window_size;
for i = 1:nb_iter- magic_factor+1
    %L_smooth(L_smooth==0)=eps;
    magic_mat=zeros(window_size,8);
    for t = 1:window_size
        magic_mat(t,1+ceil(L1(sliding_window(1)+t-1))) = 1;
    end
    colors =   (1/4 + 3/4* repmat(1-(ceil(L1(sliding_window))- L1(sliding_window)),1,3)).* (magic_mat * sylColors);
    %h{i} = scatter3(X_smooth(:,i), Y_smooth(:,i), Z_smooth(:,i), 50,colors,'s','filled');
    xlim([-20 20]);
    ylim([-20 20]);
    angleRot = angleRot+5;
    PTS = [X1(sliding_window), Y1(sliding_window), Z1(sliding_window)];
    u = mean(PTS(L1(sliding_window) == 0,:));
    cla;
    scatter3Dspin_with_lines([X1(sliding_window), Y1(sliding_window), Z1(sliding_window)],colors,angleRot, u)
    title(num2str(angleRot))
    text(10,15,[num2str(round(T1(sliding_window(1))-datenum('7/16/2013'))) ' dph'],'fontsize',20,'color', 'w');
    set(gca, 'color', [0 0 0])
    pause(.1)
    sliding_window = sliding_window+1;
    

    %axis off; shg; set(gcf, 'color', 'k');
    %pause(0.1);
    %view(45,25+4*i);
end




%% JUNK CODE
%h = cell(magic_factor,1);
% for i = 1:magic_factor
%     %L_smooth(L_smooth==0)=eps;
%     magic_mat=zeros(step_size,7);
%     for t = 1:step_size
%         magic_mat(t,ceil(L_smooth(t,i))) = 1;
%     end
%     colors =   (1/4 + 3/4* repmat(1-(ceil(L_smooth(:,i))- L_smooth(:,i)),1,3)).* (magic_mat * sylColors);
%     h{i} = scatter3(X_smooth(:,i), Y_smooth(:,i), Z_smooth(:,i), 50,colors,'s','filled');
% 
% 
%     axis off; shg; set(gcf, 'color', 'k');
%     %pause(0.1);
%     view(45,25+4*i);
% end

% change_ind = 1; 
% for i = magic_factor+1:nb_iter- magic_factor+1    
%     %L_smooth(L_smooth==0)=eps;
%     magic_mat=zeros(step_size,7);
%     for t = 1:step_size
%         magic_mat(t,ceil(L_smooth(t,i))) = 1;
%     end
%     colors =    (1/4 + 3/4* repmat(1-(ceil(L_smooth(:,i))- L_smooth(:,i)),1,3)).* (magic_mat * sylColors);
%     %scatter3(X_smooth(:,i-20), Y_smooth(:,i-20), Z_smooth(:,i-20), 50,[0 0 0],'s','filled')
%     h{change_ind}.XData = X_smooth(:,i);
%     h{change_ind}.YData = Y_smooth(:,i);
%     h{change_ind}.ZData = Z_smooth(:,i);
%     h{change_ind}.CData = colors;
%     change_ind = mod(change_ind+1,magic_factor)+1;
%     axis off; shg; set(gcf, 'color', 'k');
%     pause(0.1);
%     view(45,25+4*i);
%     
% end

% for i = 20:nb_iter- magic_factor+1
%
%     %L_smooth(L_smooth==0)=eps;
%     magic_mat=zeros(step_size,7);
%     for t = 1:step_size
%         magic_mat(t,ceil(L_smooth(t,i))) = 1;
%     end
%     colors =  magic_mat * sylColors;
%     scatter3(X_smooth(:,i), Y_smooth(:,i), Z_smooth(:,i), 50,colors,'s','filled')
%     axis off; shg; set(gcf, 'color', 'k');
% end




%




