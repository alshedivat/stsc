function LearnOut = Learn(TrainSet, TestSet, config, verbose)
% LEARN Takes an input structure of objects and performs learning.
% =========================================================================

% If semi-supervised style, we work with the whole data while training
if strcmp(config.LearningStyle,'semi-supervised')
    TrainIn.Features  = [TrainSet.Features  TestSet.Features];
    TrainIn.DomainIdx = [TrainSet.DomainIdx TestSet.DomainIdx];
    TrainIn.Labeled   = [TrainSet.Labeled   TestSet.Labeled];
    TrainIn.Labels    = [TrainSet.Labels    TestSet.Labels];
else
    TrainIn = TrainSet;
end

if strcmp(config.LearningMode, 'none')
    TrainOut = TrainIn;
else
    if isfield(config, 'PCA_var')
        [Coef, TrainIn.Features] = PCA(TrainIn.Features, config.PCA_var);
    end
    if strcmp(config.LearningMode, 'pca_only')
        TrainOut = TrainIn;
    else
        if strcmp(config.LearningMode, 'separate')
            TrainOut = SC_DT(TrainIn, config, verbose);
        elseif strcmp(config.LearningMethod, 'SVM')
            TrainOut = SC_DT_SVM(TrainIn, config, verbose);
            LearnOut.W = TrainOut.W;
            LearnOut.b = TrainOut.b;
        elseif strcmp(config.LearningMethod, 'LDA')
            throw(MException('Run:NotImplementedError',...
                             'LDA learning is not implemented.'));
            TrainOut = SC_DT_LDA(TrainIn, config, verbose);
        end
        LearnOut.Fobj = TrainOut.Fobj;
        LearnOut.Dict = TrainOut.Dict;
    end
end

% Construct the output structure
if strcmp(config.LearningStyle, 'semi-supervised')
    TrainNum = length(TrainSet.Labels);

    LearnOut.TrainSet.Features  = TrainOut.Features(:,1:TrainNum);
    LearnOut.TrainSet.DomainIdx = TrainOut.DomainIdx(:,1:TrainNum);
    LearnOut.TrainSet.Labeled   = TrainOut.Labeled(:,1:TrainNum);
    LearnOut.TrainSet.Labels    = TrainOut.Labels(:,1:TrainNum);

    LearnOut.TestSet.Features  = TrainOut.Features(:,TrainNum+1:end);
    LearnOut.TestSet.DomainIdx = TrainOut.DomainIdx(:,TrainNum+1:end);
    LearnOut.TestSet.Labeled   = TrainOut.Labeled(:,TrainNum+1:end);
    LearnOut.TestSet.Labels    = TrainOut.Labels(:,TrainNum+1:end);
else
    LearnOut.TrainSet = TrainSet;
    LearnOut.TrainSet.Features  = TrainOut.Features;  % Features <- SC

    if exist('Coef', 'var')
        TestSet.Features = Coef * TestSet.Features;
    end
    LearnOut.TestSet = TestSet;
    if isfield(LearnOut, 'Dict')
        [~,~,GL] = BuildMatrices(TestSet,config,false);
        %L = zeros(size(TestSet.Features,2),size(TestSet.Features,2));
        L = config.h * GL;
        LearnOut.TestSet.Features =...
            learn_coefficients(LearnOut.Dict,TestSet.Features,config.e,L);
    end
end

end
