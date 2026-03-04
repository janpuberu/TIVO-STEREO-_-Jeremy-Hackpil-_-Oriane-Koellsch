function MyFlick(I1,I2,MinMax)
%MyFlick(I1,I2,[MinMax])
% MyFlick - Alterne l'affichage des images I1 et I2 en cliquant dans l'image.
% Version avec ascenseurs pour les grandes images.
% INPUT : I1,I2 : images
%       : [MinMax] : (optionnel) dynamique de re-etallement
% On peut avoir l'affichage alterne sur un zoom de l'image en 
% (1) cliquant sur l'icone zoom de la fenetre figure, 
% (2) cliquant sur l'image pour zoomer
% (3) cliquant sur l'icone zoom pour le desactiver 
% (4) tout clic ulterieur fait alterner des versions zoomées
% Utilisez les "Data Tips" pour acceder aux coordonnées pixel
% Auteur : Ph. Cornic ONERA

I1=uint8(I1);
I2=uint8(I2);

if nargin<3 || isempty(MinMax)

    imscroll(I1);hold on
    hhh=imshow(I2,'Xdata',[1,size(I2,2)],'Ydata',[1,size(I2,1)]);
else
    
    imscroll(I1,[],MinMax);hold on
    hhh=imshow(I2,MinMax,'Xdata',[1,size(I2,2)],'Ydata',[1,size(I2,1)]);
end


set(hhh,'UserData',true);
set(gcf,'Name','I1');
masque=ones(size(I2));

set(hhh,'ButtonDownFcn',{@f_flick,hhh,masque,gcf});

end
function f_flick(src,event,hdl,masque,fig)

bool=get(hdl,'UserData');
   
if bool
    
    set(hdl,'UserData',false);
    set(hdl,'AlphaData',0);
    set(fig,'Name','I1');
    
else
    
    set(hdl,'UserData',true);    
    set(hdl,'AlphaData',masque);
    set(fig,'Name','I2');
end
end


function imscroll(I,hFig,MinMax)
% imscroll(I,hFig,[MinMax])
if nargin<2 || isempty(hFig),
    hFig=figure;
end
    
    if nargin<3
        hIm=imshow(I);hSP = imscrollpanel(hFig,hIm);
    else
        hIm=imshow(I,MinMax);hSP = imscrollpanel(hFig,hIm);
    end
end
