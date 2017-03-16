% evaluate_MSRAChi_multi
clear all;

DISPLAY = 1;
MULTI = 1; %1-multi, 0-single
SCORESHOLD = 0.1;

%% dirs and files
datasetName = 'CASIA';
dtDirName = 'multi1_200k';

imgDataBase = '/home/lili/datasets/';
ssdDataBase = '/home/lili/codes/ssd/caffe-ssd/data';
imgDir = fullfile(imgDataBase, datasetName, 'img', 'test');
gtDir = fullfile(imgDataBase, datasetName, 'gt', 'test', 'txt');
dtDir = fullfile(ssdDataBase, datasetName, dtDirName, 'test_bb');
%dtDir = '/home/lili/codes/testLinking/boxWord';
%% process each image
imgFiles = dir(fullfile(imgDir, '*.jpg'));
nImg = length(imgFiles);
%nImg = 50;
for i = 1: nImg
%         if i < 20
%             continue;
%         end
    imgRawName = imgFiles(i).name;
    gtFile = fullfile(gtDir, [imgRawName(1:end-3), 'txt']);
    dtFile = fullfile(dtDir, ['res_', imgRawName(1:end-3), 'txt']);
    gtBox = [];
    dtBox = [];
    gtBox = loadGTFromTxtFile(gtFile);
    
    dtBox = importdata(dtFile);
    dtBox = changeBox2ToBox1(dtBox);
    % threshold
    if ~isempty(dtBox)
        dtBox = dtBox(dtBox(:, 5) > SCORESHOLD, :);
    end
    if MULTI
        dtBox = myNms2(dtBox, 1.3, 0.7, 0.5);
    else
        dtBox = myNms(dtBox, 0.25);
    end
    
    [recall, precision, fscore, evalInfo(i)] = evalDetBox03(dtBox, gtBox);
    
    % show image and poly
    %     cla;
    if DISPLAY
        image = imread(fullfile(imgDir, imgRawName));
        imshow(image);
        displayBox(gtBox, 'r');
        %displayBox(dtBox, 'g');
        displayBox(dtBox, 'g', 'u', 5);
    end
    fprintf('%d:%s:\n', i, imgRawName);
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
