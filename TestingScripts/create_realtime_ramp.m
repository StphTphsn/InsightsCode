function [RampRamp]  = create_realtime_ramp(beg_ind_syl,end_ind_syl,length_biggest_syllable,total_length)
nb_added_dim = 100;
RampRamp = zeros(nb_added_dim,total_length);

for syl =1 :length(beg_ind_syl)
    syl;
    nb_steps = end_ind_syl(syl) - beg_ind_syl(syl)+1;
    s = linspace(-1, 1, nb_added_dim);
    ramp = zeros(nb_added_dim,nb_steps);
    for j = 0:nb_steps-1
        bump = exp( -(s.^2)/(0.1+2*(1/2-(abs(j+0.5-nb_steps/2))/nb_steps))); % change from .03 to clip more or less
        bump = 200/3*bump/sum(bump);
        ramp(:,j+1) = circshift(bump',round((j+(length_biggest_syllable - nb_steps)/2) ...
            /length_biggest_syllable*nb_added_dim/2));
    end
    RampRamp(:,beg_ind_syl(syl):end_ind_syl(syl)) = ramp;
end