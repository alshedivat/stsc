function [Input_Train, Input_Test] = SampleData(Config, seed, verbose, save_fl)
% SAMPLEDATA Samples the working train and test sets.
%   INPUT: - DataOptions: the data options structure
%          - seed: random seed
%          - save_fl: whether to save the sample datasets into a file
%                     (filename is '../data/DataDigits.mat')
%          - verbose: if true, it plots the graphs of train and test sets
% =========================================================================
if ~exist('verbose', 'var'); verbose = false; end
if ~exist('save_fl', 'var'); save_fl = false; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If the dataset has been already sampled and saved just load it
if isfield(Config,'DataFile')
    load(Config.DataFile)
    Input_Train.Features  = full(Input_Train.Features);
    Input_Train.DomainIdx = full(Input_Train.DomainIdx);
    Input_Train.Labels    = full(Input_Train.Labels);
    Input_Train.Labeled   = full(Input_Train.Labeled);

    Input_Test.Features   = full(Input_Test.Features);
    Input_Test.DomainIdx  = full(Input_Test.DomainIdx);
    Input_Test.Labels     = full(Input_Test.Labels);
    Input_Test.Labeled    = full(Input_Test.Labeled);

    for Label=unique(Input_Train.Labels)
        LabelIdx = find(Input_Test.Labels == Label);
        idx = randperm(length(LabelIdx));
        Input_Test.Labeled(idx(1:Config.TargetTrainNumEachClass)) = 1;
    end

else

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set seed for the global random stream

s = RandStream('mcg16807','Seed',seed);
RandStream.setGlobalStream(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load the source domain data
load(sprintf('../data/%s',Config.SourceDataset))

if isfield(Config,'Labels')
    LabelList = Config.Labels;
else
    LabelList = unique(gnd);
end

% Select SourceNumEachClass elements from each class for the source domain
IdxTrain = [];
IdxTest  = [];
for Label = LabelList'
    I = find(gnd == Label);
    Num = size(I,1);
    Idx = randperm(Num);
    IdxTrain = [IdxTrain I(Idx(1:Config.SourceTrainNumEachClass))'];
    IdxTest  = [IdxTest  I(Idx(Config.SourceTrainNumEachClass+1:...
                           Config.SourceTrainNumEachClass+...
                           Config.SourceTestNumEachClass))'];
end

SourceTrainNum = length(IdxTrain);
SourceTestNum = length(IdxTest);

Input_Train.Features  = fea(IdxTrain,:)';
Input_Train.DomainIdx = ones(1,SourceTrainNum);
Input_Train.Labels    = gnd(IdxTrain)';
Input_Train.Labeled   = ones(1,SourceTrainNum);

Input_Test.Features  = fea(IdxTest,:)';
Input_Test.DomainIdx = ones(1,SourceTestNum);
Input_Test.Labels    = gnd(IdxTest)';
Input_Test.Labeled   = zeros(1,SourceTestNum);

clear fea gnd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load the target domain data
load(sprintf('../data/%s',Config.TargetDataset))

if isfield(Config,'Labels')
    LabelList = Config.Labels;
else
    LabelList = unique(gnd);
end

IdxTrain = [];
IdxTest  = [];
TargetTrainLabeled = [];
LabeledTTLnum = round(Config.TargetTrainNumEachClass *...
                      Config.TargetLabeledRatio);
ULabeledTTLnum = Config.TargetTrainNumEachClass - LabeledTTLnum;
for Label = LabelList'
    I = find(gnd == Label);
    Num = length(I);
    Idx = randperm(Num);
    IdxTrain = [IdxTrain I(Idx(1:Config.TargetTrainNumEachClass))'];
    IdxTest  = [IdxTest  I(Idx(Config.TargetTrainNumEachClass+1:...
                           Config.TargetTrainNumEachClass+...
                           Config.TargetTestNumEachClass))'];
    TargetTrainLabeled = [TargetTrainLabeled...
                          ones(1,LabeledTTLnum) zeros(1,ULabeledTTLnum)];
end

TargetTrainNum = length(IdxTrain);
TargetTestNum = length(IdxTest);

% Add the objects from the target domain to the train set
Input_Train.Features  = [Input_Train.Features fea(IdxTrain,:)'];
Input_Train.DomainIdx = [Input_Train.DomainIdx -ones(1,TargetTrainNum)];
Input_Train.Labels    = [Input_Train.Labels gnd(IdxTrain)'];
Input_Train.Labeled   = [Input_Train.Labeled TargetTrainLabeled];

% Create a test set from the obects of the target domain
Input_Test.Features  = [Input_Test.Features fea(IdxTest,:)'];
Input_Test.DomainIdx = [Input_Test.DomainIdx -ones(1,TargetTestNum)];
Input_Test.Labels    = [Input_Test.Labels gnd(IdxTest)'];
Input_Test.Labeled   = [Input_Test.Labeled zeros(1,TargetTestNum)];

clear fea gnd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Store the data as sparse matrices
%{
Input_Train.Features  = sparse(Input_Train.Features);
Input_Train.DomainIdx = sparse(Input_Train.DomainIdx);
Input_Train.Labels    = sparse(Input_Train.Labels);
Input_Train.Labeled   = sparse(Input_Train.Labeled);

Input_Test.Features   = sparse(Input_Test.Features);
Input_Test.DomainIdx  = sparse(Input_Test.DomainIdx);
Input_Test.Labels     = sparse(Input_Test.Labels);
Input_Test.Labeled    = sparse(Input_Test.Labeled);
%}

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot the train and test sets
if verbose
    figure;
    subplot(4,1,1);
    imagesc(Input_Train.Features); colorbar;
    title('Features','FontSize',16);
    subplot(4,1,2);
    imagesc(Input_Train.Labels); colorbar;
    title('Labels','FontSize',16);
    subplot(4,1,3);
    imagesc(Input_Train.DomainIdx); colorbar;
    title('DomainIdx','FontSize',16);
    subplot(4,1,4);
    imagesc(Input_Train.Labeled); colorbar;
    title('Labeled','FontSize',16);

    figure;
    subplot(4,1,1);
    imagesc(Input_Test.Features); colorbar;
    title('Features','FontSize',16);
    subplot(4,1,2);
    imagesc(Input_Test.Labels); colorbar;
    title('Labels','FontSize',16);
    subplot(4,1,3);
    imagesc(Input_Test.DomainIdx); colorbar;
    title('DomainIdx','FontSize',16);
    subplot(4,1,4);
    imagesc(Input_Test.Labeled); colorbar;
    title('Labeled','FontSize',16);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomly shuffle the training and the testing data sets (if any...)
%{
Num = size(Input_Train.Labels,2);
Idx = randperm(Num);
Input_Train.Labels    = Input_Train.Labels(Idx);
Input_Train.Features  = Input_Train.Features(:,Idx);
Input_Train.DomainIdx = Input_Train.DomainIdx(Idx);
Input_Train.Labeled   = Input_Train.Labeled(Idx);

Num = size(Input_Test.Labels,2);
Idx = randperm(Num);
Input_Test.Labels    = Input_Test.Labels(Idx);
Input_Test.Features  = Input_Test.Features(:,Idx);
Input_Test.DomainIdx = Input_Test.DomainIdx(Idx);
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save the data
if save_fl
    save('../data/DataDigits', 'Input_Train', 'Input_Test');
end

end
