%% This section contains the user defined variables which change tracking performance
% We have indicated settings we used next to the variable as reference

%% Image Segmentation
%__________________________________________________________________________
% Thresholding/Image segmentation parameters are contained here. These
% variables affect the performance of segmentImage5v1.m. If you would like
% to design a new image segmentation script please use the Image Segmenter
% App
% (https://www.mathworks.com/help/images/image-segmentation-using-the-image-segmenter-app.html)

% Dilates binary masks, this will change how large or small your blobs are
erode = 2; % erode = 2;
radius = 2; % radius = 2;
decomposition = 0; % decomposition = 0;

% This determines the adaptive thresholding sensitivity
sens = 0.29; % sens = 0.29

% Defines the blob sizes of landed mosquitoes (this will depend on experiment
% illumination, camera, and thresholding settings. Modify this body size
% range accordingly for your individual experiment conditions).
sizes = [140 320];  %size = [140 320]

% Set the maximum number of expected mosquitoes (e.g. each of our cages
% contained 80 mosquitoes)
max_expected_blobs = 80; %max_expected_blobs = 80;

% Make representative images? (1 = yes, 0 = no)
repimage_logical = 0; %repimage_logical = 0;

number_of_images = 250; %number_of_images = 250;

%% Mosquito Movement
%__________________________________________________________________________
% These settings determine the cutoff values for mosquitoes which are
% analyzed. These should be adjusted depending on your experiment
% conditions.

% Maximum movement speed - the cutoff of mosquitoes of interest
% (landed/walking mosquitoes move much slower than flying mosquitoes, value in
% pixels/frame)
speed = 10; %speed = 10;

% Minimum movement speed - This is the minimum movement (pixels/frame) for
% a mosquito to be considered actively host seeking.
fsize = 0.5; % fsize = 0.5;

% Minimum track duration - the minimum number of frames the trajectory must
% be to be used for analysis
framelimit = 4; % framelimit = 4;

%% Video Information
%__________________________________________________________________________
% Video Frame Rate (adjust if using a camera with different acquisition
% rate)
FR = 10; %FR = 10;

% Analysis start time (s)
start_time = 0; %start_time = 0;

% Analysis end time (s)
end_time = 300; %end_time = 300;

