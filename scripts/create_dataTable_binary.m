%% CREATE DATATABLE - Costruzione DataTable Unica per estrazione delle feature
clear; clc;

fprintf('\nCREAZIONE DATASET UNICO\n');

%% CONFIGURAZIONE
Fs = 350;  % Frequenza di campionamento a 350 Hz

% Percorsi
script_folder = fileparts(mfilename('fullpath'));
project_folder = fileparts(script_folder);
sync_folder = fullfile(project_folder, 'synchronized_data');

% Debug: Stampa percorsi
fprintf('Script folder: %s\n', script_folder);
fprintf('Project folder: %s\n', project_folder);
fprintf('Sync folder: %s\n\n', sync_folder);

%% DEFINIZIONE FAULT CODES

file_patterns = {
    'NO_FAULT*_sync.mat', 0;      % 6 file normali
    'FAULT_M*_5_sync.mat', 1;    % 6 file fault 5%
    'FAULT_M*_10_sync.mat', 1;  % 6 file fault 10%
};

% Trova i file
all_files = {};
fault_codes = [];

for i = 1:size(file_patterns, 1)
    pattern = file_patterns{i, 1};
    code = file_patterns{i, 2};
    
    files = dir(fullfile(sync_folder, pattern));
    
    for j = 1:length(files)
        all_files{end+1} = fullfile(sync_folder, files(j).name);
        fault_codes(end+1) = code;
    end
end

nFiles = length(all_files);
fprintf('Trovati %d file sincronizzati\n', nFiles);
fprintf('  - Fault 0%%:  %d file\n', sum(fault_codes == 0));
fprintf('  - Fault 5%%:  %d file\n', sum(fault_codes == 5));
fprintf('  - Fault 10%%: %d file\n\n', sum(fault_codes == 10));

%% CREAZIONE DATATABLE
dataTable = table('Size', [nFiles 0]);

fprintf('Caricamento dati:\n');
for i = 1:nFiles
    [~, filename, ~] = fileparts(all_files{i});
    fprintf('  [%2d/%2d] %s (Fault: %d%)\n', i, nFiles, filename, fault_codes(i));
    
    % Carica file
    data = load(all_files{i});
    data = data.Data;  % Estrai struct Data
    
    % Estrazione variabili
    acc_x = data.IMU.GYR(:,1);
    acc_y = data.IMU.GYR(:,2);
    acc_z = data.IMU.GYR(:,3);
    gyr_x = data.IMU.ACC(:,1);
    gyr_y = data.IMU.ACC(:,2);
    gyr_z = data.IMU.ACC(:,3);
    
    pwm_1 = data.PWM(:,1);
    pwm_2 = data.PWM(:,2);
    pwm_3 = data.PWM(:,3);
    pwm_4 = data.PWM(:,4);
    pwm_5 = data.PWM(:,5);
    pwm_6 = data.PWM(:,6);
    
    esc_1 = data.ESC.RPM0;
    esc_2 = data.ESC.RPM1;
    esc_3 = data.ESC.RPM2;
    esc_4 = data.ESC.RPM3;
    esc_5 = data.ESC.RPM4;
    esc_6 = data.ESC.RPM5;
    
    cur_1 = data.ESC.CURR0;
    cur_2 = data.ESC.CURR1;
    cur_3 = data.ESC.CURR2;
    cur_4 = data.ESC.CURR3;
    cur_5 = data.ESC.CURR4;
    cur_6 = data.ESC.CURR5;
    
    roll = data.ATTITUDE.ROLL;
    pitch = data.ATTITUDE.PITCH;
    yaw = data.ATTITUDE.YAW;
    roll_des = data.ATTITUDE.DesROLL;
    pitch_des = data.ATTITUDE.DesPITCH;
    yaw_des = data.ATTITUDE.DesYAW;
    
    vn = data.XKF1.VN;
    ve = data.XKF1.VE;
    vd = data.XKF1.VD;
    
    vibe_x = data.VIBE.ACC(:,1);
    vibe_y = data.VIBE.ACC(:,2);
    vibe_z = data.VIBE.ACC(:,3);
    
    % Conversione a timeTable
    dataTable.acc_x(i) = {array2timetable(acc_x, 'SampleRate', Fs)};
    dataTable.acc_y(i) = {array2timetable(acc_y, 'SampleRate', Fs)};
    dataTable.acc_z(i) = {array2timetable(acc_z, 'SampleRate', Fs)};
    dataTable.gyr_x(i) = {array2timetable(gyr_x, 'SampleRate', Fs)};
    dataTable.gyr_y(i) = {array2timetable(gyr_y, 'SampleRate', Fs)};
    dataTable.gyr_z(i) = {array2timetable(gyr_z, 'SampleRate', Fs)};
    
    dataTable.pwm_1(i) = {array2timetable(pwm_1, 'SampleRate', Fs)};
    dataTable.pwm_2(i) = {array2timetable(pwm_2, 'SampleRate', Fs)};
    dataTable.pwm_3(i) = {array2timetable(pwm_3, 'SampleRate', Fs)};
    dataTable.pwm_4(i) = {array2timetable(pwm_4, 'SampleRate', Fs)};
    dataTable.pwm_5(i) = {array2timetable(pwm_5, 'SampleRate', Fs)};
    dataTable.pwm_6(i) = {array2timetable(pwm_6, 'SampleRate', Fs)};
    
    dataTable.esc_1(i) = {array2timetable(esc_1, 'SampleRate', Fs)};
    dataTable.esc_2(i) = {array2timetable(esc_2, 'SampleRate', Fs)};
    dataTable.esc_3(i) = {array2timetable(esc_3, 'SampleRate', Fs)};
    dataTable.esc_4(i) = {array2timetable(esc_4, 'SampleRate', Fs)};
    dataTable.esc_5(i) = {array2timetable(esc_5, 'SampleRate', Fs)};
    dataTable.esc_6(i) = {array2timetable(esc_6, 'SampleRate', Fs)};
    
    dataTable.cur_1(i) = {array2timetable(cur_1, 'SampleRate', Fs)};
    dataTable.cur_2(i) = {array2timetable(cur_2, 'SampleRate', Fs)};
    dataTable.cur_3(i) = {array2timetable(cur_3, 'SampleRate', Fs)};
    dataTable.cur_4(i) = {array2timetable(cur_4, 'SampleRate', Fs)};
    dataTable.cur_5(i) = {array2timetable(cur_5, 'SampleRate', Fs)};
    dataTable.cur_6(i) = {array2timetable(cur_6, 'SampleRate', Fs)};
    
    dataTable.roll(i) = {array2timetable(roll, 'SampleRate', Fs)};
    dataTable.pitch(i) = {array2timetable(pitch, 'SampleRate', Fs)};
    dataTable.yaw(i) = {array2timetable(yaw, 'SampleRate', Fs)};
    dataTable.roll_des(i) = {array2timetable(roll_des, 'SampleRate', Fs)};
    dataTable.pitch_des(i) = {array2timetable(pitch_des, 'SampleRate', Fs)};
    dataTable.yaw_des(i) = {array2timetable(yaw_des, 'SampleRate', Fs)};
    
    dataTable.vn(i) = {array2timetable(vn, 'SampleRate', Fs)};
    dataTable.ve(i) = {array2timetable(ve, 'SampleRate', Fs)};
    dataTable.vd(i) = {array2timetable(vd, 'SampleRate', Fs)};
    
    dataTable.vibe_x(i) = {array2timetable(vibe_x, 'SampleRate', Fs)};
    dataTable.vibe_y(i) = {array2timetable(vibe_y, 'SampleRate', Fs)};
    dataTable.vibe_z(i) = {array2timetable(vibe_z, 'SampleRate', Fs)};
end

%% AGGIUNTA DEI FAULT CODES
dataTable.faultCode = categorical(fault_codes');

