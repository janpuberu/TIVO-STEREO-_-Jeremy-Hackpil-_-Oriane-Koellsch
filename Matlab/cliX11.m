function cliX11(ima1,ima2,mini,maxi)
% cliX11 - affichage en boucle de deux images 
% USAGE : fliX11(ima1,ima2,mini,maxi)
%

clf('reset')
if nargin<3
  mini = min([ima1(:); ima2(:)]);
  maxi = max([ima1(:); ima2(:)]);
  H=imagesc(ima1);
else
   H=imagesc(ima1,[mini,maxi]);
end
colormap('gray');axis('image'); 
title('CLICK POUR SWAP/TOUCHE POUR STOPPER')
set(H,'EraseMode','none')

% Sequence en boucle
rep=0;
chaineTouche = 'set(gca,''UserData'',1)';
chaineClic = 'set(gca,''UserData'',2)';
set(gca,'UserData' ,0)
set(gcf,'WindowButtonDownFcn',chaineClic)
set(gcf,'KeyPressFcn',chaineTouche)
imacour = ima1;
imanext = ima2;
tampon=ima1;
clear ima1 ima2

set(gcf,'Pointer','arrow') 
while rep==0
  %set(gcf,'Pointer','watch')
	drawnow;   % necessaire sinon ca ne marche pas
   if get(gca,'UserData') == 2;
	tampon = imacour;
	imacour = imanext;
	imanext=tampon;
	set(H,'CData',imacour)
	drawnow
	set(gca,'UserData' ,0)
  end
  if get(gca,'UserData') == 1;break;end
end
set(gcf,'Pointer','arrow')
 
