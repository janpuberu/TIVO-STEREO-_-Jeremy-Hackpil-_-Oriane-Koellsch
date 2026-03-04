function [] = createGIF(I1,I2, filename)
    
    %  crée un GIF à partir de deux images 2D (grayscale)
    %   I1, I2 : images 2D (grayscale)
    %   filename : nom du GIF à sauvegarder
    
    images = {I1, I2};
    delayTime = 0.5;  % temps entre les frames
    
    for k = 1:numel(images)
        img = images{k};
    
        % Normaliser l'image en [0,1] si ce n'est pas déjà
        if ~isfloat(img)
            img = im2double(img);
        end
        img = mat2gray(img);  % assure que toutes les valeurs sont entre 0 et 1
    
        % Convertir en image indexée pour GIF (256 niveaux de gris)
        [A, map] = gray2ind(img, 256);
    
        % Écrire dans le GIF
        if k == 1
            imwrite(A, map, filename, 'gif', 'LoopCount', Inf, 'DelayTime', delayTime);
        else
            imwrite(A, map, filename, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
        end
    end
    end