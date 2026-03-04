% Script_diagnostic.m
clear all; close all; clc;

fprintf('=== DIAGNOSTIC DU PROBLÈME ===\n\n');

% 1. Afficher le dossier courant
dossier_courant = pwd;
fprintf('1. Dossier courant MATLAB : %s\n\n', dossier_courant);

% 2. Vérifier la structure
fprintf('2. Contenu du dossier courant :\n');
dir

% 3. Chemin que vous essayez d'accéder
chemin_test1 = './cam00/0000000001.png';
chemin_test2 = './cam01/0000000001.png';

fprintf('\n3. Chemins testés :\n');
fprintf('   - %s\n', chemin_test1);
fprintf('   - %s\n', chemin_test2);

% 4. Vérifier existence des dossiers
fprintf('\n4. Vérification des dossiers :\n');
if exist('./cam00', 'dir')
    fprintf('   ✓ Dossier ./cam00 existe\n');
    fprintf('     Contenu de cam00 :\n');
    dir('./cam00')
else
    fprintf('   ✗ Dossier ./cam00 N''EXISTE PAS\n');
end

fprintf('\n');
if exist('./cam01', 'dir')
    fprintf('   ✓ Dossier ./cam01 existe\n');
    fprintf('     Contenu de cam01 :\n');
    dir('./cam01')
else
    fprintf('   ✗ Dossier ./cam01 N''EXISTE PAS\n');
end

% 5. Vérifier existence des fichiers spécifiques
fprintf('\n5. Vérification des fichiers :\n');
if exist(chemin_test1, 'file')
    fprintf('   ✓ Fichier trouvé : %s\n', chemin_test1);
else
    fprintf('   ✗ Fichier NON TROUVÉ : %s\n', chemin_test1);
    fprintf('     Chemin absolu : %s\n', fullfile(pwd, 'cam00', '0000000001.png'));
end

if exist(chemin_test2, 'file')
    fprintf('   ✓ Fichier trouvé : %s\n', chemin_test2);
else
    fprintf('   ✗ Fichier NON TROUVÉ : %s\n', chemin_test2);
    fprintf('     Chemin absolu : %s\n', fullfile(pwd, 'cam01', '0000000001.png'));
end

% 6. Suggestions
fprintf('\n6. SUGGESTIONS :\n');
if ~exist('./cam00', 'dir')
    fprintf('   → Créer le dossier cam00 avec : mkdir(''cam00'')\n');
end
if ~exist('./cam01', 'dir')
    fprintf('   → Créer le dossier cam01 avec : mkdir(''cam01'')\n');
end
fprintf('   → Vérifier que les images sont dans les bons dossiers\n');
fprintf('   → Changer le dossier courant avec : cd(''chemin/vers/votre/projet'')\n');