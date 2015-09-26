function [gravity_center, deviation] = fun_gravity(spectrum)
P = spectrum;
for i = 1:size(P,2)
    P(:,i) = P(:,i)/sum(P(:,i));
end
%figure;imagesc(P);colorbar
% diagonal matrix with increasing values used to calculate the gravity
% center of the spectrum
M = diag(1:size(P,1));

% XP is the weighed probability of each random variable value x;
XP = M'*P;

%figure;imagesc(XP);colorbar


gravity_center = sum(XP);
deviation = std(XP);



