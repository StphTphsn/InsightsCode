function scatter3Dspin(positions, colors, angleRot, u, x0)
%  u, x0: 3D vectors specifying the line in parametric form x(t)=x0+t*u 
%         Default for x0 is [0,0,0] corresponding to pure rotation (no shift).
%         If x0=[] is passed as input, this is also equivalent to passing
%         x0=[0,0,0].
if nargin<5; x0 = [0,0,0]; end

msize = 20; 
[XYZnew, R, t] = AxelRot(positions', angleRot, u, x0); % R is a 3x3 rotation and t is a 3x1 translation vector.
XYZnew = XYZnew';
sizes = XYZnew*[1; -1; 0]; 
sizes = sizes-min(sizes); 
sizes = sizes/max(sizes); 
sizes = msize + sizes*msize; 
%scatter(XYZnew(:,1), XYZnew(:,2), sizes, colors, 'o', 'markerfacecolor', 'flat'); 
scatter3(XYZnew(:,1), XYZnew(:,2), XYZnew(:,3), sizes, colors, 's', 'markerfacecolor', 'flat'); 
%plot3(XYZnew(:,1), XYZnew(:,2), XYZnew(:,3), ' colors,
view(45,25)
hold on; plot3([-u(1) u(1)], [-u(2) u(2)],[-u(3) u(3)], 'r')