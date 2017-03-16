% evaluate_MSRAChi_multi
% imgfile(0001.jpg)
% gtfile(0001.txt): x1, y1, x2, y2, "XXX"
% dtfile(0001.txt): x1, y1, x2, y2, "XXX"
% 
function evaluate_FasterRCNN

DISPLAY = 0;%show each

%% dirs and files

imgDir = '/home/lili/datasets/img/test'; %!!!
gtDir = '/home/lili/codes/ssd/caffe-ssd/data/gt/test/txt'; %!!!
dtDir = '/home/lili/datasets/img/test'; %!!!

%% process each image
imgFiles = dir(fullfile(imgDir, '*.jpg'));
nImg = length(imgFiles);
for i = 1: nImg
    imgRawName = imgFiles(i).name;
    gtFile = fullfile(gtDir, [imgRawName(1:end-3), 'txt']); %!!! 
    dtFile = fullfile(dtDir, [imgRawName(1:end-3), 'txt']); %!!!
    gtBox = loadGTFromTxtFile(gtFile);
    dtBox = loadGTFromTxtFile(dtFile);
    gtBox = changeBox2ToBox1(gtBox);
    dtBox = changeBox2ToBox1(dtBox);
    
    [recall, precision, fscore, evalInfo(i)] = evalDetBox03(dtBox, gtBox);
    
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
end

%% ==================loadGTFromTxtFile================
function [box, tag, word] = loadGTFromTxtFile( gtFile )
% box = [X,Y,W,H];
% tag = {'ab','ac'};
% word(i).box = [x, y, w, h];   word(i).tag = { 'abc' };
fdata = importdata( gtFile );
%fdata = textscan(gtFile,'%s','delimiter','\n');
numWord = size(fdata, 1);
box = zeros( numWord, 4 );
tag = cell( numWord, 1 );
for j = 1:numWord
    fstring = fdata{j};
    fstringCell = regexp( fstring, '"', 'split' );
    fboxCell = regexp( fstringCell{1}, ',', 'split' );
    if  ( length( fboxCell) < 4  )
        fboxCell = regexp( fstringCell{1}, '\s+', 'split' );
    end
    box(j, : ) = [ str2double(fboxCell{1}), str2double(fboxCell{2}) ...
                        str2double(fboxCell{3}), str2double(fboxCell{4}) ];
    tag(j) = fstringCell(2);
end
word = struct( 'box', mat2cell( box, ones( numWord, 1), 4), 'tag', tag);
end

%% ==================loadGTFromTxtFile================
function box1 = changeBox2ToBox1(box2)
% box2: [x, y, w, h]
% box1: [x1, y1, x2, y2]

box1 = box2;
if isempty(box2)
    return;
end

box1(:, 3) = box1(:, 3) - box1(:, 1);
box1(:, 4) = box1(:, 4) - box1(:, 2);
end

%% ==================loadGTFromTxtFile================
function displayBox(box, color, pos, dimscore)
m = size(box,  1);
showScore = 0;
if nargin == 1
    color = 'g';
else if nargin > 2 
        showScore = 1;
        if nargin < 4
            dimscore = 5;
        end
    end
end
for i = 1:m
    rectangle('position', box(i, 1:4), 'edgecolor', color, 'linewidth', 2);
    if( showScore )
        switch(pos)
            case 'u'
                text(box(i, 1)+box(i, 3)/2-10, box(i, 2)-10, sprintf('%.2f', box(i, dimscore)), 'BackgroundColor', 'w', 'Color', 'm', 'FontWeight', 'demi');
            case 'm'
                text(box(i, 1)+box(i, 3)/2-10, box(i, 2)+box(i, 4)/2, sprintf('%.2f', box(i, dimscore)), 'BackgroundColor', 'w', 'Color', 'r', 'FontWeight', 'demi');
            case 'd'
                text(box(i, 1)+box(i, 3)/2-10, box(i, 2)+box(i, 4)-10, sprintf('%.2f', box(i, dimscore)), 'BackgroundColor', 'w', 'Color', 'b', 'FontWeight', 'demi');
            otherwise
        end
    end
    
end
end