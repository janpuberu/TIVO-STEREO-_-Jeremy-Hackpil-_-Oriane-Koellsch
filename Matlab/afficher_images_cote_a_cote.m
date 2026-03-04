function afficher_images_cote_a_cote(img1, img2, titre_fenetre)
% AFFICHER_IMAGES_COTE_A_COTE Affiche deux images côte à côte
%   afficher_images_cote_a_cote(img1, img2)
%   afficher_images_cote_a_cote(img1, img2, titre_fenetre)
%   img1 : image à afficher à gauche
%   img2 : image à afficher à droite
%   titre_fenetre : titre optionnel de la fenêtre

    % Créer une nouvelle figure
    figure;
    
    % Définir un titre par défaut si non spécifié
    if nargin < 3
        titre_fenetre = 'Images côte à côte';
    end
    
    % Afficher l'image de gauche
    subplot(1, 2, 1);
    imshow(img1);
    title('Image gauche', 'FontSize', 12);
    axis image;
    
    % Afficher l'image de droite
    subplot(1, 2, 2);
    imshow(img2);
    title('Image droite', 'FontSize', 12);
    axis image;
    
    % Ajouter un titre principal
    sgtitle(titre_fenetre, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Ajuster l'espacement entre les sous-graphiques
    set(gcf, 'Position', [100, 100, 1200, 500]);
end