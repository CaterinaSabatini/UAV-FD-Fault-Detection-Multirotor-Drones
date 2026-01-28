[featureTable,ranking,outputTable] = diagnosticFeatures(dataTable);
%save('UAV_features_complete.mat', 'featureTable', 'ranking', 'outputTable');

%% Pulizia delle Features con rimozione dei NaN

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

%% Divisione tra training e test dataset
rng(0)
partition=cvpartition(featureTable.EnsembleID_,'Holdout',0.3,'Stratify',true);
idx_train = training(partition);
idx_test = test(partition);

featureTable_Train=featureTable(idx_train,:);
featureTable_Test=featureTable(idx_test,:);

%% Salvataggio dati
save('UAV_features_final.mat', 'ranking', 'featureTable', 'featureTable_Train', 'featureTable_Test');

%% Avvio classificationLearner
classificationLearner(featureTable_Train,'faultCode');