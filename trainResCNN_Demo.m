% Training ResCNN Model (Demo)

%% Copyright,(c)2020-2024, Georgia Institute of Technology
%{
Created on:  04/30/2020 09:00

@File: trainResCNN_Demo.m
@Author：Tingli Xie
@Requirement: MATLAB R2020a

%}

clc;clear;close; % Release all data
addpath(genpath(pwd)); % Add all files to working path
%% Load data
% Load data
imds = imageDatastore('toImgs/Kat_64_pcaRGB/N09_M07_F10/','LabelSource','foldernames','IncludeSubfolders',true);

%%
% Prepare data
[trainData,valData,testData]=imds.splitEachLabel(0.7,0.15,0.15,'Randomize'); % split data to Train, Validation, Test

% Define network layers
lgraph = rescnn(16, [64 64 3], 3);
%analyzeNetwork(lgraph);

% Customize training option
options = trainingOptions('adam',...
            'InitialLearnRate',5e-4, ...
            'MaxEpochs',30, ...
            'ValidationData',valData,...
            'LearnRateSchedule','piecewise',...
            'LearnRateDropFactor',0.5,...
            'LearnRateDropPeriod',8,...
            'Plots','None',...
            'MiniBatchSize',64,...
            'ValidationFrequency',100, ...
            'ExecutionEnvironment','gpu'); %'Plots','training-progress',...'Plots','None',...

% Train
net = trainNetwork(trainData,lgraph,options);
%save net

% Test
testLabel = classify(net,testData);
precision = sum(testLabel==testData.Labels)/numel(testLabel)

figure('Units','normalized','Position',[0.2 0.2 0.4 0.4]);
cm = confusionchart(testData.Labels,testLabel);
cm.Title = 'Confusion Matrix for Validation Data';
cm.Normalization = 'row-normalized';
%cm.ColumnSummary = 'column-normalized';
%cm.RowSummary = 'row-normalized';

