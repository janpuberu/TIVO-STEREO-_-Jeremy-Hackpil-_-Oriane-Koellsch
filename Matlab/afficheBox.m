function [] = afficheBox(I, bbox2D, z_mean)
% Affiche les bounding boxes 2D et écrit z_mean sur chaque blob
%
%   I       : image 2D
%   bbox2D  : cellule de bounding boxes 2D, chaque cellule = [xmin xmax; ymin ymax]
%   z_mean  : cellule contenant la valeur moyenne Z de chaque blob

    figure;
    imshow(I, []);
    hold on;

    for k = 1:numel(bbox2D)
        box = bbox2D{k};

        % ignorer les cellules vides
        if isempty(box)
            continue;
        end

        % récupérer les limites
        Xmin = box(1,1); Xmax = box(1,2);
        Ymin = box(2,1); Ymax = box(2,2);

        % tracer le rectangle : [x y width height]
        rectangle('Position', [Xmin, Ymin, Xmax-Xmin+1, Ymax-Ymin+1], ...
                  'EdgeColor', 'r', 'LineWidth', 1.5);

        % afficher z_mean au-dessus du rectangle
        if ~isempty(z_mean) && numel(z_mean) >= k && ~isempty(z_mean{k})
            text(Xmin, Ymin-2, sprintf('z = %.2f m', z_mean{k}), ...
                 'Color', 'yellow', 'FontSize', 10, 'FontWeight', 'bold');
        end
    end

    title('Bounding boxes 2D des blobs avec z_{mean}');
    hold off;
end