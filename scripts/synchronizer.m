function Data = synchronizer(input_path, Fs)
    load(input_path);
    num_motors = 6;
    
    %% FILTRAGGIO
    
    [IMU_0,IMU_1,IMU_2] = compareN(IMU_0,IMU_1,IMU_2);
    [XKF1_0,XKF1_1] = compareN(XKF1_0,XKF1_1);
    [VIBE_0,VIBE_1,VIBE_2] = compareN(VIBE_0,VIBE_1,VIBE_2);
    
    % Media IMU
    IMU_all = cat(3, IMU_0(:,4:9), IMU_1(:,4:9), IMU_2(:,4:9));
    IMU_mean = mean(IMU_all, 3);
    IMU.GYR = IMU_mean(:,1:3);
    IMU.ACC = IMU_mean(:,4:6);
    
    % PWM
    PWM = RCOU(:,11:11+num_motors-1);
    
    % ESC
    for k = 1:num_motors
        ESC.(sprintf('RPM%d', k-1)) = eval(sprintf('ESC_%d(:,4)', k-1));
        ESC.(sprintf('CURR%d', k-1)) = eval(sprintf('ESC_%d(:,7)', k-1));
    end
    
    % ATTITUDE
    cols = [4 6 8];
    des_cols = [3 5 7];
    fields = {'ROLL','PITCH','YAW'};
    for i = 1:3
        ATTITUDE.(fields{i}) = ATT(:, cols(i));
        ATTITUDE.(sprintf('Des%s', fields{i})) = ATT(:, des_cols(i));
    end
    
    % XFK1
    n = min([size(XKF1_0,1) size(XKF1_1,1)]);
    XKF1_angles = cat(3, XKF1_0(1:n,4:6), XKF1_1(1:n,4:6));
    XKF1.ROLL = mean(unwrap(XKF1_angles(:,1,:)/360*2*pi,[],3),3);
    XKF1.PITCH = mean(unwrap(XKF1_angles(:,2,:)/360*2*pi,[],3),3);
    XKF1.YAW = mean(unwrap(XKF1_angles(:,3,:)/360*2*pi,[],3),3);
    
    XKF1_vel = cat(3, XKF1_0(1:n,7:9), XKF1_1(1:n,7:9));
    XKF1.VN = mean(XKF1_vel(:,1,:),3);
    XKF1.VE = mean(XKF1_vel(:,2,:),3);
    XKF1.VD = mean(XKF1_vel(:,3,:),3);
    
    % VIBE
    VIBE_all = cat(3, VIBE_0(:,4:6), VIBE_1(:,4:6), VIBE_2(:,4:6));
    VIBE.ACC = mean(VIBE_all, 3);
    
    %% TIME
    
    ESC_all = {ESC_0, ESC_1, ESC_2, ESC_3, ESC_4, ESC_5}; % perchè ci sono 6 motori
    Time.IMU = seconds(IMU_0(1:size(IMU.GYR,1),2)/1e6);
    Time.PWM = seconds(RCOU(:,2)/1e6);
    Time.ATT = seconds(ATT(:,2)/1e6);
    Time.XKF1 = seconds(XKF1_0(1:size(XKF1.ROLL,1),2)/1e6);
    Time.VIBE = seconds(VIBE_0(1:size(VIBE.ACC,1),2)/1e6);
    for k = 1:num_motors
        Time.(sprintf('ESC%d', k-1)) = seconds(ESC_all{k}(:,2)/1e6);
    end
    
    %% SINCRONIZZAZIONE ZOH - con synchronize()
    
    % IMU
    IMU_tt = timetable(Time.IMU, IMU.GYR(:,1), IMU.GYR(:,2), IMU.GYR(:,3), IMU.ACC(:,1), IMU.ACC(:,2), IMU.ACC(:,3), 'VariableNames', {'IMU_GYR_X','IMU_GYR_Y','IMU_GYR_Z','IMU_ACC_X','IMU_ACC_Y','IMU_ACC_Z'});
    
    % PWM
    PWM_tt = timetable(Time.PWM, PWM, 'VariableNames', {'PWM'});
    
    % ESC: timetable separate perchè ogni ESC ha timestamp diversi
    ESC_tt_list = cell(num_motors, 1);
    for k = 1:num_motors
        motor_id = k - 1;
        rpm_name = sprintf('ESC_RPM%d', motor_id);
        curr_name = sprintf('ESC_CURR%d', motor_id);
        time_name = sprintf('ESC%d', motor_id);
        ESC_tt_list{k} = timetable(Time.(time_name), ESC.(sprintf('RPM%d', motor_id)), ESC.(sprintf('CURR%d', motor_id)), 'VariableNames', {rpm_name, curr_name});
    end
    
    % ATTITUDE
    ATT_tt = timetable(Time.ATT, ATTITUDE.ROLL, ATTITUDE.PITCH, ATTITUDE.YAW, ATTITUDE.DesROLL, ATTITUDE.DesPITCH, ATTITUDE.DesYAW, 'VariableNames', {'ATT_ROLL','ATT_PITCH','ATT_YAW','ATT_DesROLL','ATT_DesPITCH','ATT_DesYAW'});
    
    % XKF1
    XKF1_tt = timetable(Time.XKF1, XKF1.ROLL, XKF1.PITCH, XKF1.YAW, XKF1.VN, XKF1.VE, XKF1.VD, 'VariableNames', {'XKF1_ROLL','XKF1_PITCH','XKF1_YAW','XKF1_VN','XKF1_VE','XKF1_VD'});
    
    % VIBE
    VIBE_tt = timetable(Time.VIBE, VIBE.ACC(:,1), VIBE.ACC(:,2), VIBE.ACC(:,3), 'VariableNames', {'VIBE_ACC_X','VIBE_ACC_Y','VIBE_ACC_Z'});
    
    %% SINCRONIZZAZIONE di tutto con 'union' + 'previous' (ZOH)
    
    all_tt_cell = {IMU_tt, PWM_tt, ATT_tt, XKF1_tt, VIBE_tt, ESC_tt_list{:}};
    tt_sync = synchronize(all_tt_cell{:}, 'union', 'previous');
    
    % Resample a 350 Hz uniforme
    finishTime = seconds(tt_sync.Time(end));
    timesout = seconds(0:1/Fs:finishTime)';
    tt_resampled = retime(tt_sync, timesout, 'linear');
    
    % Estrazione delle variabili
    IMU_SYNC.GYR = [tt_resampled.IMU_GYR_X, tt_resampled.IMU_GYR_Y, tt_resampled.IMU_GYR_Z];
    IMU_SYNC.ACC = [tt_resampled.IMU_ACC_X, tt_resampled.IMU_ACC_Y, tt_resampled.IMU_ACC_Z];
    PWM_sync = tt_resampled.PWM;
    
    for k = 1:num_motors
        motor_id = k - 1;
        ESC_SYNC.(sprintf('RPM%d', motor_id)) = tt_resampled.(sprintf('ESC_RPM%d', motor_id));
        ESC_SYNC.(sprintf('CURR%d', motor_id)) = tt_resampled.(sprintf('ESC_CURR%d', motor_id));
    end
    
    ATTITUDE_SYNC.ROLL = tt_resampled.ATT_ROLL;
    ATTITUDE_SYNC.PITCH = tt_resampled.ATT_PITCH;
    ATTITUDE_SYNC.YAW = tt_resampled.ATT_YAW;
    ATTITUDE_SYNC.DesROLL = tt_resampled.ATT_DesROLL;
    ATTITUDE_SYNC.DesPITCH = tt_resampled.ATT_DesPITCH;
    ATTITUDE_SYNC.DesYAW = tt_resampled.ATT_DesYAW;
    
    XKF1_SYNC.ROLL = tt_resampled.XKF1_ROLL;
    XKF1_SYNC.PITCH = tt_resampled.XKF1_PITCH;
    XKF1_SYNC.YAW = tt_resampled.XKF1_YAW;
    XKF1_SYNC.VN = tt_resampled.XKF1_VN;
    XKF1_SYNC.VE = tt_resampled.XKF1_VE;
    XKF1_SYNC.VD = tt_resampled.XKF1_VD;
    
    VIBE_SYNC.ACC = [tt_resampled.VIBE_ACC_X, tt_resampled.VIBE_ACC_Y, tt_resampled.VIBE_ACC_Z];

    time_sync = tt_resampled.Time;
    
    %% TAGLIO FASE DI DECOLLO E ATTERRAGGIO
    
    syncStructs = {IMU_SYNC, ESC_SYNC, ATTITUDE_SYNC, XKF1_SYNC, VIBE_SYNC};
    
    % CUT 1: Throttle basso
    idxcut1 = sum(PWM_sync, 2) < 1450*size(PWM, 2);
    for s = 1:length(syncStructs)
        flds = fieldnames(syncStructs{s});
        for f = 1:length(flds)
            syncStructs{s}.(flds{f})(idxcut1, :) = [];
        end
    end
    PWM_sync(idxcut1, :) = [];
    time_sync(idxcut1) = [];
    
    % CUT 2: Primi 2 secondi
    idxcut2 = 1:min(2*Fs, size(PWM_sync, 1));
    for s = 1:length(syncStructs)
        flds = fieldnames(syncStructs{s});
        for f = 1:length(flds)
            syncStructs{s}.(flds{f})(idxcut2, :) = [];
        end
    end
    PWM_sync(idxcut2, :) = [];
    time_sync(idxcut2) = [];
    
    % CUT 3: Ultimi 2 secondi
    n_rows = size(PWM_sync, 1);
    if n_rows > 2*Fs
        idxcut3 = (n_rows - 2*Fs + 1):n_rows;
        for s = 1:length(syncStructs)
            flds = fieldnames(syncStructs{s});
            for f = 1:length(flds)
                syncStructs{s}.(flds{f})(idxcut3, :) = [];
            end
        end
        PWM_sync(idxcut3, :) = [];
        time_sync(idxcut2) = [];
    end
    
    IMU_SYNC = syncStructs{1};
    ESC_SYNC = syncStructs{2};
    ATTITUDE_SYNC = syncStructs{3};
    XKF1_SYNC = syncStructs{4};
    VIBE_SYNC = syncStructs{5};
    
    %% SALVATAGGIO
    Data.Time = time_sync;
    
    Data.IMU.GYR = IMU_SYNC.GYR;
    Data.IMU.ACC = IMU_SYNC.ACC;
    Data.PWM = PWM_sync;
    for k = 1:num_motors
        Data.ESC.(sprintf('RPM%d', k-1)) = ESC_SYNC.(sprintf('RPM%d', k-1));
        Data.ESC.(sprintf('CURR%d', k-1)) = ESC_SYNC.(sprintf('CURR%d', k-1));
    end
    Data.ATTITUDE = ATTITUDE_SYNC;
    Data.XKF1 = XKF1_SYNC;
    Data.VIBE.ACC = VIBE_SYNC.ACC;
    
    % Salvataggio su file
    [~, base_name, ~] = fileparts(input_path);
    script_folder = fileparts(mfilename('fullpath'));
    project_folder = fileparts(script_folder);
    output_folder = fullfile(project_folder, 'synchronized_data');
    output_file = fullfile(output_folder, [base_name '_sync.mat']);
    save(output_file, 'Data', '-v7.3');

end
