% Main.m
clear all; close all; clc;

% 1. Ajouter le dossier où se trouve charger_images_gris au chemin
chemin_fonctions = '\\domain.iogs\ESO\Home\jeremy.hackpil\Documents\STEREO\V\Projet_stereo_2026\Matlab';
addpath(chemin_fonctions);

% 2. Vérifier que la fonction est maintenant disponible
if exist('charger_images_gris', 'file')
    fprintf('✓ Fonction charger_images_gris disponible\n');
else
    error('Fonction charger_images_gris non trouvée');
end

% 3. Vérifier aussi l'autre fonction
if exist('afficher_images_cote_a_cote', 'file')
    fprintf('✓ Fonction afficher_images_cote_a_cote disponible\n');
else
    warning('Fonction afficher_images_cote_a_cote non trouvée');
end

% 5. Charger et afficher
chemin_relatifL2 = './cam00/0000000004.png';%'./cam00/0000000004.png';0000004011
chemin_relatifR2 = './cam01/0000000004.png';
[L2, R2] = charger_images_gris(chemin_relatifL2, chemin_relatifR2);


chemin_relatifL1 = './cam00/0000000003.png';
chemin_relatifR1 = './cam01/0000000003.png';
[L1, R1] = charger_images_gris(chemin_relatifL1, chemin_relatifR1);

%cliX11(L1,L2)
% 8. Paramtres du banc Stéréo

a = loadCalibrationCamToCam("./Calibration_data/calib_cam_to_cam.txt")
% Méthode directe - Extraire K00 et K10
fprintf('\n=== EXTRACTION DIRECTE ===\n');

% K00 matrice intrinseque du banc stereo
K00 = a.P_rect{1}(:,1:3);

fprintf('Matrice K00 (caméra 0) :\n');
disp(K00);


% T01 translation entre caméra gauche et camera droite
T01 = a.T{2};

fprintf('T01 (caméra 0 a 1) :\n');
disp(T01);

% Baseline 
Baseline = norm(T01)
fprintf('Baseline (m) :\n');
disp(Baseline);

% 7. Calcul d'odometrie
[R,T,P,map3D] = odoStereo(L2,R2,L1,K00,Baseline,30,1);


%8 Dense Disparity Using SGM on L2 R2 (Zmax = 40)
Zmax=40;
fpix=K00(1,1);
dmin=floor(fpix*Baseline/Zmax);
disparityRange = [dmin dmin+128];
disparityMap = disparitySGM(L2,R2,'DisparityRange',disparityRange);


figure
imshow(disparityMap,disparityRange)
title("Disparity Map")
colormap jet
colorbar


Z_3D = (fpix * Baseline) ./ disparityMap;
Z_3D(disparityMap == 0) = NaN; % Éliminer les points invalide


%filtre sur la hauteur
Hcam=1.65;
Hmax=2.5;
[X, Y] = meshgrid(1:size(Z_3D,2), 1:size(Z_3D,1));

valid_high=Hcam +Baseline*(K00(2,3)-Y)./disparityMap <Hmax ;

Z_3D(valid_high==0) = NaN;

figure
imshow(Z_3D, [0,40])
title("Carte de profondeur")
colormap jet
colorbar

%% 
% Passage du repere pixel au repert monde (lambda * K * Xt =  (xpix, ypix, 1) ),
% lambda^-1=Z_3D

% Création des coordonnées pixels
[rows, cols] = size(Z_3D);
[x_pix, y_pix] = meshgrid(1:cols, 1:rows);

K_inv=inv(K00);

%on verifie que Z_verif vaut bien la meme chose que Z_3D 

coord_pix = [x_pix(:), y_pix(:), ones(rows*cols, 1)]';
coord_3D = K_inv * coord_pix;
coord_3D = coord_3D .* reshape(Z_3D, [1, rows*cols]);
X_3D = reshape(coord_3D(1,:), [rows, cols]);
Y_3D = reshape(coord_3D(2,:), [rows, cols]);
Z_verif = reshape(coord_3D(3,:), [rows, cols]);

% 4. Afficher le nuage de points 3D
figure
scatter3(X_3D(:), Y_3D(:), Z_3D(:), 1, Z_3D(:))
title('Nuage de points 3D à t')
xlabel('X')
ylabel('Y')
zlabel('Profondeur (m)')
colormap jet
colorbar
view(3)

%% Passage de 3D(t) à 3D(t-1)t-1 avec les matrices R(t-1,t) et T(t-1,t) : X_{t-1}=R(X_t -T)

coords_3D_t_1 = [X_3D(:)-T(1),Y_3D(:)-T(2),Z_3D(:)-T(3)]';
coords_3D_t_1 = R * coords_3D_t_1;
X_3D_t_1 = reshape(coords_3D_t_1(1,:), [rows,cols]);
Y_3D_t_1 = reshape(coords_3D_t_1(2,:), [rows,cols]);
Z_3D_t_1 = reshape(coords_3D_t_1(3,:), [rows,cols]);


% Coord 3D_t-1 reel (pour comparer)

Zmax=40;
fpix=K00(1,1);
dmin=floor(fpix*Baseline/Zmax);
disparityRange = [dmin dmin+128];
disparityMap = disparitySGM(L1,R1,'DisparityRange',disparityRange);


Z_3D_t_1_reel = (fpix * Baseline) ./ disparityMap;
Z_3D_t_1_reel(disparityMap == 0) = NaN; % Éliminer les points invalide

[rows, cols] = size(Z_3D_t_1_reel);
[x_pix, y_pix] = meshgrid(1:cols, 1:rows);

K_inv=inv(K00);

coord_pix = [x_pix(:), y_pix(:), ones(rows*cols, 1)]';
coord_3D = K_inv * coord_pix;
coord_3D = coord_3D .* reshape(Z_3D, [1, rows*cols]);
X_3D_t_1_reel = reshape(coord_3D(1,:), [rows, cols]);
Y_3D_t_1_reel = reshape(coord_3D(2,:), [rows, cols]);
Z_verif = reshape(coord_3D(3,:), [rows, cols]);



% 4. Afficher le nuage de points 3D
figure
scatter3(X_3D_t_1(:), Y_3D_t_1(:), Z_3D_t_1(:), 1, Z_3D_t_1(:), "red")
hold on
scatter3(X_3D_t_1_reel(:),Y_3D_t_1_reel(:), Z_3D_t_1_reel(:), 1, Z_3D_t_1_reel(:), "blue")
title('Nuage de points 3D à t-1 predit')
xlabel('X')
ylabel('Y')
legend('t-1 prédit','t-1 réel')
zlabel('Profondeur (m)')
colormap jet
colorbar
view(3)


%% Projection sur l'image en t-1, prédite sans mouvement

coords_2D_t_1=K00*coords_3D_t_1;
lambda=[coords_2D_t_1(3,:);coords_2D_t_1(3,:);coords_2D_t_1(3,:)];
coords_2D_t_1=coords_2D_t_1./(lambda);

x_pix_t_1 = reshape(coords_2D_t_1(1,:), [rows,cols]);
y_pix_t_1 = reshape(coords_2D_t_1(2,:), [rows,cols]);

[X, Y] = meshgrid(1:size(Z_3D,2), 1:size(Z_3D,1));

L1_double = double(L1);

L2_pred=interp2(X,Y,L1_double,x_pix_t_1,y_pix_t_1);
L2_pred(isnan(L2_pred))=L2(isnan(L2_pred));
cliX11(L2,L2_pred)




%% detection de flot optique entre l'image et l'image prédite
L2_pred=double(L2_pred);
L2=double(L2);

[u,v]=eFolki(L2_pred, L2);
afficheFlot(L2_pred,L2,u,v);


%%

M=[u(:)  v(:)]';
%SigmaM=eye(size(M,2)); matrice de convariance de M, pour le moment prise comme l'identité, en realité : matrice diagonal par bloc des matrice de covariance de M en chaque point
%d_maha2=diag(M'*inv(SigmaM)*M); %distance de Mahalanobis

%on décompose car trop lourd pour matlab

d_maha2=u.^2+v.^2; %pdist


imagesc(d_maha2)
title("distance de Mahalanobis")


%% 

seuil_d=11; 
seuil_area=0.01; %en m2, aire minimale des blobs
seuil_dmin=0.3; %en m, distance 3D en dessous de laquelle les blobs sont fusionnées
seuil_area2=0.16; %en m2, aire minimale des blobs fusionné


inmouv=d_maha2>seuil_d;
connex_part=bwconncomp(inmouv);

connex_part_pix=connex_part.PixelIdxList;

afficheBlob(L2, connex_part_pix, "Blobs connexes détectés")

%premier filtre sur l'aire des blob
filteredblob = {}; %on utilise un cell car on connais pas le nb final de blob
k = 1;
for i = 1:size(connex_part_pix, 2)

    coord  = connex_part_pix{i};   
  

    d_mean = mean(disparityMap(coord), 'omitnan');

    if ~isnan(d_mean)
        area = size(coord,1)*size(coord,2) * Baseline^2 / d_mean^2;
        if area >= seuil_area
            filteredblob{k} = coord;
            k = k + 1;
        end
    end
end


afficheBlob(L2, filteredblob, "Blobs détectés après filtrage de l'aire")


fusion=1:size(filteredblob, 2);

%fusion des blobs proches en 3D
for i = 1:size(filteredblob, 2)-1
    coord1  = filteredblob{i};
    for j=i+1:size(filteredblob, 2)
        coord2  = filteredblob{j};
        P1= [X_3D(coord1), Y_3D(coord1), Z_3D(coord1)];
        P2= [X_3D(coord2), Y_3D(coord2), Z_3D(coord2)];

        D = sqrt((P1(:,1) - P2(:,1)').^2 + ...
            (P1(:,2) - P2(:,2)').^2 + ...
            (P1(:,3) - P2(:,3)').^2 );
        
        d_min = min(D(:));
        dmin = min(D(:));

        if dmin<seuil_dmin
            fusion(j)=fusion(i);

        end
    end
end

fusionedblob={};

k = 1;
for i = 1:size(filteredblob, 2)
    idx = find(fusion == i);
    if size(idx)>0
        coord=[];
       for j=idx
        coord=vertcat(coord, filteredblob{j});

       end
       fusionedblob{k} = coord;
       k = k + 1;

    end


end

afficheBlob(L2, fusionedblob, "Blobs détectés après filtrage de l'aire et fusionnés lorsque proches")

%suppressier des blobs fusionnée en fonction de la somme des aire de chaque
%pixel
filteredblob = {}; %on utilise un cell car on connais pas le nb final de blob
k = 1;
area = Baseline^2 ./ disparityMap.^2;
area(isnan(area))=0;

for i = 1:size(fusionedblob, 2)

    coord  = fusionedblob{i};   
    
    area_blob=sum((area(coord)));


    if area_blob >= seuil_area2
        
        filteredblob{k} = coord;
        k = k + 1;
    end
    
end


afficheBlob(L2, filteredblob, "Blobs détectés après filtrage de l'aire sur les blocs fusionnés")
%% calcul de la profondeur moyenne de chaque objet en mouvmeent detecté et affichage final
bbox = {};
z_mean={};

for i = 1:size(filteredblob, 2) 
    
    coord  = filteredblob{i};  
    [rows, cols] = ind2sub(size(L2), coord);


    xmin = min(cols); xmax = max(cols);
    ymin = min(rows); ymax = max(rows);

    bbox{k} = [xmin xmax; ymin ymax];
    z_mean{k}=mean(Z_3D(coord(~isnan(Z_3D(coord)) )));
    k = k + 1;
    
end

afficheBox(L2,bbox, z_mean)









































