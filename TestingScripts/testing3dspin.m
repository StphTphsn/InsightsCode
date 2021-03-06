n = 20
blob = randn(n,3)*.4; 
blob(blob>1) = 1; 
colors = abs(blob);%ones(n,3); ; 

figure(1); set(gcf, 'color', [0 0 0])
angleRot = 0; 
u = [0 1 1]; 

for angleRot = 0:10:8*180
    cla; hold on
    xlim([-1 1]); ylim([-1 1]); zlim([-1 1]); axis off
    scatter3Dspin(blob,colors,angleRot, u)
    title(num2str(angleRot))
    set(gca, 'color', [0 0 0])
    pause(.1)
end
