function P = ProdMat(A,x,y,z)
%  Produit entre une matrice 3x3 A et un vecteur colonne de dimension 3 B=[x;y;z] 
%  dont chaque terme est une matrice de dimension nxm. 
%Sortie : produit matriciel entre A et entre chaque coord de B


X=(x.*A(1,1)+y.*A(1,2)+z.*A(1,3));
Y=(x.*A(2,1)+y.*A(2,2)+z.*A(2,3));
Z=(x.*A(3,1)+y.*A(3,2)+z.*A(3,3));

P = [X; Y; Z];
end