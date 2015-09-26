function [rampt]  = create_straight_ramp(labels)
nb_added_dim = 300/3;
s = linspace(-1, 1, 3*nb_added_dim);
nb_steps = 1000;
ramp = zeros(nb_added_dim,nb_steps);
    bump = exp( -(s.^2)/(0.001));
    bump = bump/sum(bump);
for j = 1:nb_steps

    ramp(:,j) = bump(round(0.75*nb_added_dim)+(round(j/nb_steps*nb_added_dim/2)+1 : ...
        round(j/nb_steps*nb_added_dim/2)+nb_added_dim));
end

%figure;imagesc(ramp);

rampt = ramp(:,ceil(nb_steps*(1-(ceil(labels)-labels))));