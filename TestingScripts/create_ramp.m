function [rampt]  = create_ramp(labels)
nb_added_dim = 300/3;
s = linspace(-1, 1, nb_added_dim);
nb_steps = 1000;
ramp = zeros(nb_added_dim,nb_steps);
for j = 1:nb_steps
    bump = exp( -(s.^2)/(0.3+1/2-(abs(j-nb_steps/2))/nb_steps)); % change from .03 to clip more or less
    bump = 200/3*bump/sum(bump);
    ramp(:,j) = circshift(bump',round(j/nb_steps*nb_added_dim/2));
end

rampt = ramp(:,ceil(nb_steps*(1-(ceil(labels)-labels))));
% figure; imagesc(ramp);
% figure; imagesc(rampt);