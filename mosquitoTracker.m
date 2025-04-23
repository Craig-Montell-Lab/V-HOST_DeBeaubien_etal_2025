%% TRACKING PARAMETERS 

% Clear extraneous workspace variables
clearvars -except ExpID X Y ExpList OutList ExpName OutName ExperimentLog Range;

% Load user defined variables
userVariables

% Generates file_name and output variables
file_name = ExpName;
output = OutName;

% Initializes the video reader object (v)
v = VideoReader(file_name);

% Makes the output directory and adds it to the current directory
mkdir(output);
addpath(genpath(output));
    
%% SET TIME FOR ANALYSIS
% This assumes that the experiment is analyzed for the first 3000 frames
% (5 minutes at 10 fps), but can be adjusted to meet your needs
TotalTime = num2str(round(v.Duration));

% Calculated the analysis duration in frames
period = end_time*FR - start_time*FR;
Final = period;

% Set current time to 0
v.CurrentTime = 0;   

% Calculates the total number of frames in the video
nFrames = ceil(v.FrameRate*v.Duration);

%% Video Analysis

% Resets video to first frame
v.CurrentTime = start_time;                                           

% Preallocate Data
cords = cell(1,nFrames);

% Preallocate Data    
allBlobAreas = NaN(1,max_expected_blobs);
allowableAreaIndexes = NaN(1,max_expected_blobs);
keeperIndexes = NaN(1,max_expected_blobs);
dots = NaN(max_expected_blobs,2);

% Loops through each frame and collects object tracking data
for k = 1:Final
    % Reads video frame
    im = readFrame(v);
    
    % Converts frame image to grayscale
    im = rgb2gray(im);
    
    % Performs image thresholding. This can either be modified to work for your
    % experiment settings or a new thresholding script can be made that is more
    % suited to your configuration using the Image Segmenter Toolbox
    [BW] = imageSegmentation(im,erode,sens); %Generates segmented image

    % Invert threshold image
    BW_inv = ((BW-1)*-1) == 1; 
    
    % Detects objects in the thresholded image      
    blobs = regionprops(BW_inv);
            
    % Filters blobs according to the user defined blob areas
    allBlobAreas = [blobs.Area];
    allowableAreaIndexes = (allBlobAreas > sizes(1)) & (allBlobAreas < sizes(2));
    keeperIndexes = find(allowableAreaIndexes);
            
    % Collects the centroid positions of acceptably sized blobs      
    dots = vertcat(blobs.Centroid);
    dots = dots(keeperIndexes,:);
    cords(k) = {dots};
    
    % Resets arrays to capture next frame
    allBlobAreas = NaN(1,max_expected_blobs);
    allowableAreaIndexes = NaN(1,max_expected_blobs);
    keeperIndexes = NaN(1,max_expected_blobs);
    dots = NaN(max_expected_blobs,2);       
end

% Removes any unused 
cords(k+1:end) = [];
all_cords = vertcat(cords{:});        

%% Perform Track Analysis
% This code goes through each frame and uses knnsearch to match coordinates
% together to reconstruct trajectories

[trax_X,trax_Y,track_data,track_set] = trackFinder(X, Y, cords, FR, speed);

%% Remove Stationary Mosquitoes
% This code removes stationary (non host-seeking) mosquitoes from the
% analyzed data
[newPI, final_pts, point_distance] = statRemover(track_set, trax_X, trax_Y, X, Y, fsize, framelimit);

%% Output File Handling

%Prepeares output data
round(size(final_pts,1)/(end_time*FR),2);
SeekingScore = round(size(final_pts,1)/(end_time*FR),2);

% Setup file output path
outfile = strcat(output, '.mat');
outpath = strcat(pwd,'/',output,'/',outfile);

% Generate and save representative images
if repimage_logical == 1
    makeImages
else
end

% Prints analysis results
Preference_Index = newPI;
disp('Preference for Zone 2 versus Zone 1 (Preference Index):')
Preference_Index

Host_Seeking_Index = SeekingScore;
disp('Average # Host Seeking Mosquitoes per Frame (Host Seeking Index):')
Host_Seeking_Index
save(outpath);

%Closes any figure windows
close all
