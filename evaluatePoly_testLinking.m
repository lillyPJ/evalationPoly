% evaluatePoly_shopSign
clear all;
DISPLAY = 0;

%% dirs and files
datasetName = 'MSRATD500';
imgDataBase = '/home/lili/datasets/';
ssdDataBase = '/home/lili/codes/ssd/caffe-ssd/data';
imgDir = fullfile(imgDataBase, datasetName, 'img', 'test');
gtDir = fullfile(imgDataBase, datasetName, 'gt', 'test', 'txt', 'polyTextline');
dtDir = fullfile(ssdDataBase, datasetName, 'test_poly');
dtDir = '/home/lili/codes/testLinking/boxWord';
logFile = fullfile(dtDir, '..', 'testLog.txt');
fp = fopen(logFile, 'wt');
%% process each image
imgFiles = dir(fullfile(imgDir, '*.jpg'));
nImg = length(imgFiles);
%nImg = 50;
for i = 1: nImg
    %     if i < 13
    %         continue;
    %     end
    imgRawName = imgFiles(i).name;
    gtFile = fullfile(gtDir, [imgRawName(1:end-3), 'txt']);
    dtFile = fullfile(dtDir, ['res_', imgRawName(1:end-3), 'txt']);
    gtPoly = [];
    dtPoly = [];
    gtPoly = importdata(gtFile);
    
    dtPoly = importdata(dtFile);
    
    [recall, precision, fscore, evalInfo(i)] = evalDetPoly(dtPoly, gtPoly);
    
    % show image and poly
    %     cla;
    if DISPLAY
        image = imread(fullfile(imgDir, imgRawName));
        imshow(image);
        displayPoly(gtPoly, 'r');
        displayPoly(dtPoly, 'g');
    end
    fprintf('%d:%s:\n', i, imgRawName);
    fprintf('recall = %.3f, precision = %.3f, f-score = %.3f\n', recall, precision, fscore);
    
    fprintf(fp, '%d:%s:\n', i, imgRawName);
    fprintf(fp, 'recall = %.3f, precision = %.3f, f-score = %.3f\n', recall, precision, fscore);
    
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
fprintf(fp, '\nrecall = %.3f, precision = %.3f, fmeasure = %.3f\n', recall, precision, fscore);
fclose(fp);