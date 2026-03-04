function [R,T,P,map3D] = odoStereo(L1,R1,L2,matK,baseline,nbPtsMin,DISPLAY)
% odometry
% [R,T,P,map3D] = odoStereo(L1,R1,L2,matK,baseline,nbPtsMin);
%
% Uses matched Orb points (L1,R1) to triangulate 3D points find them in
% L2 images and compute the pose.
% The pose estimation is then refined with non-linear estimation

% INPUT:
%   L1 : left image instant t
%   R1 : right image instant t
%   L2 : left image instant t+1
%   matK : intrinsic matrix
%   baseline : base line of the stereo rig
%   nbPtsMin : min number of points to compute the pose. [30]
%   DISPLAY : display matched points Left,Right and matched points L1 L2  [0]   
%
% OUTPUT:
%
%  R : rotation of the stereo rig between t and t+1 (in the frame of L1) :
%  X_{t+1}=R(X_t -T)
%  T : translation of the stereo rig between t and t+1
%  P : L2 projection matrix : P=[R,-R*T]
%  map3D : triangulated points

% input : L1,R1,L2,focale,matK,baseline
% output : R,T,P,map3D
% projection fct L2 : P=[R,-R*T]
% test interne de rejet : nb de points min (nbPtsMin)

%Utiliser la matrice fondamentale (pour eviter d avoir a utiliser un mask

if (nargin<5)
    nbPtsMin=30;
end

if nargin<6
    DISPLAY=0;
end

seuilEpipo=0.8;
[nl,nc]=size(L1);
focale=matK(1,1);

pointsL1 = detectORBFeatures(L1);
[featuresL1, valid_pointsL1] = extractFeatures(L1, pointsL1);
% affichage des points gauche
if (DISPLAY)
    figure(1),imagesc(L1),colormap(gray),axis('image')
    hold on
    plot(pointsL1)
    hold off
end

pointsR1 = detectORBFeatures(R1);
[featuresR1, valid_pointsR1] = extractFeatures(R1, pointsR1);

% matching gauche-droite
indexPairs = matchFeatures(featuresL1, featuresR1);
matchedPointsL1 = valid_pointsL1(indexPairs(:, 1), :);
matchedPointsR1 = valid_pointsR1(indexPairs(:, 2), :);
if (DISPLAY)
    figure; showMatchedFeatures(L1, R1, matchedPointsL1, matchedPointsR1);
end

% test de la geo epipolaire et selection des points
seuilDisp = 1.0;
deplt=matchedPointsR1.Location-matchedPointsL1.Location;
indEpipo=find(abs(deplt(:,2))<seuilEpipo & abs(deplt(:,1))>seuilDisp)  ; %Modifié
matchedPointsL1=matchedPointsL1(indEpipo,:);
matchedPointsR1=matchedPointsR1(indEpipo,:);
deplt=deplt(indEpipo,:);
disparite=deplt(:,1);
nbMatchLR = size(indEpipo,1);
if (DISPLAY)
    figure; showMatchedFeatures(L1, R1, matchedPointsL1, matchedPointsR1);
    %title(sprintf('Appariement G-D instant %d',numIma(instant1)))
    title('Appariement G-D')
end


% triangulation
profondeur = focale * baseline./abs(disparite);
map3D1 = repmat(profondeur(:)',[3,1]).*(inv(matK)*...
    [matchedPointsL1.Location';ones(1,nbMatchLR)]);
map3D1=double(map3D1);
% affichage
if (DISPLAY)
                
    vue3D(10,map3D1,matK,[nl,nc],zeros(6,1),'red','create');
    %title(sprintf('Reconstruction 3D instant %d',numIma(instant1)));
    title('Reconstruction 3D');
end

pointsL2 = detectORBFeatures(L2);
[featuresL2, valid_pointsL2] = extractFeatures(L2, pointsL2);
indexAux = matchFeatures(featuresL1, featuresL2);
tksL1=valid_pointsL1(indexAux(:,1),:);
tksL2=valid_pointsL2(indexAux(:,2),:);

if (DISPLAY)
    figure; showMatchedFeatures(L1, L2, tksL1, tksL2);
    %title(sprintf('Appariement temporel instants %d-%d',numIma(instant1),numIma(instant2)));
    title('Appariement temporel');
    
end

% selection
matchedFeaturesL1 = binaryFeatures(featuresL1.Features(indexPairs(indEpipo, 1),:));
indexTracks = matchFeatures(matchedFeaturesL1, featuresL2);



tracksL1=matchedPointsL1(indexTracks(:,1),:);
tracksL2=valid_pointsL2(indexTracks(:,2),:);

if 1 %(DISPLAY)
    figure()
    showMatchedFeatures(L1, L2, tracksL1, tracksL2);
    %title(sprintf('Appariement temporel avant filtre matrice temporelle (selectionne) instants %d-%d',numIma(instant1),numIma(instant2)));
    title('Appariements temporels selectionnés avant filtrage matrice Fondamentale');
    text(double(tracksL1.Location(:,1)),double(tracksL1.Location(:,2)),num2str([1:size(tracksL1,1)]'))
end


%MODIF : matrice fondammentale/essentielle
[F,inliersIndex] = estimateFundamentalMatrix(tracksL1,tracksL2);

tracksL1 = tracksL1(inliersIndex, :);
tracksL2 = tracksL2(inliersIndex, :);
%fin modif

if 1 %(DISPLAY)
    figure()
    showMatchedFeatures(L1, L2, tracksL1, tracksL2);
    %title(sprintf('Appariement temporel (selectionne) instants %d-%d',numIma(instant1),numIma(instant2)));
    title('Appariements temporels selectionnés');
    text(double(tracksL1.Location(:,1)),double(tracksL1.Location(:,2)),num2str([1:size(tracksL1,1)]'))
end

% association 2D-3D
map3D2=map3D1(:,indexTracks(:,1));

map3D2   = map3D2(:, inliersIndex); %Modifié

nbPts=length(map3D2);

% test
if nbPts<nbPtsMin
    fprintf(1,'nb appariement 2D-3D (=%d) trop faible (<%d)\n',nbPts,nbPtsMin);
    return;
end

% mise en forme
pts3D=map3D2';           % dim : nbX x 3
pts2D=double(tracksL2.Location); % dim : nbX x 2

% calcul de pose lineaire
posN=inv(matK)*[pts2D';ones(1,nbPts)];
posN=posN';
M=[-pts3D,-ones(nbPts,1),zeros(nbPts,4),repmat(posN(:,1),1,3).*pts3D,posN(:,1)];
M=[M;[zeros(nbPts,4),-pts3D,-ones(nbPts,1),repmat(posN(:,2),1,3).*pts3D,posN(:,2)]];
[U,S,V] = svd(M);
pest=V(:,end);

pest=pest/norm(pest(9:11));
Pest=reshape(pest,4,3)';
if det(Pest(:,1:3))<0
    Pest=-Pest;
end

% affichage superposant position initiale et finale
if (DISPLAY)
    vue3D(10,map3D2,matK,[nl,nc],zeros(6,1),'red','create');
    vue3D(10,map3D2,matK,[nl,nc],Pest,'green','addcam');
               
end

% --------- affinage non lineaire
[Ur,Sr,Vr] = svd(Pest(1:3,1:3)); % avant : transpose
Rest=Ur*Vr';
% retour en angle et translation
angcandidat = rot2ang(Rest);
% on selectionne l'angle le plus proche de l'angle precedent (ie. le plus
% faible)
[~,imin]=min(sum(angcandidat.^2));
anginit = angcandidat(:,imin);
%Tinit=Pest(1:3,4);
Tinit=-Rest'*Pest(1:3,4);
anginit, Tinit, matK
[angfin, Tfin] = affinageRT(anginit, Tinit, matK, pts3D, pts2D);
mvtfin=[angfin(:);Tfin(:)];

if (DISPLAY)
    vue3D(10,map3D2,matK,[nl,nc],mvtfin,'magenta','addcam');
end

% rotation/translation finales
T=Tfin;
R=ang2rot(angfin);
P=[R,-R*T];
map3D=map3D2;
end

function ang = rot2ang(matR)
% fct rot2ang : passage d'une rotation 3D a 3 angles
%
% forme d'appel
%    ang=rot2ang(R);
%
% Entree
% - R : matrice 3x3 de rotation
% Sortie
% - ang : angles des rotations autour de z,x,y
% Attention ang est 2x3 car il y a deux possibilites de codage
%
% NB : codage Euler d'une rotation en zxy
%
% ONERA/DTIM

if (abs(matR(3,2))~=1)
  
  ang = zeros(2,3);
  
  % rotation angle around x axis
  ang(1,2) = asin(-matR(3,2));
  ang(2,2) = sign(ang(1,2))*pi-ang(1,2);
  
  % rotation angle around y axis => last column of 'ang'
  ang(1,3) = atan2(matR(3,1)/cos(ang(1,2)),matR(3,3)/cos(ang(1,2)));
  ang(2,3) = atan2(matR(3,1)/cos(ang(2,2)),matR(3,3)/cos(ang(2,2)));

  % rotation angle around z axis => 1st column of 'ang'
  ang(1,1) = atan2(matR(1,2)/cos(ang(1,2)),matR(2,2)/cos(ang(1,2)));
  ang(2,1) = atan2(matR(1,2)/cos(ang(2,2)),matR(2,2)/cos(ang(2,2))); 
  
else
   
  ang(1) = roll;
  
  if (matR(3,2)==1)
    ang(2) = -pi/2;
    ang(3) = atan2(-matR(1,3),-matR(2,3))-ang(1);
    if (ang(3)>pi)
      ang(3) = ang(3)-2*pi;
    elseif (ang(3)<-pi)
      ang(3) = ang(3)+2*pi;
    end    
  else
    ang(2) = pi/2;
    ang(3) = ang(1)-atan2(matR(1,3),matR(2,3));  
    if (ang(3)>pi)
      ang(3) = ang(3)-2*pi;
    elseif (ang(3)<-pi)
      ang(3) = ang(3)+2*pi;
    end        
  end  
end

ang = ang';

return;
end

function [R]=ang2rot(ang);
% fct ang2rot : codage d'une rotation 3D par 3 angles
%
% forme d'appel
%    R=ang2rot(ang);
% Entree
% - ang : angles des rotations autour de z,x,y
% Sortie
% - R : matrice 3x3 de rotation
%
% NB : codage Euler d'une rotation en zxy
%
% ONERA/DTIM

Rz =  [cos(ang(1)) sin(ang(1)) 0;
    -sin(ang(1)) cos(ang(1)) 0;
    0 0 1];

Rx = [1 0 0;
    0 cos(ang(2)) sin(ang(2));
    0 -sin(ang(2)) cos(ang(2))];

Ry =  [cos(ang(3)) 0 -sin(ang(3));
    0 1 0;
    sin(ang(3)) 0 cos(ang(3))];

R = Rz*Rx*Ry;
return;
end

function [angfin, Tfin] = affinageRT(anginit, Tinit, matK, pos3D, pos2D);
% affinageRT : affine rotation et translation par minimisation
%              de l'erreur de reprojection dans les images
%
% forme d'appel
% [angfin, Tfin] = affinageRT(anginit, Tinit, matK, pos3D, pos2D);
% - anginit : vecteur 3x1 des angles de la rotation camera
% - Tinit: vecteur 3x1 de la translation camera
% - matK   : parametres intrinseques de la camera
% - pos3D  : positions 3D des points dans repere monde (tableau Nx3)
% - pos2D  : positions 2D des points dans repere camera (tableau Nx3)
%
%

[nbPts,aux]=size(pos3D);
[nbPts2,aux]=size(pos2D);
if (nbPts~=nbPts2)
    disp('erreur de dimensions');
    return;
end


% residu image : on a un peu perdu avec la projection sur une rotation
Rinit=ang2rot(anginit);
Mproj3 = Rinit*pos3D' - repmat(Rinit*Tinit,[1,nbPts]);
aux = matK*Mproj3;
mproj3 = aux(1:2,:)./repmat(aux(3,:),[2,1]);
mproj3=mproj3';
residu3 = double(mproj3(:))-double(pos2D(:));
fprintf(1,'RMS de l''erreur de projection initiale %f\n',sqrt(mean(residu3(:).^2)))

% ===== optimisation
dinit=[Tinit(:);anginit(:)];
resinit=eval_fct_proj_ck(dinit,pos2D',pos3D',matK);
critinit=sum(resinit(:).^2)

f = @(d)eval_fct_proj_ck(d,pos2D',pos3D',matK);
mes_options = optimoptions(@lsqnonlin,'display','iter');
dfin = lsqnonlin(f,dinit,[],[],mes_options);
resfin=eval_fct_proj_ck(dfin,pos2D',pos3D',matK);
critfin=sum(resfin.^2)

Tfin=dfin(1:3);
angfin=dfin(4:6);

% residu image final
Rfin=ang2rot(angfin);
Mproj4 = Rfin*pos3D' - repmat(Rfin*Tfin,[1,nbPts]);
aux = matK*Mproj4;
mproj4 = aux(1:2,:)./repmat(aux(3,:),[2,1]);
mproj4=mproj4';
residu4 = double(mproj4(:))-double(pos2D(:));
fprintf(1,'RMS de l''erreur de projection apres opti %f\n',sqrt(mean(residu4(:).^2)))

end

function [ res,x ] = eval_fct_proj_ck( d,xref,X,K )
% eval_fct_proj : evaluation de la fonction de projection
%
% forme d'appel
% [res,x] = eval_fct_proj(d, xref, X, K);
%
% Entrees :
% - d : parametres de deplact de la camera d = [T;ang] (dim 6x1)
% - xref : positions 2D de reference pour le calcul des residus (dim 2xN)
% - X : position 3D des pts a projeter (dim 3xN)
% - K : matrice intrinseque
%
% Sortie
% - res : vecteur des residus entre xref et la projection de X mis en 
%         une seule colonne (dim 2N x 1)
% - x : position 2D (en pixels) des points image obtenus par projection
%       de X (dim 2xN) 
%
% NB : cette fonction fait appel a fct_proj.m

[x] = fct_proj_ck(d,X,K);
res = x-xref;
res=res(:);


end

function [ x ] = fct_proj_ck( d,X,K )
% fct_proj : fonction de projection 3D -> 2D
%
% forme d'appel
% [x] = fct_proj(d, X, K);
%
% Entrees :
% - d : parametres de deplact de la camera d = [T;ang] (dim 6x1)
% - X : position 3D des pts a projeter (dim 3xN)
% - K : matrice intrinseque
%
% Sortie
% - x : position 2D (en pixels) des points image obtenus par projection
%       de X (dim 2xN) 
%

alx=K(1,1);
aly=K(2,2);
x0=K(1,3);
y0=K(2,3);

R=ang2rot(d(4:end));
T=d(1:3);

D=R*(X-repmat(T,1,size(X,2)));
%D=R*X + repmat(T,1,size(X,2));
x1 = alx*D(1,:)./D(3,:)+x0;
y1 = aly*D(2,:)./D(3,:)+y0;

x=[x1;y1];

end


