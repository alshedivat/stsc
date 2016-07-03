function PrepareDataset
% PREPAREDATASET Prepares the dataset of images by downsizing them to 16x16
%                and retrieving a subset.
% =============================================================================

%%% MNIST
load('../data/MNIST')

SampleNum = length(gnd);
fea_new = zeros(SampleNum,16*16);
fea = mat2gray(fea);

for i=1:SampleNum
    if mod(i,1000) == 0; disp(strcat('Sample_', int2str(i))); end;
    X = reshape(fea(i,:),28,28)';
    Y = imresize(X, [16 16]);
    fea_new(i,:) = reshape(Y,1,16*16);
end

fea = mat2gray(fea_new);
save('../data/MNIST_16x16', 'fea', 'gnd');
clear all;

%%% USPS
load('../data/USPS')
gnd = gnd - 1;

SampleNum = length(gnd);
fea_new = zeros(SampleNum,16*16);

for i=1:SampleNum
    if mod(i,1000) == 0; disp(strcat('Sample_', int2str(i))); end;
    X = reshape(fea(i,:),16,16)';
    fea_new(i,:) = reshape(X,1,16*16);
end

fea = mat2gray(fea_new);
save('../data/USPS_16x16', 'fea', 'gnd');
clear all;

%%% Arabic
load('../data/Arabic')

SampleNum = length(gnd);
fea_new = zeros(SampleNum,16*16);
fea = mat2gray(fea);

for i=1:SampleNum
    if mod(i,1000) == 0; disp(strcat('Sample_', int2str(i))); end;
    X = reshape(fea(i,:),28,28);
    Y = imresize(X, [16 16]);
    fea_new(i,:) = reshape(Y,1,16*16);
end

fea = mat2gray(fea_new);
save('../data/Arabic_16x16', 'fea', 'gnd');

end
