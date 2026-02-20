%% CHIAMATA DELLA FUNZIONE CHE ESTRAE LE FEATURE

[featureTable,ranking,outputTable] = diagnosticFeatures(dataTable);
save('UAV_features_binary.mat', 'featureTable', 'ranking', 'outputTable'); % Salvataggio su file

% Cambiare il comando in base a quale analisi si vuole fare (binaria o multiclasse)

%save('UAV_features_multiclass.mat', 'featureTable', 'ranking', 'outputTable');

%% PULIZIA DELLE FEATURE CON RIMOZIONE DEI NAN

fprintf('Feature totali: %d\n', width(featureTable) - 4);
fprintf('Frame totali: %d\n', height(featureTable));
totalCells = (width(featureTable) - 4) * height(featureTable);
fprintf('Celle totali: %d\n', totalCells);

featureTable=standardizeMissing(featureTable,{-Inf,Inf});
countcolumnNaNs=[zeros(1,4),sum(isnan(table2array(featureTable(:,5:end))))];

% Rimozione delle Features con più del 25% di NaN
featureTable(:,find(countcolumnNaNs>size(featureTable,1)/4))=[];

nansAfterRemoval = sum(sum(isnan(table2array(featureTable(:,5:end)))));
fprintf('\n--- DOPO RIMOZIONE COLONNE ---\n');
fprintf('Feature rimanenti: %d\n', width(featureTable) - 4);
fprintf('NaN rimanenti: %d\n', nansAfterRemoval);

% Primo sample se c'è NaN metto lo 0
initial=find(featureTable.('FRM_1/TimeStart')==0);
featureTable_tmp1 = fillmissing(featureTable(initial,:),'constant',0,'DataVariables',@isnumeric);
featureTable(initial,:) = featureTable_tmp1;

% Dal secondo sample sostituisco i NaN col valore precedente
featureTable = fillmissing(featureTable,'previous');

nansAfterFill = sum(sum(isnan(table2array(featureTable(:,5:end)))));
fprintf('\n=== RISULTATO FINALE ===\n');
fprintf('Feature finali: %d\n', width(featureTable) - 4);
fprintf('Frame finali: %d\n', height(featureTable));
fprintf('NaN residui: %d\n', nansAfterFill);

%% DIVISIONE TRA TRAINING E TEST SET

rng(0)
partition=cvpartition(featureTable.EnsembleID_,'Holdout',0.3,'Stratify',true);
idx_train = training(partition);
idx_test = test(partition);

featureTable_Train=featureTable(idx_train,:);
featureTable_Test=featureTable(idx_test,:);

%% SALVATAGGIO DATI 

save('UAV_finalDatasetSplitted_binary.mat', 'ranking', 'featureTable', 'featureTable_Train', 'featureTable_Test'); 

% Cambiare il comando in base a quale analisi si vuole fare (binaria o multiclasse)

% save('UAV_finalDatasetSplitted_multiclass.mat', 'ranking', 'featureTable','featureTable_Train', 'featureTable_Test');

%% AVVIO DEL TOOLBOX CLASSIFICATION LEARNER

classificationLearner(featureTable_Train,'faultCode');