function experiment_input_gui()
    % Load or initialize ExperimentLog
    if isfile('ExperimentLog.mat')
        loadedData = load('ExperimentLog.mat');
        if isfield(loadedData, 'ExperimentLog')
            ExperimentLog = loadedData.ExperimentLog;
        else
            ExperimentLog = {};
        end
    else
        ExperimentLog = {};
    end

    % Store temporary new entries before saving
    experimentList = {};

    % Define static default values
    defaultExpID = 'Exp_1';
    defaultVideoFile = 'Exp_1.mov';
    defaultOutputFile = 'Exp_1_analysis';

    % Create the GUI
    fig = uifigure('Position', [500 500 400 250], 'Name', 'Experiment Input');
    % Labels and Fields
    uilabel(fig, 'Position', [30 190 120 22], 'Text', 'Experiment ID:');
    expIDField = uieditfield(fig, 'text', 'Position', [160 190 200 22], 'Value', defaultExpID);

    uilabel(fig, 'Position', [30 150 120 22], 'Text', 'Video File Name:');
    videoFileField = uieditfield(fig, 'text', 'Position', [160 150 200 22], 'Value', defaultVideoFile);

    uilabel(fig, 'Position', [30 110 120 22], 'Text', 'Output File Name:');
    outputFileField = uieditfield(fig, 'text', 'Position', [160 110 200 22], 'Value', defaultOutputFile);

    % Buttons
    uibutton(fig, 'Position', [40 40 150 30], 'Text', 'Add to Experiment List', ...
        'ButtonPushedFcn', @(btn,event) addExperiment());

    uibutton(fig, 'Position', [210 40 150 30], 'Text', 'Finished Entering Exps', ...
        'ButtonPushedFcn', @(btn,event) finishInput());

    % Callback: Add experiment to temporary list
    function addExperiment()
        expID = expIDField.Value;
        videoFile = videoFileField.Value;
        outputFile = outputFileField.Value;

        % Store new values (initialize 4th column as empty)
        experimentList{end+1, 1} = expID;
        experimentList{end, 2} = videoFile;
        experimentList{end, 3} = outputFile;
        experimentList{end, 4} = NaN;  % Placeholder for future data

        % Reset fields to original defaults
        expIDField.Value = defaultExpID;
        videoFileField.Value = defaultVideoFile;
        outputFileField.Value = defaultOutputFile;
    end

    % Callback: Save to ExperimentLog.mat
    function finishInput()
        % Append to loaded ExperimentLog
        ExperimentLog = [ExperimentLog; experimentList];

        % Save back to file
        save('ExperimentLog.mat', 'ExperimentLog');

        % Optional: Display confirmation
        disp('Updated ExperimentLog saved to ExperimentLog.mat:');
        disp(ExperimentLog);

        % Close the GUI
        close(fig);
    end
end

