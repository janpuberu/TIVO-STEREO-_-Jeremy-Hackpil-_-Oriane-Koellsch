function [u v] = eFolki(I0, I1, para)
% eFolki ---- optical flow computation by dense LK
% AP, GLB, FC --- ONERA/DTIM --- 2003-2015
%
% [u,v] = eFolki(I1,I2,[params]);
% I1,I2  :  input images
% u,v    :  output horizontal, vertical flow component
% params :  optional parameters structure (default value)
% params.radius = radius of block (5)
% params.levels = nb of pyramid levels (5)
% params.iter = nb of iteration per levels (3)
% params. bord = size of margin (0)
% params.census = radius of census filter (4)
% 

