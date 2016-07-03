% Construct Arabic digits dataset
clear; clc;
fea = zeros(70000,28*28);
gnd = zeros(70000,1);
i = 1;

train_path  = '../../MADBase_TrainingSet';
train_parts = dir(train_path);
train_parts = train_parts(3:end);

for part_name={train_parts.name}
    folder = sprintf('%s/%s',train_path, part_name{1});
    imgs = dir(folder); imgs = imgs(3:end);
    for img_name={imgs.name}
        im = imcomplement(imread(sprintf('%s/%s',folder,img_name{1})));
        im = reshape(im,1,28*28);
        fea(i,:) = im;
        gnd(i) = img_name{1}(end-4) - double('0');
        i = i + 1;
    end
end

test_path  = '../../MADBase_TestingSet';
test_parts = dir(train_path);
test_parts = test_parts(3:end);

for part_name={test_parts.name}
    folder = sprintf('%s/%s',test_path, part_name{1});
    imgs = dir(folder); imgs = imgs(3:end);
    for img_name={imgs.name}
        im = imcomplement(imread(sprintf('%s/%s',folder,img_name{1})));
        im = reshape(im,1,28*28);
        fea(i,:) = im;
        gnd(i) = img_name{1}(end-4) - double('0');
        i = i + 1;
    end
end
