%% explore_data.m
% Script per esplorare la struttura dei file .mat del dataset UAV-FD
clear; clc; close all;
%% Carica UN file di esempio
filename = 'data_row\FAULT_M1_5.mat';
fprintf('Caricamento file: %s\n', filename);
load(filename);
%% Visualizza tutti i campi disponibili
fprintf('\n=== VARIABILI DISPONIBILI NEL FILE ===\n');
% Ottieni lista di tutte le variabili nel workspace
all_vars = who;
for i = 1:length(all_vars)
    varname = all_vars{i};
    
    % Salta la variabile 'filename' e altre variabili di sistema
    if strcmp(varname, 'filename') || strcmp(varname, 'all_vars')
        continue;
    end
    
    % Ottieni la variabile
    var_data = eval(varname);
    
    % Se è una struct, mostra i suoi sottocampi
    if isstruct(var_data)
        subfields = fieldnames(var_data);
        fprintf('%s (struct con %d campi): %s\n', varname, length(subfields), ...
                strjoin(subfields(1:min(5,end)), ', '));
    else
        fprintf('%s: %s\n', varname, class(var_data));
    end
end
%% Analisi dettagliata IMU con struttura matrice
if exist('IMU_0', 'var')
    fprintf('\n=== ANALISI IMU_0 (formato matrice) ===\n');
    imu = IMU_0;
    
    fprintf('Dimensioni: %d righe x %d colonne\n', size(imu, 1), size(imu, 2));
    
    % Estrai timestamp (colonna 2)
    time_us = imu(:, 2);
    time_s = time_us / 1e6;
    
    % Calcola frequenza di campionamento
    dt = diff(time_s);
    freq = 1 / mean(dt);
    fprintf('Frequenza media IMU: %.2f Hz\n', freq);
    fprintf('Durata volo: %.2f secondi\n', time_s(end) - time_s(1));
    fprintf('Numero campioni: %d\n', length(time_s));
    
    % Estrai accelerazioni (colonne 7-9)
    AccX = imu(:, 7);
    AccY = imu(:, 8);
    AccZ = imu(:, 9);
    
    fprintf('\nAccelerazioni:\n');
    fprintf('  AccX: min=%.2f, max=%.2f, mean=%.2f m/s²\n', min(AccX), max(AccX), mean(AccX));
    fprintf('  AccY: min=%.2f, max=%.2f, mean=%.2f m/s²\n', min(AccY), max(AccY), mean(AccY));
    fprintf('  AccZ: min=%.2f, max=%.2f, mean=%.2f m/s² (gravità ~-9.8)\n', min(AccZ), max(AccZ), mean(AccZ));
    
    % Estrai giroscopi (colonne 4-6)
    GyrX = imu(:, 4);
    GyrY = imu(:, 5);
    GyrZ = imu(:, 6);
    
    fprintf('\nGiroscopi:\n');
    fprintf('  GyrX: min=%.2f, max=%.2f, mean=%.2f rad/s\n', min(GyrX), max(GyrX), mean(GyrX));
    fprintf('  GyrY: min=%.2f, max=%.2f, mean=%.2f rad/s\n', min(GyrY), max(GyrY), mean(GyrY));
    fprintf('  GyrZ: min=%.2f, max=%.2f, mean=%.2f rad/s\n', min(GyrZ), max(GyrZ), mean(GyrZ));
end
%% Analisi ESC (motori)
fprintf('\n=== ANALISI ESC (MOTORI) ===\n');
for motor = 0:5
    esc_name = sprintf('ESC_%d', motor);
    if exist(esc_name, 'var')
        esc = eval(esc_name);
        fprintf('\n%s:\n', esc_name);
        fprintf('  Tipo: %s\n', class(esc));
        fprintf('  Dimensioni: %d x %d\n', size(esc, 1), size(esc, 2));
        
        if isnumeric(esc) && size(esc, 2) >= 2
            % Probabilmente: Col 1 = counter, Col 2 = TimeUS, Col 3 = RPM, ecc.
            fprintf('  Prime 3 righe:\n');
            disp(esc(1:3, :));
            
            % Analizza statistiche
            fprintf('  Statistiche colonne:\n');
            for col = 1:min(5, size(esc, 2))
                fprintf('    Col %d: min=%.2f, max=%.2f, mean=%.2f\n', ...
                        col, min(esc(:,col)), max(esc(:,col)), mean(esc(:,col)));
            end
        end
    end
end
%% Analisi VIBE (vibrazioni)
fprintf('\n=== ANALISI VIBE ===\n');
for vibe_id = 0:2
    vibe_name = sprintf('VIBE_%d', vibe_id);
    if exist(vibe_name, 'var')
        vibe = eval(vibe_name);
        fprintf('\n%s:\n', vibe_name);
        fprintf('  Tipo: %s\n', class(vibe));
        fprintf('  Dimensioni: %d x %d\n', size(vibe, 1), size(vibe, 2));
        
        if isnumeric(vibe) && size(vibe, 2) >= 2
            fprintf('  Prime 3 righe:\n');
            disp(vibe(1:3, :));
            
            % Statistiche
            fprintf('  Statistiche colonne:\n');
            for col = 1:size(vibe, 2)
                fprintf('    Col %d: min=%.2f, max=%.2f, mean=%.2f\n', ...
                        col, min(vibe(:,col)), max(vibe(:,col)), mean(vibe(:,col)));
            end
        end
    end
end