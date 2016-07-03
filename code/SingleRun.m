function RunOutput = SingleRun(config, seed, verbose, LearnOut)
% SINGLERUN Runs one of the sparse coding methods, builds the codebook,
%           tests the classification on a random sample of the data.
% =========================================================================

close all;
if ~exist('seed','var'); seed = 42; end
if ~exist('verbose','var'); verbose = false; end

% Add path to the optimization procedures
addpath('learning');
addpath('optimization');
addpath('classification');

% Display the method and the data parameters for logging purposes
if verbose
    disp('Configuration:');
    disp(config);
end

if ~exist('LearnOut','var')
    % Load the datasets
    [TrainSet,TestSet] = SampleData(config, seed, verbose);

    % Learn the codebook and the sparse codes
    LearnOut = Learn(TrainSet, TestSet, config, verbose);
end

% Test the codebook and the sparse codes
PredictOut = Predict(LearnOut, config, verbose);

% Write output
RunOutput.Train = LearnOut;
RunOutput.Test  = PredictOut;

end
