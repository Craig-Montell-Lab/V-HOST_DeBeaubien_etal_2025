%% This script allows for batch processing of experiment recordings

% Clear the workspace variables
clearvars -except Range

% Set the range of experiments to analyze (corresponds to indices in
% ExperimentNames.mat. This can be a single scalar (e.g. 3) or a range (e.g.
% 1:17)


% Load ZoneMaster.mat, ExperimentNames.mat, and OutNames.mat
load('ExperimentLog.mat')

OutList = ExperimentLog(Range,3);

% Iterate through ExpList and analyze each video
for i = 1:size(Range,1)
exp_idx = Range(i,1);
ExpID = ExperimentLog{exp_idx,1};
ExpName = ExperimentLog{exp_idx,2};
OutName = ExperimentLog{exp_idx,3};

% Load the zone data from ZoneMaster
boxes = ExperimentLog{exp_idx,4};
X = boxes(:,1);
Y = boxes(:,2);

% Print the name of the experiment currently being analyzed
disp("Experiment analyzed:")
ExpID

% Perform the analysis on this current video
mosquitoTracker
end

%% This section pulls the relevant metrics from the analyzed experiments
ExtractList = OutList;
Extraction = NaN(size(ExtractList,1),3);

for i = 1:size(ExtractList,1)
    ExpName = ExtractList{i};
    ExpName = strcat(ExpName,'.mat');
    
    if exist(ExpName, 'file') == 2;
        load(ExpName);
    Extraction(i,1) = FR; % Frame rate of the video analyzed
    Extraction(i,2) = round(newPI,2); % Preference Index of the experiment
    Extraction(i,3) = SeekingScore; % SeekingScore of the experiment
        
else
     'File Does Not Exist';
end

end
