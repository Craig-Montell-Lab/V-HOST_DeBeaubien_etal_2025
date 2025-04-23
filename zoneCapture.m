% Loads ZoneMaster and ExperimentNames
load('ExperimentLog.mat')

% Assuming ExperimentLog is already loaded and is a cell array
nanRows = [];  % Initialize an empty array to store row indices

for i = 1:size(ExperimentLog, 1)
    if isnan(ExperimentLog{i, 4})  % Check if the value in the 4th column is NaN
        nanRows = [nanRows, i];  % Append the row index to the result array
    end
end

for i = 1:size(nanRows,2)



        exp_index = nanRows(i);
        file_name = ExperimentLog{i,2};
        v = VideoReader(file_name);
        
        % Reads a video frame
        findbox = readFrame(v);
        
        % Generates a figure for capturing user input
        findzones = figure('Position',[100 100 v.Width*1.5 v.Height*1.5]);
        daspect([1 1 1])
        image(findbox);
        hold on;
            
        % Captures zone data
        [X,Y] = ginput(8);
        close(findzones);
        
        cords = [X,Y];
        
        ExperimentLog(exp_index,4) = {cords};

 
end
% Clears workspace variables
clearvars -except ExperimentLog

% Saves zone information
save('ExperimentLog.mat')

