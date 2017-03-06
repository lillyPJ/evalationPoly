% change test_bb to test_poly
% test_bb: x, y, w, h
% test_poly: x1, y1, x2, y2, x3, y3, x4, y4
%% dir and files
testDataBase = '/home/lili/datasets/VOC/VOCdevkit/MSRATD500/';
testListName = fullfile(testDataBase, 'ImageSets/Main/test.txt');
imgDir = fullfile(testDataBase,'JPEGImages');

testBase = '/home/lili/codes/ssd/caffe-ssd/data/MSRATD500';
sourceDir = fullfile(testBase, 'test_bb');
destDir = fullfile(testBase, 'test_poly');
mkdir(destDir);
%% process each file
files = dir(fullfile(sourceDir, '*.txt'));
nFile = numel(files);

for i = 1:nFile
    sourceTestFile = fullfile(sourceDir, files(i).name);
    destTestFile = fullfile(destDir, files(i).name);
    fprintf('%d:%s\n', i, sourceTestFile);
    % load test box
    [x1, y1, x2, y2, angle, score] = textread(sourceTestFile,'%d,%d,%d,%d,%d,%f');
    box = [x1, y1, x2, y2, angle];
    % change box to polys
    polys = fromAngleBoxToPoly(box);
%     polys = [];
%     if ~isempty(box)
%         box(:,3) = box(:,3) - box(:,1);
%         box(:,4) = box(:,4) - box(:,2);
%         charWords = mySelectGroup(box);
%         nWord = length(charWords);
%         % get poly
%         for j = 1:nWord
%             charBox = charWords(j).charbox;
%             %displayBox([charBox, j*ones(size(charWords(j).charbox, 1), 1)], 'g', 'u');
%             gtP = getCornerPoints(charBox);
%             poly = minBoundingBox(gtP); % x1, x2, x3, x4; y1, y2, y3, y4
%             %displayEightBox(poly,'b');
%             polys = [polys; ceil(poly(:))'];
%         end
%     end
    image = imread(fullfile(imgDir, [files(i).name(5:end-3), 'jpg']));
    displayPoly(polys);
    % write to destTestFile
    fp = fopen(destTestFile, 'wt');
    nPoly = size(polys, 1);
    for j = 1:nPoly
        fprintf(fp, '%d, %d, %d, %d, %d, %d, %d, %d\n', polys(j,:));
    end
    fclose(fp);
end

