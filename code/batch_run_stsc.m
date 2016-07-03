addpath('utils/')
matlabpool local 8
cv = 1;

%% STSC METHODS
% +SVM
% Get configuration
config = GetConfiguration('TSC+SVM')

% Parameters search grid
param_names = {'a', 'e', 'f', 'TargetTrainNumEachClass'};
a = [0.05 0.1 0.15 0.2];
e = [0.1];
f = [1 10 100]*1e4;
TTNEC = [5];
param_vals = allcomb(a, e, f, TTNEC);

% Conduct all the measurments
Performances = MeasurePerformance(config, param_names, param_vals, cv, ...
                                  42, true, false);
save('../results/STSC_param_search', ...
     'Performances', 'param_names', 'param_vals');

%%
matlabpool close
exit;
