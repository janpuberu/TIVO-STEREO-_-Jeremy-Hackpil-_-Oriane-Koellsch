function [img1, img2] = charger_images_gris(chemin1, chemin2)
% CHARGER_IMAGES_GRIS Charge deux images et les convertit en niveaux de gris
%   [img1, img2] = charger_images_gris(chemin1, chemin2)
%   chemin1 : chemin vers la première image
%   chemin2 : chemin vers la deuxième image
%   img1, img2 : images en niveaux de gris

    % Charger la première image
    if exist(chemin1, 'file')
        img1_orig = imread(chemin1);
    else
        error('Fichier non trouvé : %s', chemin1);
    end
    
    % Charger la deuxième image
    if exist(chemin2, 'file')
        img2_orig = imread(chemin2);
    else
        error('Fichier non trouvé : %s', chemin2);
    end
    
    % Convertir en niveaux de gris
    if size(img1_orig, 3) == 3
        img1 = rgb2gray(img1_orig);
    else
        img1 = img1_orig;
    end
    
    if size(img2_orig, 3) == 3
        img2 = rgb2gray(img2_orig);
    else
        img2 = img2_orig;
    end
end