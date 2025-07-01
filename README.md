# V-HOST_DeBeaubien_etal_2025


======================
INSTALLING V-HOST
======================

This code requires a MATLAB installation with the Image Processing Toolbox and Statistics and Machine Learning Toolbox.

For MATLAB system requirements please visit: https://www.mathworks.com/support/requirements/matlab-system-requirements.html

This code has been tested on Windows and Mac operating systems. This code has been tested on MATLAB versions R2019a and later.

Installation Guide
1. Install MATLAB along with Image Processing Toolbox and Statistics and Machine Learning Toolbox. MATLAB installation time will vary depending on machine. For more detailed description of MATLAB installs please visit mathworks.com.
2. Download the V-HOST folder from GitHub.
3. Set the V-HOST folder as your current folder (directory) in MATLAB.
4. No further installation required.

======================
ANALYZING EXPERIMENTS
======================

Run the following commands to analyze a new set of experiments.

1. Add videos to the V-HOST folder

	Experiment videos must be in the V-HOST path for them to be recognized by MATLAB. You can make a subfolder in V-HOST to contain videos (e.g. a folder called "videos"), but you must ensure you also add this subfolder to the MATLAB path. 

2. Command: addExperiments
	
	This will load a dialog box where you can append experiments to your ExperimentLog.m file. If this file does not already exist, a new one will be created. This is where you will store a unique experiment ID for that video (e.g. IR_134), information about the corresponding video (e.g. IR_134.mov), and the name of the folder where analysis outputs will be saved (e.g. IR_134_analysis). Enter your information in the fields and press "Add to Experiment List". When you are finished entering experiments press "Finished Entering Exps". This will close the dialog box. Once you have begun building your Experiment Log you can continually add to it as you generate new experiments (with the command addExperiments), do not delete ExperimentLog.mat or this information will be lost.

3. Command: zoneCapture

	This will loop through all the entries of ExperimentLog.mat and find experiments where you have not yet captured zone information. It will then load an image from that experiment and allow you to select the corners of your zones of interest. The code is written to analyze two zones. To accurately capture zone information you should:

	1. Select the four corners of the first zone in a clockwise fashion (4 clicks only!)
	2. Select the four corners of the second zone in a clockwise fashion (4 clicks only!)

	After you have entered your selections, the code will proceed to the next video or terminate if all zones have been captured. 

3. Command: selectExperiments

	This will open a dialog box where you can use the selection tool to check which experiments you would like to analyze. When you are finished selecting your experiments to analyze press "Finished".

4. Command: trackCommand

	This will initiate the analysis of videos. The videos will be analyzed in the order specified by indexes in the Range variable. ExpID should print to the Command Window which experiment is being currently analyzed. The Command window will return the Preference_Index and Host_Seeking_Index values for that experiment.

======================
RELEVANT OUTPUTS
======================

Overall_Activity_Index (this is the average number of mosquitoes landed during the experiment)

Overall_Preference_Index (this is a summary of the preference for Zone 2 versus Zone 1, including all landing events)

Movement_Index (this is the average number of mosquitoes landed and walking during the experiment)

Movement_Preference_Index (this is a summary of the preference for Zone 2 versus Zone 1, including landing events with walking)

"ExpID"_analysis.mat (this is a MATLAB file containing all of the variables generated during the analysis. This is helpful if you want to go back and look at the data more closely, or generate tracking figures, etc.)

======================
Optimizing Performance
======================

	All of the modifiable variables that affect tracking performance are located in userVariables.m and can be modified to fit your experiment conditions. The most important factor for tracking performance is adequate image thresholding and segmentation. You can modify these variables to affect the performance of imageSegmentation.m, or, design a new segmentation algorithm using the Image Segmenter App (see MathWorks documentation). If you do this, make sure to replace imageSegmentation with your new algorithm:

Line 60 (mosquitoTracker.m): [BW] = imageSegmentation(im,erode,sens); %Generates segmented image

***Replace imageSegmentation() with your new segmentation script. Ensure the output remains 'BW'***

Modify the "sizes" variable to set upper and lower limits on acceptable mosquito body sizes.

	Tracking results can be saved as representative images using the makeImages.m function. To do this, change the repimage_logical to a value of 1 ("repimage_logical = 1") and specify the number of output images you would like ("number_of_images = 250"). This will generate snapshots of individually tracked mosquitoes and wide field views of all mosquitoes tracked. Used this information to evaluate tracking performance and make necessary modifications to tracking parameters. 

======================
USER-DEFINED VARIABLES
======================

erode - (modifies the erosion performance of the image segmentation script)
radius - (modifies the erosion performance of the image segmentation script)
decomposition - (modifies the erosion performance of the image segmentation script)
sens - (determines the thresholding sensitivity of the image segmentation script)
sizes - (sets the lower and upper limits of mosquito body sizes for analysis)
max_expected_blobs - (lets the analysis script know the total number of mosquitoes in the cage)
repimage_logical - (determines whether or not to save representative tracking images)
number_of_images - (determines the number of representative images to save)
speed - (determines the upper limit of movement speed for mosquitoes to still be analyzed, in pixels/frame)
framelimit - (determines the minimum number of frames in a trajectory that constitutes a walking bout)
FR - (specifies the framerate of input videos, adjust this as necessary)
start_time - (specifies in seconds the start time of where analysis should begin)
end_time - (specified in seconds the end time of where analysis should end)

======================
Expected Performance
======================

This code analyzes the provided 5 minute example data in roughly 1 minute.

An example video can be found at the following link: https://figshare.com/articles/media/Chandel_and_DeBeaubien_et_al_2024_/25961890
