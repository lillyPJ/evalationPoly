% evaluatePoly_shopSign
clear all;

%% dirs and files
testDataBase = '/home/lili/datasets/VOC/VOCdevkit/MSRATD500/';
testListName = fullfile(testDataBase, 'ImageSets/Main/test.txt');
imgDir = fullfile(testDataBase,'JPEGImages');
[imgName] = textread(testListName,'%s');
gtDir = '/home/lili/datasets/MSRATD500Poly/gt/test/txt/poly';
dtDir = '/home/lili/codes/ssd/caffe-ssd/data/MSRATD500/test_poly';
%% process each image
nImg = length(imgName);
for i = 1: nImg
    
    gtFile = fullfile(gtDir, [imgName{i}, '.txt']);
    dtFile = fullfile(dtDir, ['res_', imgName{i}, '.txt']);
    gtPoly = importdata(gtFile);
    dtPoly = importdata(dtFile);
    
    [recall, precision, fscore, evalInfo(i)] = evalDetPoly(dtPoly, gtPoly);
    
    % show image and poly
    image = imread(fullfile(imgDir, [imgName{i}, '.jpg']));
%         imshow(image);
%         displayPoly(gtPoly, 'r');
%         displayPoly(dtPoly, 'g');
    fprintf('%d:%s:\n', i, imgName{i});
    fprintf('recall = %.3f, precision = %.3f, f-score = %.3f\n', recall, precision, fscore);
    
end
% total
recall =  sum( [evalInfo.tr] ) / sum( [evalInfo.nG] );
precision = sum( [evalInfo.tp] ) / sum( [evalInfo.nD] );
if recall + precision > 0
    fscore = 2 * recall * precision / (recall + precision);
else
    fscore = 0;
end
fprintf('\nrecall = %.3f, precision = %.3f, fmeasure = %.3f\n', recall, precision, fscore);
