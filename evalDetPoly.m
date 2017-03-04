function [recall, precision, fscore , evalInfo] = evalDetPoly(dtPoly, gtPoly, varargin)
% To evaluate the detection results
%
% USAGE
% [recall, precision, fscore] = evalDetPoly(dtPoly, gtPoly, varargin)
%
% INPUTS
% - dtPoly
%  	- detection results with each line as a 8-d Poly:
%       [x1, y1, x2, y2, x3, y3, x4, y4]. The total dimension is nD*8
% - gtPoly
%  	- groundTruth Polyes with each line as a 8-d Poly:
%       [x1, y1, x2, y2, x3, y3, x4, y4]. The total dimension is nG*8
% - varargin
%  	- 'overlapThr'[0,1], default = 0.5(HIT criteria)
%     - the threshold of the overlap area. When IOU (intersection / union
%       of the test and the gt Poly) is greater than the threshold, it
%       counts. (HIT criteria)
%     - Especially, when  overlapThr = 0, use the 'NOHIT' criteria.
%  	- 'angleThr'[0,pi], default = pi/8
%
% OUTPUTS
% - recall          - recall of the results
% - precision       - precision of the results
% - fscore
%   - fscore of the results (alpha = 0.5) :
%      fscore = 2 / (1/recall + 1/precision)
% - others
%   - others.nD  = nD, num of detection Poly
%   - others.nG  = nG, num of gt Poly
%   - others.tr    = tr, sum of score of gt
%   - others.tp   = tp, sum of score of detection
%   - others.dt   = dt [x y w h matchScore], column vector with the same size of the detectPoly.
%   - others.gt   = gt [x y w h matchScore], column vector with the same size of the gtPoly.

%
% EXAMPLE
%  dfs = { 'overlapThr', 0.5, 'angleThr', pi/8 };
%  detectPoly = [ 11, 62, 392, 55; 8, 128, 584, 186];
%  gtPoly = [ 9, 130, 581, 180; 12, 65, 309, 50; 349, 68, 238, 47];
%  prm = evalDetPoly(detectPoly, gtPoly, dfs)

%% get parameters
dfs={'overlapThr', 0.5, 'angleThr', pi/8};
params = getPrmDflt(varargin, dfs);
overlapThr = params.overlapThr;
angleThr = params.angleThr;
assert(overlapThr >= 0);
assert(overlapThr <= 1);
assert(angleThr >= 0);
assert(angleThr <= pi);
% check input
if(nargin < 2)
    error('Input must include at least detectPoly and gtPoly !');
end
%% initialization
recall = 0;
precision = 0;
fscore = 0;
nD = size(dtPoly, 1);
nG = size(gtPoly, 1);
evalInfo.empty = true;
evalInfo.nD = nD;
evalInfo.nG = nG;
evalInfo.tr = 0;
evalInfo.tp = 0;
evalInfo.dt = [];
evalInfo.gt = [];
evalInfo.scoreMatrix = [];
if(nD == 0 || nG == 0)
    return;
end

%% change poly(x1,y1, x2, y2,..., x4, y4) to box(x, y, w, h, theta) format
gtAngleBox = fromPolyToAngleBox(gtPoly);
dtAngleBox = fromPolyToAngleBox(dtPoly);
%% seperate box and angle 
gtBox = gtAngleBox(:, 1:4);
gtAngle = gtAngleBox(:, 5);
dtBox = dtAngleBox(:, 1:4);
dtAngle = dtAngleBox(:, 5);

assert(size(gtBox, 2) == 4);
assert(size(dtBox, 2) == 4);

dt = horzcat(dtBox, zeros(nD, 1));
gt = horzcat(gtBox, zeros(nG, 1));
%%  calculate scoreMatrix
scoreMatrix = zeros(nD, nG);
for i=1:nD
    for j=1:nG
        if abs(dtAngle(i) - gtAngle(j)) < angleThr
            scoreMatrix(i, j) = calculateOverlap03(dtBox(i,:), gtBox(j,:));
        else
            scoreMatrix(i, j) = 0;
        end
    end
end
%% assign detection
for i=1:nD
    dt(i, 5) = max(scoreMatrix(i, :));
end
%% assign gt
for j=1:nG
    gt(j, 5) = max(scoreMatrix(:, j));
end
%% calculate the criterion
if overlapThr > 0  % HIT
    ind = (dt(:, 5) > overlapThr);
    dt(ind, 5) = 1;
    dt(~ind, 5) = 0;
    ind = (gt(:, 5) > overlapThr);
    gt(ind, 5) = 1;
    gt(~ind, 5) = 0;
end
tr = sum(gt(:, 5));
tp = sum(dt(:, 5));
recall = tr / nG * 100;
precision = tp / nD * 100;
fscore = 2/(1/recall + 1/precision);
% all results;
if(nargout > 3)
    evalInfo.empty = false;
    evalInfo.nD  = nD;
    evalInfo.nG  = nG;
    evalInfo.tr    = tr;
    evalInfo.tp   = tp;
    evalInfo.dt   = dt;
    evalInfo.gt   = gt;
    evalInfo.scoreMatrix = scoreMatrix;
end
