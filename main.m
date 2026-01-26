
%% Computation of Diagnostic Feature Designer features
[feature_Table,data_feature_Table] = diagnosticFeaturesfull(dataTable);

%% Clean features by removing NaNs from features
feature_Table=standardizeMissing(feature_Table,{-Inf,Inf});
countcolumnNaNs=[zeros(1,4),sum(isnan(table2array(feature_Table(:,5:end))))];
% Remove features with more than 25% of NaNs
feature_Table(:,find(countcolumnNaNs>size(feature_Table,1)/4))=[];
% First sample: if a feature sample is NaN, replace with 0
initial=find(feature_Table.('FRM_1/TimeStart')==0);
feature_Table_tmp1 = fillmissing(feature_Table(initial,:),'constant',0,'DataVariables',@isnumeric);
feature_Table(initial,:) = feature_Table_tmp1;
% Second to last sample: if a feature sample is NaN, replace with previous value
feature_Table = fillmissing(feature_Table,'previous');

%% Split into training and testing data
rng(0)
partition=cvpartition(feature_Table.EnsembleID_,'Holdout',0.3,'Stratify',true);
idx_train = training(partition);
idx_test = test(partition);

feature_Table_Train=feature_Table(idx_train,:);
feature_Table_Test=feature_Table(idx_test,:);

%% Save data and try to reload the feature table
save data_feature_Table_zoh.mat dataTable data_feature_Table feature_Table feature_Table_Train feature_Table_Test
clear all
load data_feature_Table_zoh.mat

%%
classificationLearner(feature_Table_Train,'faultCode');