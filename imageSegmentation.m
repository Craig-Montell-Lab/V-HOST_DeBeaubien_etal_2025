function [BW] = imageSegmentation(X, erode, sens)
%segmentImage Segment image using auto-generated code from imageSegmenter app
%  [BW,MASKEDIMAGE] = segmentImage(X) segments image X using auto-generated
%  code from the imageSegmenter app. The final segmentation is returned in
%  BW, and a masked image is returned in MASKEDIMAGE.

% Auto-generated by imageSegmenter app on 03-Jul-2019
%----------------------------------------------------


% Threshold image - adaptive threshold
BW = imbinarize(X, 'adaptive', 'Sensitivity', sens, 'ForegroundPolarity', 'dark');

% Erode mask with disk
radius = erode;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imerode(BW, se);

BW = imerode(BW, se);
end

