clear all;clc
load('tSNE_PURPLE')

selected = rand(size(Spectro,2),1)>=0;

figure; plot(selected)

tSNE_Coord = tSNE_Coord(selected,:);

save('tSNE_PURPLE_sub','tSNE_Coord','selected','Spectro')