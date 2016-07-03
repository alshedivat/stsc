function TestOut = SVMClassify(LearnOut, Options)
% SVMCLASSIFY Applies SVM classification to the input data.
%             Returns the Output structure with true labels, scores,
%             predictions, and accuracy.
% =========================================================================

TrainSet = LearnOut.TrainSet;
TestSet = LearnOut.TestSet;
LabeledTrainIdx = find(TrainSet.Labeled == 1);
SourceTestIdx = find(TestSet.DomainIdx ==  1);
TargetTestIdx = find(TestSet.DomainIdx == -1);

SVMmodel = {};
for i=1:length(Options.c)
    % Learning SVM model from the training data
    SVMmodel{i} = svmtrain(TrainSet.Labels(LabeledTrainIdx)',...
                           TrainSet.Features(:,LabeledTrainIdx)',...
                           sprintf('-s 0 -t 0 -e 0.001 -c %f -b 1 -q',...
                           Options.c(i)));
end

TestOut.Accuracy = [];
TestOut.Predictions = [];
for i=1:length(Options.c)
    % Classifying the test data
    [Predictions,Accuracy,~] =...
        svmpredict(TestSet.Labels',TestSet.Features',SVMmodel{i}, '-b 1 -q');

    TestOut.Accuracy = [TestOut.Accuracy Accuracy(1)];
    TestOut.Predictions = [TestOut.Predictions Predictions];
end

% Classify only the source part
if ~isempty(SourceTestIdx)
    TestOut.AccuracyS = [];
    TestOut.PredictionsS = [];
    for i=1:length(Options.c)
        % Classifying the test data
        [Predictions,Accuracy,~] =...
            svmpredict(TestSet.Labels(SourceTestIdx)',...
                       TestSet.Features(:,SourceTestIdx)',...
                       SVMmodel{i}, '-b 1 -q');

        TestOut.AccuracyS = [TestOut.AccuracyS Accuracy(1)];
        TestOut.PredictionsS = [TestOut.PredictionsS Predictions];
    end
end

% Classify only the target part
if ~isempty(TargetTestIdx)
    TestOut.AccuracyT = [];
    TestOut.PredictionsT = [];
    for i=1:length(Options.c)
        % Classifying the test data
        [Predictions,Accuracy,~] =...
            svmpredict(TestSet.Labels(TargetTestIdx)',...
                       TestSet.Features(:,TargetTestIdx)',...
                       SVMmodel{i}, '-b 1 -q');

        TestOut.AccuracyT = [TestOut.AccuracyT Accuracy(1)];
        TestOut.PredictionsT = [TestOut.PredictionsT Predictions];
    end
end


end
