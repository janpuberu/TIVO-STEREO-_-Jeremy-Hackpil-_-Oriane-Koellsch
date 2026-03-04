function [h,hcb]=fnb(ima,min,max,optionColorbar)
% fnb       - Affichage image noir et blanc (colormap bone)
% USAGE : [h, hcb]= fnb(ima,[min],[max],[colorbarOUI]);
%
% Origine : Muriel Brunet
% Customisation : FChamp 31/01/00

if nargin==0, help fnb, return, end
if nargin==1
  h=imagesc(ima);
else
  h=imagesc(ima,[min max]);
end
axis('image'), colormap('bone'), 
if nargin < 4
  optionColorbar = 1;
end
if optionColorbar ~= 0
  hcb = colorbar;
end
