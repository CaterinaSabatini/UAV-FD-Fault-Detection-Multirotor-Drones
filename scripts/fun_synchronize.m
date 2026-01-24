clear; clc;

%% SETUP PERCORSI
script_folder = fileparts(mfilename('fullpath'));
project_folder = fileparts(script_folder);
raw_data_folder = fullfile(project_folder, 'raw_data');

% Creazione cartella di output nel caso in cui non esista
output_folder = fullfile(project_folder, 'synchronized_data');

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
    fprintf('Cartella creata: %s\n', output_folder);
else
    fprintf('Cartella di output già esistente.\n');
end

%% TROVA TUTTI I FILE .MAT
file_list = dir(fullfile(raw_data_folder, '*.mat'));
n_files = length(file_list);

fprintf('\n=== SINCRONIZZAZIONE BATCH ===\n');
fprintf('Trovati %d file\n\n', n_files);

%% PROCESSA TUTTI I FILE
for i = 1:n_files
    filename = file_list(i).name;
    input_path = fullfile(raw_data_folder, filename);
    
    fprintf('[%2d/%2d] Processando: %s ... ', i, n_files, filename);
    
    % CHIAMA LA FUNZIONE
    Data = synchronizer(input_path, 350);
    
    fprintf('File salvato correttamente\n');
end

fprintf('\n=== COMPLETATO ===\n');
fprintf('Tutti i %d file sono stati sincronizzati\n\n', n_files);