function TestOut = LRClassify(LearnOut, Options)
% LRCLASSIFY Applies logistic regression to the input data.
%            Returns the Output structure with true labels, scores,
%            predictions, and accuracy.
% =========================================================================

TrainSet = LearnOut.TrainSet;
TestSet = LearnOut.TestSet;
LabeledTrainIdx = find(TrainSet.Labeled == 1);
SourceTestIdx = find(TestSet.DomainIdx == 1);
TargetTestIdx = find(TestSet.DomainIdx == -1);

LRmodel = {};
for i=1:length(Options.c)
    % Learn LR model from the training data
    LRmodel{i} = train(sparse(TrainSet.Labels(LabeledTrainIdx))',...
                       sparse(TrainSet.Features(:,LabeledTrainIdx))',...
                       sprintf('-s 0 -e 0.01 -c %f -q', Options.c(i)));
end

TestOut.Accuracy = [];
TestOut.Predictions = [];
for i=1:length(Options.c)
    % Classify the test data
    [Predictions,Accuracy,~] =...
        predict(sparse(TestSet.Labels)',sparse(TestSet.Features)',...
                LRmodel{i},'-b 1 -q');
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
            predict(sparse(TestSet.Labels(SourceTestIdx))',...
                    sparse(TestSet.Features(:,SourceTestIdx))',...
                    LRmodel{i},'-b 1 -q');
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
            predict(sparse(TestSet.Labels(TargetTestIdx))',...
                    sparse(TestSet.Features(:,TargetTestIdx))',...
                    LRmodel{i},'-b 1 -q');
        TestOut.AccuracyT = [TestOut.AccuracyT Accuracy(1)];
        TestOut.PredictionsT = [TestOut.PredictionsT Predictions];
    end
end

end
