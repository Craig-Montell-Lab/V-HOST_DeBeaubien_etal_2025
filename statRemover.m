function [newPI,final_pts,point_distance,points_out] = statRemover(track_set,trax_X,trax_Y,X,Y,fsize,framelimit)
%% This code removes positions from stationary mosquitoes (not host seeking)
% dis_thresh is a user defined variable for the minimum movement length
% between frames
dis_thresh = fsize;

% Sets the total displacement length across the entire track
trav_thresh = 10;

% Preallocates output cell array
moving_traces = cell(1,size(track_set,2));
   
%% Remove Short Tracks
% This removes short traces that fall below framelimit (user defined
% variable)
for i = 1:size(track_set,2);

    % Extract current trace
    trace = track_set{i};
    
    if size(trace,1) > framelimit;   
        p1 = trace(1,:);
        p2 = trace(end,:) ;
        moving_traces{i} = trace;
    else
        moving_traces{i} = [];
    end
end

% Removes empty cells
empty = find(~cellfun('isempty', moving_traces(:,:)));
moving_traces = moving_traces(empty);

%% Remove Stationary Points

% Removes points that fall below the movement threshold
points_out = cell(1,size(moving_traces,2));
for ii = 1:size(moving_traces,2);
    points = moving_traces{ii};
    d1 = (diff(points(:,2))).^2;
    d2 = (diff(points(:,2))).^2;
    fin_dis = (d1 + d2).^0.5;
    thresholder = find(fin_dis > dis_thresh);
    points_out{ii} = points(thresholder,:);
    point_distance(ii) = {fin_dis};
end

%% Remove Singles
% Removes traces that only have a single recorded position
for i = 1:size(points_out,2);
    trace = points_out{i};
    
    if size(trace,1) > 1;
        
    else
    points_out{i} = [];
    end
end

% Removes empty cells
empty = find(~cellfun('isempty', points_out(:,:)));
points_out = points_out(empty);

% Outputs final data
final_pts = vertcat(points_out{:});
z1 = (sum(inpolygon(final_pts(:,1),final_pts(:,2),X(1:4),Y(1:4)))); 
z2 = (sum(inpolygon(final_pts(:,1),final_pts(:,2),X(5:8),Y(5:8))));

% Calculates new PI
newPI = round((z2-z1)/(z2+z1),2);
end

