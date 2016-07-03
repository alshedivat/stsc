function TestOut = Predict(LearnOut, Options, verbose)
% PREDICT Takes an input structure of objects and predicts their classes.
% =========================================================================

addpath('libsvm/matlab/')
addpath('liblinear/matlab/')

if verbose; fprintf('Testing the learned model... '); end

for classifier=Options.ClassificationMethods
    if strcmp(classifier{:}, 'Linear')
        TestOut.(classifier{:}) = LinClassify(LearnOut);
    elseif strcmp(classifier{:},'SVM')
        TestOut.(classifier{:}) = SVMClassify(LearnOut,Options);
    elseif strcmp(classifier{:},'LR')
        TestOut.(classifier{:}) = LRClassify(LearnOut,Options);
    end
end

if verbose; fprintf('Done.\n'); end

end
