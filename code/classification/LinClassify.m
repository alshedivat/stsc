function TestOut = LinClassify(LearnOut)
% LINCLASSIFY  Applies linear classification to the input data.
%              Returns the Output structure with true labels, scores,
%              predictions, and accuracy.
% =========================================================================

TestSet = LearnOut.TestSet;
LabelIdx = unique(TestSet.Labels);
SampleNum = size(TestSet.Features,2);

% Linear classification scores
TestOut.Scores = LearnOut.W * TestSet.Features + ...
                 repmat(LearnOut.b, 1, SampleNum);

% Choose the labels with the best scores
[~,LabelIdxTemp] = max(TestOut.Scores,[],1);
TestOut.Predictions = LabelIdx(LabelIdxTemp);

TestOut.Accuracy = sum(TestSet.Labels == TestOut.Predictions) /...
                   size(TestSet.Labels,2) * 100;

TestOut.AccuracyS = ...
    sum(TestSet.Labels == TestOut.Predictions & TestSet.DomainIdx == 1) /...
    sum(TestSet.DomainIdx ==  1) * 100;

TestOut.AccuracyT = ...
    sum(TestSet.Labels == TestOut.Predictions & TestSet.DomainIdx == -1) /...
    sum(TestSet.DomainIdx == -1) * 100;
end

