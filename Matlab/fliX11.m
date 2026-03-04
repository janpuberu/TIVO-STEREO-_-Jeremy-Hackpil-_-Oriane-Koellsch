function fliX11(ima1,ima2,fps,mini,maxi)
% fliX11 - affichage en boucle de deux images 
% USAGE : fliX11(ima1,ima2,mini,maxi)
%

clf('reset')
switch (nargin)
  case {5}
	H=fnb(ima1,mini,maxi);
  case {3}
	mini = min([ima1(:); ima2(:)]);
	maxi = max([ima1(:); ima2(:)]);
	H=fnb(ima1);
  case {2}
	fps=8;
	mini = min([ima1(:); ima2(:)]);
	maxi = max([ima1(:); ima2(:)]);
	H=fnb(ima1);
  otherwise
	fprintf(1,'nombre d''arguments incorrect\n');
	return
end

%clear ima1
%long_seq=size(seq,3);
%set(gcf,'Name',['sequence de ',int2str(long_seq),' images'])
title('CLICK/TOUCHE POUR STOPPER')
set(H,'EraseMode','none')

% Sequence en boucle
rep=0;
chaine = 'set(gca,''UserData'' ,1)';
set(gca,'UserData' ,0)
set(gca,'ButtonDownFcn',chaine)
set(gcf,'KeyPressFcn',chaine)
while rep==0
  set(gcf,'Pointer','watch')
  set(H,'CData',ima1)
  drawnow
  pause(1/fps)
  set(H,'CData',ima2)
  drawnow
  pause(1/fps)
  %pause(2)
  %set(gcf,'Pointer','arrow')
  %rep=waitforbuttonpress;
  %if rep==1, break, end
  if get(gca,'UserData') == 1;break;end
end
set(gcf,'Pointer','arrow')
 
