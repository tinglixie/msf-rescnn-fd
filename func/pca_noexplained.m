function [dataPca] = pca_noexplained(dataRaw, k)
dataZscore = zscore(dataRaw);
[coeff,~,~,~,~,~] = pca(dataZscore,'VariableWeights','variance');
dataPcaPre = bsxfun(@minus,dataZscore,mean(dataZscore, 1));
dataPca = dataPcaPre*coeff(:, 1:k);