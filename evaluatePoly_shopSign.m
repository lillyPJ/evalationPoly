% evaluatePoly_shopSign
clear all;

%% dirs and files
testDataBase = '/home/lili/datasets/VOC/VOCdevkit/shopSign/';
testListName = fullfile(testDataBase, 'ImageSets/Main/test.txt');
imgDir = fullfile(testDataBase,'JPEGImages');
[imgName] = textread(testListName,'%s');
gtDir = '/home/lili/datasets/shopSignPoly/gt/test/txt/poly';
dtDir = '/home/lili/codes/ssd/caffe-ssd/data/shopSign/test_poly';
%% process each image
nImg = length(imgName);
for i = 1: nImg
    gtFile = fullfile(gtDir, [imgName{i}, '.txt']);
    dtFile = fullfile(dtDir, ['res_', imgName{i}, '.txt']);
    gtPoly = importdata(gtFile);
    dtPoly = importdata(dtFile);
    
end