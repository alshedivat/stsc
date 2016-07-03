addpath('utils/')
% matlabpool local 12
cv = 1;

%% TSC METHOD
% Get configuration
config = GetConfiguration('TSC')

% Parameters search grid
param_names = {'e', 'f', 'TargetTrainNumEachClass'};
e = [0.1];
f = [10]*1e4;
TTNEC = [5];
param_vals = allcomb(e,f,TTNEC);

% Conduct all the measurments
Performances = MeasurePerformance(config, param_names, param_vals, cv, ...
                                  101, true, false);
save('../results/TSC_param_search', ...
     'Performances', 'param_names', 'param_vals');

%%
% matlabpool close
exit;
