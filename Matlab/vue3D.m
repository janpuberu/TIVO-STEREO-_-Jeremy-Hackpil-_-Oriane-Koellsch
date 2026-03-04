function [] = vue3D(numFig,pts3D,matK,sizeim,pose,camColor,operation);
% fct vue3D - affichage 3D d'un nuage de points et d'une camera
%
% forme d'appel
% vue3D(numFig,pos3D,matK,sizeim,pose,camColor,operation);
%
% - numFig : numero de figure pour l'affichage
% - pts3D  : positions 3D des points dans repere monde (tableau 3xN)
% - matK   : parametres intrinseques de la camera
% - sizeim : tailles image (ie. [nl,nc])
% - pose : parametre donnant la pose (angle et translation) de la camera
%          dans le repere monde
%   2 formes : vecteur 6x1 contenant [angle; translation] ou
%              matrice de projection en camera normalisee Pn (3x4)
% - position : position centre optique camera dans repere monde
% - camColor : couleur affichage camera ('red', 'blue', 'green', etc.)
% - operation : type d'affichage voulu
%       operation = 'create' : premier affichage d'une scene + camera
%       operation = 'addcam' : ajout d'une camera a une scene existante
%       operation = 'addpts' : ajout de points 3D a une scene existante
% 
% GLB/MS --- ONERA/DTIM --- 2015

% seuil pour elimination des points 3D trop loins
seuil_dist=30;

if (length(numFig) == 0) || (length(numFig) > 1)
    disp('Le premier parametre doit etre un numero de figure');
    return;
end

if (nargin ~= 7)
    disp('erreur de syntaxe, cf. help vue3D');
    return;
end

if (size(pts3D,1) > 3)
    pts3D=pts3D';
    disp('warning : le tableau pts3D doit etre 3xN');
end

if (size(pose,1)==6 & size(pose,2)==1)
    attitude = pose(1:3);
    position = pose( 4:6);
else
    if (size(pose,1)==3 & size(pose,2)==4)
        tensP=pose;
        position = [];
    else
        disp('dimensions mvt non conformes');
    end
end

params.numfig = numFig;
params.tail = 1;
params.pt3DStyle = 'b.';
params.camColor = camColor;
if (strcmp(operation,'create'))
    params.holdon = 0;
else
    params.holdon = 1;
end
params.camWidth = 1;
params.Xaxis = [];
params.Yaxis = [];
params.Zaxis = [];

nb=size(pts3D,2);
if length(position)==0
    vec=pts3D-repmat(tensP(:,4),1,nb);
    dist=sqrt(diag(vec'*vec));
else
    Rloc = f_utils_euler2rot(attitude(:),'zxy');
    tensP=[Rloc,-Rloc*position(:)]; % pour calcul de traj relative a cam1
    %tensP=[Rloc,position(:)];
    vec=pts3D-repmat(position(:),1,nb);
    dist=sqrt(diag(vec'*vec));
end

% suppression des points trop loin
if (length(find((dist>=seuil_dist))))
    fprintf(1,'Out of range points deleted (max range=%d m)\n',seuil_dist);
end
indOK=find(dist<seuil_dist);

pIntra=[matK(1,1);matK(2,2);...
    matK(1,3);matK(2,3)];
imasize=fliplr(sizeim);

if (strcmp(operation,'addpts'))
    params.pt3DStyle = 'r.';
    f_utils_displayScene(pts3D(:,indOK),[],pIntra,imasize,params);
elseif (strcmp(operation,'addcam'))
    f_utils_displayScene([],tensP,pIntra,imasize,params);
else
    f_utils_displayScene(pts3D(:,indOK),tensP,pIntra,imasize,params);
end

function f_utils_displayScene(tabPos3D,tensP,pIntra,imasize,params);
%
% Syntax :
%
%         f_utils_displayScene(tabPos3D,tensP,pIntra,imasize,params)
%
% Overview :
%
%         Display on a 3D plot cameras and reconstructed 3D points.
%         Camera are displayed as a cone whom overture is representative
%         of the intrinsic parameters.
%
% Inputs : 
%
%         tabPos3D = array containing the 3D-points for displaying (array [3,NbPts])
%         tensP    = array containing rotation matrix and position such as
%                    tensP(:,:,k) = [R(k) T(k)] and Xcam(k) = R(k)Xworld + T(k).
%                    (array [3,4,nbCam]);
%         pIntra   = Intrinsic parameters (array [4,NbCam] ou vector [4,1])
%                    if an array is given to the function, the program suppose
%                    that the field of view is varying.
%                    parameter order : [alphaU;alphaV;u0;v0]
%         imasize  = Image size (vector [1,2] or [2,1] order : nbcol,nbrow)
%         params   = structure containing some plot properties
%                    xxxx.numfig   = figure number (by default :100)
%                    xxxx.tail     = cone height (by default : 2 meters)
%                    xxx.pt3DStyle = string uses in plot3 (by default : 'b.');
%                    xxx.holdon    = if non zero, don't reinitialize the figure (default : 0)
%                    xxx.camColor  = color of the line symbolizing the camera (default : 'black');
%                    xxx.camWidth  = width of the line used to render cameras
%                    xxx.Xaxis     = Limits on X axis;
%                    xxx.Yaxis     = Limits on Y axis;
%                    xxx.Zaxis     = Limits on Z axis;
%
% History
%
%         March 2004   -  First Release (by Guy)
%         6 Sept 2007  +  Some improvements
%         7 sept 2007  +  Add 'holdon' and 'camColor' field to "params" strucutre
%        12 sept 2007  +  Bug correction : if params was not given, holdon was not initialized
%                                          idem for camColor
%        09 nov  2007  +  Add camWidth field 
%                         I've forgotten to initialize axis if params was not given
%        ??  ??  ??    +  Can be used to display 3Dpoint only, camera only or both
%
%===================================================================================================
% MS - ONERA/DTIM/IED -                                                                    - Sept07
%

if ~isempty(pIntra)
  if size(pIntra,2)~=1,
    if size(pIntra,2)~=size(tensP,3),
      disp('!!ERROR!!(f_utils_displayScene) Number of intrinsic vectors is different of the number of motion tensors');
      return;
    end
  end
end


% Check params structure
% 

if (nargin<5) || (nargin==5 && isempty(params)),  
  params.numfig = 100;
  params.tail = 2;
  params.pt3DStyle = 'b.';
  params.holdon = 0;
  params.camColor = 'black';    
  params.camWidth = 1;
  params.Xaxis = [];
  params.Yaxis = [];
  params.Zaxis = []; 
else
  if ~isfield(params,'numfig') 
    params.numfig = 100;
  end
  if ~isfield(params,'tail')
    params.tail = 2;
  end
  if ~isfield(params,'pt3DStyle')
    params.pt3DStyle = 'b.';
  end
  if ~isfield(params,'holdon')
    params.holdon = 0;       
  end
  if ~isfield(params,'camColor')
    params.camColor = 'black';       
  end    
  if ~isfield(params,'camWidth')
    params.camWidth = 1;       
  end  
  if ~isfield(params,'Xaxis')
    params.Xaxis = [];
  end
  if ~isfield(params,'Yaxis')
    params.Yaxis = [];
  end
  if ~isfield(params,'Zaxis')
    params.Zaxis = [];
  end  
end

% Check Intrinsic parameters
%
if nargin==2,
  
  imasize = [640,480];
  ratio = imasize(2)/imasize(1);
  pIntra(3) = imasize(1)/2;
  pIntra(4) = imasize(2)/2;
  pIntra(1) = pIntra(3)/tan(20*pi/180);
  pIntra(2) = pIntra(4)/tan(ratio*20*pi/180);	
  FLAG_VARIABLEFOV = 0;  
  
elseif nargin>=3,
  
  if isempty(pIntra)
    pIntra = zeros(4);
    if (exist('imasize') && isempty(imasize)) || (~exist('imasize'))
      imasize = [640,480];
    end
    ratio = imasize(2)/imasize(1);
    pIntra(3) = imasize(1)/2;
    pIntra(4) = imasize(2)/2;
    pIntra(1) = pIntra(3)/tan(20*pi/180);
    pIntra(2) = pIntra(4)/tan(ratio*20*pi/180);	
    FLAG_VARIABLEFOV = 0;
  elseif size(pIntra,2)==1,
    FLAG_VARIABLEFOV = 0;
  else
    FLAG_VARIABLEFOV = 1;
  end
end

%
% Display 3Dpoints cloud
%
figure(params.numfig);
hold on;
if params.holdon==0,
  hold off;
  clf;
end

if ~isempty(tabPos3D),
   
  plot3(tabPos3D(1,:),tabPos3D(2,:),tabPos3D(3,:),params.pt3DStyle);
  
else
  
  disp(' No 3D model given. Camera displaying only !');
  
end

%
% Define the conic vertices coordinates (in the camera frame)
%

nbCam = size(tensP,3);

if ~isempty(tensP)

  if ~FLAG_VARIABLEFOV
    
    coneVertices = zeros(3,5);
    
    vtmp = [1 imasize(1) imasize(1) 1;...
	    1 1 imasize(2) imasize(2);...
	    1 1 1 1];
    
    matK = [pIntra(1) 0 pIntra(3);...
	    0 pIntra(2) pIntra(4);...
	    0 0 1];
    
    coneVertices(:,[2:5]) = params.tail*inv(matK)*vtmp;
    
    for cptC = 1 : nbCam,
      
      currentTensP = squeeze(tensP(:,:,cptC));    
      cVWorld = currentTensP(:,1:3)'*(coneVertices-repmat(currentTensP(:,4),1,5));
      
      figure(params.numfig)
      hold on;
      
      line([cVWorld(1,1);cVWorld(1,2)],[cVWorld(2,1);cVWorld(2,2)],[cVWorld(3,1);cVWorld(3,2)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,1);cVWorld(1,3)],[cVWorld(2,1);cVWorld(2,3)],[cVWorld(3,1);cVWorld(3,3)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,1);cVWorld(1,4)],[cVWorld(2,1);cVWorld(2,4)],[cVWorld(3,1);cVWorld(3,4)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,1);cVWorld(1,5)],[cVWorld(2,1);cVWorld(2,5)],[cVWorld(3,1);cVWorld(3,5)],'color',params.camColor,'LineWidth',params.camWidth)
      
      line([cVWorld(1,2);cVWorld(1,3)],[cVWorld(2,2);cVWorld(2,3)],[cVWorld(3,2);cVWorld(3,3)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,3);cVWorld(1,4)],[cVWorld(2,3);cVWorld(2,4)],[cVWorld(3,3);cVWorld(3,4)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,4);cVWorld(1,5)],[cVWorld(2,4);cVWorld(2,5)],[cVWorld(3,4);cVWorld(3,5)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,5);cVWorld(1,2)],[cVWorld(2,5);cVWorld(2,2)],[cVWorld(3,5);cVWorld(3,2)],'color',params.camColor,'LineWidth',params.camWidth)
      
      hold off
      
    end
    
  else
    
    for cptC = 1 : nbCam,
      
      coneVertices = zeros(3,5);
      
      vtmp = [1 imasize(1) imasize(1) 1;...
	      1 1 imasize(2) imasize(2);...
	      1 1 1 1];
      
      matK = [pIntra(1,cptC) 0 pIntra(3,cptC);...
	      0 pIntra(2,cptC) pIntra(4,cptC);...
	      0 0 1];
      
      coneVertices(:,[2:5]) = params.tail*inv(matK)*vtmp;
      
      currentTensP = squeeze(tensP(:,:,cptC));    
      cVWorld = currentTensP(:,1:3)'*(coneVertices-repmat(currentTensP(:,4),1,5));      
      
      figure(params.numfig)
      hold on;
      line([cVWorld(1,1);cVWorld(1,2)],[cVWorld(2,1);cVWorld(2,2)],[cVWorld(3,1);cVWorld(3,2)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,1);cVWorld(1,3)],[cVWorld(2,1);cVWorld(2,3)],[cVWorld(3,1);cVWorld(3,3)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,1);cVWorld(1,4)],[cVWorld(2,1);cVWorld(2,4)],[cVWorld(3,1);cVWorld(3,4)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,1);cVWorld(1,5)],[cVWorld(2,1);cVWorld(2,5)],[cVWorld(3,1);cVWorld(3,5)],'color',params.camColor,'LineWidth',params.camWidth)
      
      line([cVWorld(1,2);cVWorld(1,3)],[cVWorld(2,2);cVWorld(2,3)],[cVWorld(3,2);cVWorld(3,3)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,3);cVWorld(1,4)],[cVWorld(2,3);cVWorld(2,4)],[cVWorld(3,3);cVWorld(3,4)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,4);cVWorld(1,5)],[cVWorld(2,4);cVWorld(2,5)],[cVWorld(3,4);cVWorld(3,5)],'color',params.camColor,'LineWidth',params.camWidth)
      line([cVWorld(1,5);cVWorld(1,2)],[cVWorld(2,5);cVWorld(2,2)],[cVWorld(3,5);cVWorld(3,2)],'color',params.camColor,'LineWidth',params.camWidth)
      hold off
      
    end
    
  end
  
end

axis('equal')

if ~isempty(params.Xaxis)
  set(gca,'XLim',params.Xaxis);
end

if ~isempty(params.Yaxis)
  set(gca,'YLim',params.Yaxis);
end

if ~isempty(params.Xaxis)
  set(gca,'ZLim',params.Zaxis);
end

if ~isempty(tabPos3D),
  camproj('perspective')
end
grid on

xlabel('X');
ylabel('Y');
zlabel('Z');

function matR = f_utils_euler2rot (angle,eulerOrder)
%
% Syntax :
%
%         matR =  f_utils_euler2rot (angle,eulerOrder)
%
% Overview :
%
%         Generate the rotation matrix from the 3-vector angle
%         using the eulerOrder Euler angle sequence
%
% Input :
% 
%         angle      = angle Euler store in eulerOrder (vector [3,1])
%         eulerOrder = string defining the order of the 3 elementary rotations,
%                      eg. 'xyz' give Rx*Ry*Rz and 
%                      angle(1) = angle for Rx,
%                      angle(2) = angle for Ry,
%                      angle(3) = angle for Rz,
%                      
% Output : 
%
%         matR = rotation matrix
%
% History :
%
%         03 sept 2007 - FirstRelease
%
%===================================================================================================
% MS - ONERA/DTIM/IED -                                                                    - Setp07
%

if nargin==1,
  
  eulerOrder = 'xyz';
  
end


matR = eye(3);
angle = angle(:);
eulerOrder = lower(eulerOrder);

for k = 3:-1:1,
  
  switch eulerOrder(k),
    
   case 'x'
    
    matRElem = [1,0,0;
		0,cos(angle(k)),sin(angle(k));...
		0,-sin(angle(k)),cos(angle(k))];
    matR = matRElem*matR;
    
   case 'y'
    
    matRElem = [cos(angle(k)),0,-sin(angle(k));...
		0,1,0;....
		sin(angle(k)),0,cos(angle(k))];
    matR = matRElem*matR;
    
   case 'z'
    
    matRElem = [cos(angle(k)),sin(angle(k)),0;...
		-sin(angle(k)),cos(angle(k)),0;...
		0,0,1];
    matR = matRElem*matR;    
    
  end
  
end

