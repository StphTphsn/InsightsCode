function [NCLUST halo] = cluster_dp(xx)
% code from from A Rodriguez, A Laio, 
% Clustering by fast search and find of density peaks
% SCIENCE, 1492, vol 322 (2014) 
% http://people.sissa.it/~laio/Research/Res_clustering.php

% minor modifications, Emily Mackevicius

% use something like this to get xx from Data 
% nt = size(Data,1); % number of datapoints
% nf = size(Data,2); % number of dimensions
% D = pdist(Data, 'euclidean'); 
% xx = [squareform(repmat(1:nt,nt,1).*~eye(nt))' ...
%     squareform(repmat((1:nt)',1,nt).*~eye(nt))' ...
%     D']; 

if size(xx,2)~=3
    disp('The format of xx be: ')
    disp('Column 1: id of element i')
    disp('Column 2: id of element j')
    disp('Column 3: dist(i,j)')
end

ND=max(xx(:,2));
NL=max(xx(:,1));
if (NL>ND)
  ND=NL;
end
N=size(xx,1);
for i=1:ND
  for j=1:ND
    dist(i,j)=0;
  end
end
for i=1:N
  ii=xx(i,1);
  jj=xx(i,2);
  dist(ii,jj)=xx(i,3);
  dist(jj,ii)=xx(i,3);
end
percent=.5;
fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);

position=round(N*percent/100);
sda=sort(xx(:,3));
dc=sda(position);

fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);


for i=1:ND
  rho(i)=0.;
end
%
% Gaussian kernel
%
for i=1:ND-1
  for j=i+1:ND
     rho(i)=rho(i)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
     rho(j)=rho(j)+exp(-(dist(i,j)/dc)*(dist(i,j)/dc));
  end
end
%
% "Cut off" kernel
%
%for i=1:ND-1
%  for j=i+1:ND
%    if (dist(i,j)<dc)
%       rho(i)=rho(i)+1.;
%       rho(j)=rho(j)+1.;
%    end
%  end
%end

maxd=max(max(dist));

[rho_sorted,ordrho]=sort(rho,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

for ii=2:ND
   delta(ordrho(ii))=maxd;
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));
disp('Generated file:DECISION GRAPH')
disp('column 1:Density')
disp('column 2:Delta')

fid = fopen('DECISION_GRAPH', 'w');
for i=1:ND
   fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
end

disp('Select a rectangle enclosing cluster centers')
scrsz = get(0,'ScreenSize');
h = figure; clf; hold on; %set(gcf, 'Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);
set(gcf, 'papersize', [3 2], 'paperposition',[0 0 3 2])
for i=1:ND
  ind(i)=i;
  gamma(i)=rho(i)*delta(i);
end

tt=plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')


rect = getrect(h);
rhomin=rect(1);%40; %prctile(rho(:),75);%
deltamin=rect(2);%.6; %prctile(delta(:),75);%rect(2);
NCLUST=0;
for i=1:ND
  cl(i)=-1;
end
for i=1:ND
  if ( (rho(i)>rhomin) && (delta(i)>deltamin))
     NCLUST=NCLUST+1;
     cl(i)=NCLUST;
     icl(NCLUST)=i;
  end
end
fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')

%assignation
for i=1:ND
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end
%halo
for i=1:ND
  halo(i)=cl(i);
end
if (NCLUST>1)
  for i=1:NCLUST
    bord_rho(i)=0.;
  end
  for i=1:ND-1
    for j=i+1:ND
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(cl(i))) 
          bord_rho(cl(i))=rho_aver;
        end
        if (rho_aver>bord_rho(cl(j))) 
          bord_rho(cl(j))=rho_aver;
        end
      end
    end
  end
  for i=1:ND
    if (rho(i)<bord_rho(cl(i)))
      halo(i)=0;
    end
  end
end
for i=1:NCLUST
  nc=0;
  nh=0;
  for j=1:ND
    if (cl(j)==i) 
      nc=nc+1;
    end
    if (halo(j)==i) 
      nh=nh+1;
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(i),nc,nh,nc-nh);
end

Colors = jet(NCLUST); 
for i=1:NCLUST
   %ic=int8((i*64.)/(NCLUST*1.));
   %subplot(2,1,1)
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',Colors(i,:),'MarkerEdgeColor',Colors(i,:));
end
drawnow
% subplot(2,1,2)
% disp('Performing 2D nonclassical multidimensional scaling')
% Y1 = mdscale(dist, 2, 'criterion','metricstress');
% plot(Y1(:,1),Y1(:,2),'o','MarkerSize',2,'MarkerFaceColor','k','MarkerEdgeColor','k');
% title ('2D Nonclassical multidimensional scaling','FontSize',15.0)
% xlabel ('X')
% ylabel ('Y')
% for i=1:ND
%  A(i,1)=0.;
%  A(i,2)=0.;
% end
% for i=1:NCLUST
%   nn=0;
%   ic=int8((i*64.)/(NCLUST*1.));
%   for j=1:ND
%     if (halo(j)==i)
%       nn=nn+1;
%       A(nn,1)=Y1(j,1);
%       A(nn,2)=Y1(j,2);
%     end
%   end
%   hold on
%   plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
% end

%for i=1:ND
%   if (halo(i)>0)
%      ic=int8((halo(i)*64.)/(NCLUST*1.));
%      hold on
%      plot(Y1(i,1),Y1(i,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
%   end
%end
faa = fopen('CLUSTER_ASSIGNATION', 'w');
disp('Generated file:CLUSTER_ASSIGNATION')
disp('column 1:element id')
disp('column 2:cluster assignation without halo control')
disp('column 3:cluster assignation with halo control')
for i=1:ND
   fprintf(faa, '%i %i %i\n',i,cl(i),halo(i));
end
