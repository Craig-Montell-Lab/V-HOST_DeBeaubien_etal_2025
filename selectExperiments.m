function select_experiments_gui()
    % Step 1: Load ExperimentLog.mat
    if isfile('ExperimentLog.mat')
        loadedData = load('ExperimentLog.mat');
        if isfield(loadedData, 'ExperimentLog')
            ExperimentLog = loadedData.ExperimentLog;
        else
            uialert(uifigure, 'ExperimentLog.mat does not contain ''ExperimentLog''.', 'Error');
            return;
        end
    else
        uialert(uifigure, 'ExperimentLog.mat not found in current directory.', 'Error');
        return;
    end

    % Step 2: Extract Experiment IDs (column 1)
    experimentIDs = ExperimentLog(:, 1);
    numExperiments = length(experimentIDs);

    % GUI Constants
    checkboxHeight = 25;
    visibleCheckboxes = 10;
    scrollHeight = checkboxHeight * visibleCheckboxes;
    panelHeight = max(checkboxHeight * numExperiments, scrollHeight);

    % Step 3: Create GUI
    fig = uifigure('Position', [500 300 400 400], 'Name', 'Select Experiments');

    % Instructions
    uilabel(fig, 'Position', [20 370 300 22], ...
        'Text', 'Select experiments to analyze:', 'FontWeight', 'bold');

    % Scrollable panel
    scrollContainer = uipanel(fig, ...
        'Position', [20 80 360 scrollHeight], ...
        'Scrollable', 'on', ...
        'Title', '');

    % Inner panel for checkboxes
    checkboxPanel = uipanel(scrollContainer, ...
        'Position', [0 0 360 panelHeight]);

    % Create dynamic checkboxes
    checkboxList = gobjects(numExperiments, 1);
    for i = 1:numExperiments
        checkboxList(i) = uicheckbox(checkboxPanel, ...
            'Text', experimentIDs{i}, ...
            'Position', [10, panelHeight - i * checkboxHeight, 300, 20]);
    end

    % Analyze button
    uibutton(fig, 'Position', [125 30 150 30], ...
        'Text', 'Finished', ...
        'ButtonPushedFcn', @(btn, event) analyzeExperiments());

    % Callback: Save selected row indices as 'Range'
    function analyzeExperiments()
        selectedIndices = [];  % To store row indices
        for i = 1:numExperiments
            if checkboxList(i).Value
                selectedIndices(end+1,1) = i; %#ok<AGROW>
            end
        end

        if isempty(selectedIndices)
            uialert(fig, 'Please select at least one experiment.', 'No Selection');
            return;
        end

        % Assign to base workspace
        assignin('base', 'Range', selectedIndices);
        % Optional: Close GUI after selection
        close(fig);
    end
end
