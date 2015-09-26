function [X_smooth, Y_smooth,Z_smooth,nb_iter,step_size,window_size] = recurrent_tSNE_3D(Data, parameters)

max_nb_iter = 100;
nb_points_tot = size(Data,2);
% parameters = setRunParameters;
window_size = 1000;
window_first_pt = nb_points_tot-window_size+1;
window_last_pt = nb_points_tot;
step_size = 50;
nb_iter = min(max_nb_iter, floor((nb_points_tot-window_size)/step_size));


% parameters.training_perplexity = 2*20;
% parameters.perplexity = 2*32;
% parameters.num_tsne_dim = 3;

tSNEcoord_X = zeros(window_size,nb_iter);
tSNEcoord_Y = zeros(window_size,nb_iter);
tSNEcoord_Z = zeros(window_size,nb_iter);
% tSNEcoord_L = zeros(window_size,nb_iter);
% tSNEcoord_T = zeros(window_size,nb_iter);

for iter =1:nb_iter
    [y,betas,P,errors] = run_tSne(Data(:,window_first_pt:window_last_pt)', parameters);
    tSNEcoord_X(:,iter) = y(:,1);
    tSNEcoord_Y(:,iter) = y(:,2);
    tSNEcoord_Z(:,iter) = y(:,3);
%     tSNEcoord_L(:,iter) = labels(window_first_pt:window_last_pt);
%     tSNEcoord_T(:,iter) = times(window_first_pt:window_last_pt);
    parameters.num_tsne_dim = [zeros(step_size,3); y(1:end-step_size,:)];
    window_first_pt = window_first_pt - step_size;
    window_last_pt = window_last_pt - step_size;
    display(['recurrent tSne iteration ' num2str(iter) '/' num2str(nb_iter)])
end



magic_factor = window_size/step_size;

X_aligned = zeros(window_size,nb_iter- magic_factor+1);
Y_aligned = zeros(window_size,nb_iter- magic_factor+1);
Z_aligned = zeros(window_size,nb_iter- magic_factor+1);
% L_aligned = zeros(window_size,nb_iter- magic_factor+1);
% T_aligned = zeros(window_size,nb_iter- magic_factor+1);

for i = 1:magic_factor
    X_aligned(i+(0:step_size-1)*magic_factor,:) = tSNEcoord_X((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    Y_aligned(i+(0:step_size-1)*magic_factor,:) = tSNEcoord_Y((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    Z_aligned(i+(0:step_size-1)*magic_factor,:) = tSNEcoord_Z((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
%     L_aligned(i+(0:step_size-1)*magic_factor,:) = L2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
%         T_aligned(i+(0:step_size-1)*magic_factor,:) = T2((i-1)*step_size +(1:step_size), i:end+i-magic_factor);
    
end


X_smooth = zeros(step_size,nb_iter- magic_factor+1);
Y_smooth = zeros(step_size,nb_iter- magic_factor+1);
Z_smooth = zeros(step_size,nb_iter- magic_factor+1);
% L_smooth = zeros(step_size,nb_iter- magic_factor+1);
% T_smooth = zeros(step_size,nb_iter- magic_factor+1);
for i = 1:step_size
    X_smooth(i,:) = mean(X_aligned((i-1)*magic_factor+(1:magic_factor), :));
    Y_smooth(i,:) = mean(Y_aligned((i-1)*magic_factor+(1:magic_factor), :));
    Z_smooth(i,:) = mean(Z_aligned((i-1)*magic_factor+(1:magic_factor), :));
%     L_smooth(i,:) = mean(L_aligned((i-1)*magic_factor+(1:magic_factor), :));
%         T_smooth(i,:) = mean(T_aligned((i-1)*magic_factor+(1:magic_factor), :));
end


figure;imagesc(X_smooth);colorbar;
% figure;imagesc(L_smooth);colorbar;





end