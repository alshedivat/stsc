function Config = GetConfiguration(config_name, source_name, target_name)
% GETCONFIGURATION Gets one of the predefined configurations.
%   INPUT:  configuration name
%   OUTPUT: options structure
% =========================================================================

Config = [];
Config.name = config_name;

% Data parameters
Config.SourceTrainNumEachClass = 50;
Config.TargetTrainNumEachClass = 50;
Config.TargetLabeledRatio = 0.05;
Config.SourceTestNumEachClass = 100;
Config.TargetTestNumEachClass = 100;

if ~exist('source_name','var'); source_name = 'USPS_16x16'; end;
if ~exist('target_name','var'); target_name = 'MNIST_16x16'; end;
Config.SourceDataset = source_name;
Config.TargetDataset = target_name;
Config.LearningStyle = 'supervised';

% Other parameters general for all the methods
Config.PCA_var=98;
Config.CodebookSize=128;
Config.g=1;

%% BASELINE METHODS
if strcmp(config_name, 'NoLearn')
    Config.LearningMode='none';
    Config.ClassificationMethods={'LR','SVM'};
    Config.c=100;
end
if strcmp(config_name, 'PCA')
    Config.LearningMode='pca_only';
    Config.ClassificationMethods={'LR','SVM'};
    Config.PCA_var=98;   % The percentage of variance used after PCA
    Config.c=1;
end
if strcmp(config_name, 'SC')
    Config.LearningMode='separate';
    Config.ClassificationMethods={'LR','SVM'};
    Config.TransMethod='';   % Can be set to 'EachClass'
    Config.c=[0.01 0.1 1 10 100];
    Config.d=1;              % Coding coefficient
    Config.e=0.1;            % Regularization coefficient (sparsity)
    Config.f=0;              % MMD coefficient
    Config.h=0;              % GraphLaplacian coefficient
    Config.p=1;              % Nearest neighbors number for GraphLaplacian
    Config.MaxIter=40;
end
if strcmp(config_name, 'TSC')
    Config.LearningMode='separate';
    Config.ClassificationMethods={'LR','SVM'};
    Config.TransMethod='';   % Can be set to 'EachClass'
    Config.c=[0.01 0.1 1 10 100];
    Config.d=1;              % Coding coefficient
    Config.e=0.1;            % Regularization coefficient (sparsity)
    Config.f=1.0*1e5;        % MMD coefficient
    Config.h=1;              % GraphLaplacian coefficient
    Config.p=5;              % Nearest neighbors number for GraphLaplacian
    Config.MaxIter=100;
end
if strcmp(config_name, 'TSC+EC')
    Config.LearningMode='separate';
    Config.ClassificationMethods={'LR','SVM'};
    Config.TransMethod='EachClass';
    Config.c=[0.01 0.1 1 10 100];
    Config.d=1;              % Coding coefficient
    Config.e=0.1;            % Regularization coefficient (sparsity)
    Config.f=1.0*1e5;        % MMD coefficient
    Config.h=1;              % GraphLaplacian coefficient
    Config.p=5;              % Nearest neighbors number for GraphLaplacian
    Config.MaxIter=100;
end

%% STSC METHODS
% +SVM
if strcmp(config_name, 'TSC+SVM')
    Config.LearningMode='simultaneous';
    Config.LearningMethod='SVM';
    Config.ClassificationMethods={'Linear','LR','SVM'};
    Config.TransMethod='';   % Can be set to 'EachClass'
    Config.a=0.2;            % SVM term weight
    Config.C=1;              % SVM C parameter
    Config.c=[0.01 0.05 0.1 0.5 1 5 10 50 100 250 500 1000];
    Config.d=1;              % Coding coefficient
    Config.e=0.1;            % Regularization coefficient (sparsity)
    Config.f=1.0*1e4;        % MMD coefficient
    Config.h=1;              % GraphLaplacian coefficient
    Config.p=5;              % Nearest neighbors number for GraphLaplacian
    Config.PreIter=10;
    Config.MaxIter=100;
    Config.SLInterval=1;
end
if strcmp(config_name, 'TSC+EC+SVM')
    Config.LearningMode='simultaneous';
    Config.LearningMethod='SVM';
    Config.ClassificationMethods={'Linear','LR','SVM'};
    Config.TransMethod='EachClass';
    Config.a=0.9;            % SVM term weight
    Config.C=1;              % SVM C parameter
    Config.c=[0.01 0.1 1 10 100];
    Config.d=1;              % Coding coefficient
    Config.e=0.1;            % Regularization coefficient (sparsity)
    Config.f=0.5*1e4;        % MMD coefficient
    Config.h=1;              % GraphLaplacian coefficient
    Config.p=5;              % Nearest neighbors number for GraphLaplacian
    Config.PreIter=10;
    Config.MaxIter=100;
    Config.SLInterval=1;
end

end
