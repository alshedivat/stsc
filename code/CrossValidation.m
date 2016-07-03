function [BestParams, BestAccuracy] = CrossValidation(config, cv, seed, verbose)
% CROSSVALIDATION Performs SingleRun several times with different seeds,
%                 accumulates the accuracy results and returns the average.
% =========================================================================
if ~exist('cv','var'); cv = 10; end
if ~exist('seed','var'); seed = 42; end
if ~exist('verbose','var'); verbose = true; end

% Initialize accuracies
cl_meth = config.ClassificationMethods;
Accuracies = cell(1, cv);   % total accuracy
AccuraciesS = cell(1, cv);  % accuracy on source
AccuraciesT = cell(1, cv);  % accuracy on target

if verbose; fprintf('Cross-validating...\n'); end
parfor i=1:cv
  if verbose; fprintf('  Iteration %d/%d\n',i,cv); end
  RunOutput = SingleRun(config, i*seed);
  for j=1:numel(cl_meth)
    meth = cl_meth{j};
    Accuracies{i}.(meth) = RunOutput.Test.(meth).Accuracy;
    AccuraciesS{i}.(meth) = RunOutput.Test.(meth).AccuracyS;
    AccuraciesT{i}.(meth) = RunOutput.Test.(meth).AccuracyT;
  end
end
if verbose; fprintf('Done.\n'); end

% Compute mean and std for the performed measurements
for j=1:numel(cl_meth)
  meth = cl_meth{j};
  Measurments.(meth) = zeros(cv,length(config.c));
  MeasurmentsS.(meth) = zeros(cv,length(config.c));
  MeasurmentsT.(meth) = zeros(cv,length(config.c));
  for i=1:cv
      Measurments.(meth)(i,:) = Accuracies{i}.(meth);
      MeasurmentsS.(meth)(i,:) = AccuraciesS{i}.(meth);
      MeasurmentsT.(meth)(i,:) = AccuraciesT{i}.(meth);
  end
  Accuracy.(meth) = [mean(Measurments.(meth), 1);...
                           std(Measurments.(meth), 0, 1)];
  AccuracyS.(meth) = [mean(MeasurmentsS.(meth), 1);...
                      std(MeasurmentsS.(meth), 0, 1)];
  AccuracyT.(meth) = [mean(MeasurmentsT.(meth), 1);...
                      std(MeasurmentsT.(meth{j}), 0, 1)];
end

% Choose the best result and set the appropriate parameters
for j=1:numel(cl_meth)
  meth = cl_meth{j};
  [BestAccuracy.(meth), ind] = max(Accuracy.(meth)(1,:));
  [BestAccuracyS.(meth), indS] = max(AccuracyS.(meth)(1,:));
  [BestAccuracyT.(meth), indT] = max(AccuracyT.(meth)(1,:));

  BestAccuracy.(meth) =...
    [BestAccuracy.(meth) BestAccuracyS.(meth) BestAccuracyT.(meth);...
     Accuracy.(meth)(2,ind) AccuracyS.(meth)(2,indS) AccuracyT.(meth)(2,indT)];
  BestParams.(meth) = [config.c(ind) config.c(indS) config.c(indT)];
end

end
