% change test_bb to test_poly
% char box
%% dir and files
testBase = '/home/lili/codes/ssd/caffe-ssd/data/shopSign';
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
    [x1, y1, x2, y2, score] = textread(sourceTestFile,'%d,%d,%d,%d,%f');
    box = [x1, y1, x2, y2];
    % change box to polys
    polys = [];
    if ~isempty(box)
        box(:,3) = box(:,3) - box(:,1);
        box(:,4) = box(:,4) - box(:,2);
        charWords = mySelectGroup(box);
        nWord = length(charWords);
        % get poly
        for j = 1:nWord
            charBox = charWords(j).charbox;
            %displayBox([charBox, j*ones(size(charWords(j).charbox, 1), 1)], 'g', 'u');
            gtP = getCornerPoints(charBox);
            poly = minBoundingBox(gtP);
            %displayEightBox(poly,'b');
            polys = [polys; ceil(poly(:))'];
        end
    end
    % write to destTestFile
    fp = fopen(destTestFile, 'wt');
    nPoly = size(polys, 1);
    for j = 1:nPoly
        fprintf(fp, '%d, %d, %d, %d, %d, %d, %d, %d\n', polys(j,:));
    end
    fclose(fp);
end

