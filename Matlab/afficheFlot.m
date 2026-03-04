function [] = afficheFlot(I1,I2,u,v,numFig,facteur,affNorme,pas)
% afficheFlot - affiche flot optique et norme/erreur de recalage
%
% function [] = afficheFlot(I1,I2,u,v)
% function [] = afficheFlot(I1,I2,u,v,numFig,facteur,affNorme)
% numFig : 2x1, numero figures pour affichage (defaut = [1,2])
% facteur : echelle des fleches ds rep flot par quiver
% affNorme = 0 : affichage de la difference inter image
% affNorme > 0 : affichage de la norme seuillee a affNorme
% pas : pas utilise pour l'affichage des vecteurs dans le quiver
%       (optionnel : defaut = 8)
%
% ONERA/DTIM/IED --- Guy Le Besnerais 10/04
  
if (nargin==4)
    numFig=[1,2];
    facteur =1;
    affNorme=1;
    pas=16;
end

[nl,nc]=size(u);
I1=I1(1:nl,1:nc);
I2=I2(1:nl,1:nc);
[X,Y]=meshgrid((1:nc),(1:nl));
I2cour=interp2(I2,X+u,Y+v,'linear');
indNan=find(isnan(I2cour));
I2cour(indNan)=0;

if (not(exist('pas')))
  pas=16;
end
if not(length(facteur))
  noru=sqrt(u.^2+v.^2);
  normoy=mean(noru(:));
  facteur = (max([nl,nc])/50)/normoy; 
end  
figure(numFig(1)),colormap(gray)
imagesc(I1),colormap(gray)
hold on
truc=quiver(X(1:pas:end,1:pas:end),Y(1:pas:end,1:pas:end),u(1:pas:end,1:pas:end)*facteur,v(1:pas:end,1:pas:end)*facteur,0);
set(truc,'color','yellow');
set(truc,'linewidth',1.5);
axis('ij');   
axis([1 nc 1 nl]);
axis('image')
title(sprintf('champ de deplacement, facteur = %f',facteur))
hold off

if (length(numFig)==2)
  if (affNorme)
    figure(numFig(2)),colormap(jet);
    normFlot=sqrt(u.^2+v.^2);
    imagesc(min(normFlot,affNorme)),axis('image')
    colorbar
  else
    figure(numFig(2)),colormap(gray)
    imagesc([I1-I2,I1-I2cour]),axis('image')
    colormap(gray)   
  end
end















