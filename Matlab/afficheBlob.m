function [] = afficheBlob(I,blob, titre)
%I image de fond
%blob : cellarray de coordonnées de point dans un blob
%title : titre du graphique
figure()

N = numel(blob);
colors = hsv(N);

imshow(I, []);
hold on;

for i = 1:N
    coord = blob{i};
    [y, x] = ind2sub(size(I), coord);
    plot(x, y, '.', ...
        'Color', colors(i,:), ...
        'MarkerSize', 8);
end

title(titre);
hold off;

hold off;

end