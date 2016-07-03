% Perform TLR sweeps for various methods
matlabpool local 8

%%
addpath('utils/')
cv = 4;

param_names = {'TargetLabeledRatio'};
param_vals  = allcomb(0.00:0.01:0.10);

Config = GetConfiguration('PCA');
TLR_PCA = MeasurePerformance(Config, param_names, param_vals, cv, 101, true);
save('../results/TLR_PCA_USPS_MNIST.mat', 'TLR_PCA', 'param_vals');

%%
matlabpool close
exit;

