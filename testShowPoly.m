% testShowPoly
clear all;

%% dirs and files
datasetName = 'MSRATD500';
imgDataBase = '/home/lili/datasets/';
ssdDataBase = '/home/lili/codes/ssd/caffe-ssd/data';
imgDir = fullfile(imgDataBase, datasetName, 'img', 'test');
gtDir = fullfile(imgDataBase, datasetName, 'gt', 'test', 'txt', 'polyTextline');
dtDir = fullfile(ssdDataBase, datasetName, 'test_poly');
dtDir = '/home/lili/codes/testLinking/boxWord';
%% process each image
imgFiles = dir(fullfile(imgDir, '*.jpg'));
nImg = length(imgFiles);
for i = 1: nImg
%     if i < 5
%         continue;
%     end
    imgRawName = imgFiles(i).name;
    fprintf('%d:%s\n', i, imgFiles(i).name);
    
    gtFile = fullfile(gtDir, [imgRawName(1:end-3), 'txt']);
    dtFile = fullfile(dtDir, ['res_', imgRawName(1:end-3), 'txt']);
    gtPoly = importdata(gtFile);
    dtPoly = importdata(dtFile);
    angleBoxes = fromPolyToAngleBox(dtPoly);
    % show image and poly
    image = imread(fullfile(imgDir, imgRawName));
    imshow(image);
%     displayEightPoly(gtPoly, 'r');
%     displayEightPoly(dtPoly, 'g');
    displayAngleBox(angleBoxes);
end