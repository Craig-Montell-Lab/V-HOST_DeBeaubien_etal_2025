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

%% Calculate Raw PI
% This calculates the preference index from all observations WITHOUT
% filtering for host-seeking behaviors
raw_z1 = (sum(inpolygon(all_cords(:,1),all_cords(:,2),X(1:4),Y(1:4)))); 
raw_z2 = (sum(inpolygon(all_cords(:,1),all_cords(:,2),X(5:8),Y(5:8))));
raw_PI = round((raw_z2-raw_z1)/(raw_z2+raw_z1),2);



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
round(size(final_pts,1)/((end_time-start_time)*FR),2);
SeekingScore = round(size(final_pts,1)/((end_time-start_time)*FR),2);
ActivityScore = round((raw_z1+raw_z2)/((end_time-start_time)*FR),2);

% Setup file output path
outfile = strcat(output, '.mat');
outpath = strcat(pwd,'/',output,'/',outfile);

% Generate and save representative images
if repimage_logical == 1
    makeImages
else
end

% Generate and save representative videos
if repvideo_logical == 1
    makeVideos
else
end

%% Prints analysis results
% This value is the total distribution of mosquito observations across zone
% 1 and zone 2 WITHOUT any filtering for walking/probing
Overall_Preference_Index = raw_PI;
disp('Overall Preference Index (OPI) for Zone 2 versus Zone 1:')
Overall_Preference_Index

% This value is the total number of mosquito obervations WITHOUT any
% filtering for walking/probing
Overall_Activity_Index = ActivityScore;
disp('Overall Activity Index (OAI):')
Overall_Activity_Index

Movement_Preference_Index = newPI;
disp('Movement Preference Index (MPI) for Zone 2 versus Zone 1:')
Movement_Preference_Index

Movement_Index = SeekingScore;
disp('Movement Index (MI):')
Movement_Index
save(outpath);

%Closes any figure windows
close all
