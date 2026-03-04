function L2_pred=Interpolation(L2,L1,x1,y1)
%Cette foncton crée une nouvelle image avec les valeures de L1 aux coord x1 et
%y1 interpolées lorsqu'elles existent et les valeures de L2 lorsque x1 et y1
%vallent NaN

L2_pred=zeros(size(L2));
[X, Y] = meshgrid(1:size(L1,2), 1:size(L1,1));
for i=1:size(x1,1)
    for j=1:size(x1,2)
        if or(isnan(x1(i,j)), isnan(y1(i,j)))
            L2_pred(i,j)=L2(i,j);
        else
            L2_pred(i,j)=interp2(X,Y,L1,x1(i,j),y1(i,j));
                       
        end
    end
end

end
