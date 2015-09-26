function [gravity_center, deviation] = fun_gravity(spectrum,F)
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
gravity_center = F(ceil(gravity_center));
deviation = sqrt(sum(P.*(repmat(F(:),1,size(P,2)) - repmat(gravity_center(:)',size(P,1),1)).^2,1)); 


% %std(XP);
% deltaF = F(2)-F(1);
% deviation = deviation; 



