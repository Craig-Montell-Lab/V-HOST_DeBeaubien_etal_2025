function [trax_X, trax_Y, track_data, track_set] = trackFinder(X, Y, cords, FR, speed)
%% This function reconstructs the trajectory of mosquitoes from XY positions across sequential frames

% Remove any empty frames from cords
remove_blanks = ~cellfun('isempty', cords(:,:));
cords = cords(remove_blanks);

% Count the number of detected positions in each frame
for i = 1:length(cords)
    big(i) = length(cords{i});
end

% Create a buffer for array size based on max number of detections
wind = round(max(big) * 1.02); % Adds small buffer size

% Preallocate trax_X and trax_Y arrays
trax_X = cell(round(length(cords)), wind);
trax_Y = cell(round(length(cords)), wind);

% Preallocate track_set array
track_set = cell(1, length(cords));

% Seed the initial positions into trax_X and trax_Y to begin track assignment
set = [cords{1}];
for ii = 1:size(set, 1)
    trax_X{1, ii} = set(ii, 1);
    trax_Y{1, ii} = set(ii, 2);
end

% Index for storing completed tracks in track_set
tick = 1;

% Loop through each frame to match detections and build trajectories
for k = 1:length(cords) - 1
    
    % Pull detections from the next frame
    query = cords{k + 1};  

    % Find nearest neighbors between current track positions and next frame detections
    [findspot, distance] = knnsearch(query, [[trax_X{k, :}]', [trax_Y{k, :}]']);  
    
    % Filter out matches that exceed the speed threshold (moving too fast to be same mosquito)
    limiter = distance < speed;  
    findspot = findspot(limiter); 
    query_list = 1:length([trax_X{k, :}]);
    query_list = query_list(limiter);
    Xplaces = cell(1, wind);
    Yplaces = cell(1, wind);

    % Store matched positions in new arrays for the next frame
    for i = 1:length(findspot)
        Xplaces{query_list(i)} = query(findspot(i), 1);
        Yplaces{query_list(i)} = query(findspot(i), 2);
    end        

    trax_X(k + 1, :) = Xplaces;
    trax_Y(k + 1, :) = Yplaces;

    % Find next available index for unmatched detections in the arrays
    edge1 = find(~cellfun('isempty', trax_X(k, :)), 1, 'last') + 1;
    edge2 = find(~cellfun('isempty', trax_X(k + 1, :)), 1, 'last') + 1;
    edge = max([edge1 edge2]);
    remover = find(limiter == 0);
    used_X = [trax_X{k + 1, :}]';
    remaining = find(~ismember(query(:, 1), used_X));
    unassigned = query(remaining, :);   
    added = length(unassigned(:, 1));  

    % Add unmatched positions as new tracks
    for u = 1:added
        trax_X{k + 1, edge + u - 1} = unassigned(u, 1);
        trax_Y{k + 1, edge + u - 1} = unassigned(u, 2);
    end

    % Save completed tracks (mosquitoes not matched in current frame)
    for i = 1:length(remover)
        track_set{tick} = [[trax_X{:, remover(i)}]', [trax_Y{:, remover(i)}]'];
        tick = tick + 1;    
    end    

    % Remove completed tracks from tracking arrays
    trax_X(:, remover) = [];
    trax_Y(:, remover) = [];
    trax_X{1, wind} = [];
    trax_Y{1, wind} = [];        

end

% Save any remaining active tracks at the end of the sequence
for ii = 1:wind
    track_set{tick} = [[trax_X{:, ii}]', [trax_Y{:, ii}]'];
    tick = tick + 1;
end

% Remove empty cells from track_set
empty = ~cellfun('isempty', track_set(:,:));
track_set = track_set(empty);

% Preallocate arrays for storing track data
X_dat = NaN(length(trax_X), size(track_set, 2));
Y_dat = NaN(length(trax_X), size(track_set, 2));
Dif_dat = NaN(length(trax_X), size(track_set, 2));

% Populate coordinate and distance data for each track
for i = 1:size(track_set, 2)
    XY = track_set{i};
    X_dat(1:length(XY), i) = XY(:, 1);
    Y_dat(1:length(XY), i) = XY(:, 2);
    
    % Compute stepwise distances between each frame for each track
    Dif_dat(2:length(XY), i) = sqrt(sum(abs(diff(XY)), 2));
end

% Calculate total distance traveled in each defined zone
dis1 = nansum(Dif_dat(inpolygon(X_dat, Y_dat, X(1:4), Y(1:4))));
dis2 = nansum(Dif_dat(inpolygon(X_dat, Y_dat, X(5:8), Y(5:8))));

% Calculate total time spent in each zone
tim1 = sum(nansum(inpolygon(X_dat, Y_dat, X(1:4), Y(1:4)))) / FR; 
tim2 = sum(nansum(inpolygon(X_dat, Y_dat, X(5:8), Y(5:8)))) / FR;

% Calculate average time per track in each zone
meantime1 = mean(nonzeros(nansum(inpolygon(X_dat, Y_dat, X(1:4), Y(1:4))))) / FR;
meantime2 = mean(nonzeros(nansum(inpolygon(X_dat, Y_dat, X(5:8), Y(5:8))))) / FR;

% Compile summary statistics for distances and times in each zone
track_data = cell({
    'Total Distance Zone 1', 'Total Distance Zone 2', ...
    'Total Time Zone 1', 'Total Time Zone 2', ...
    'Average Time Zone 1', 'Average Time Zone 2'; 
    dis1, dis2, tim1, tim2, meantime1, meantime2});

end
