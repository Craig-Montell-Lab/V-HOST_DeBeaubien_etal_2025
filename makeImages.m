%% This script is used to make small images at final coordinate positions to visually asses tracking performance

% This is a counting variable used increase with every captured image
ticker = 1;

% This is a counting variable for the current frame
frame = 1;

% Generates a figure called 'f'
f = figure;

% This can be modified for your specific experiment/condition and will be
% the base string in output image filenames
image_file_base = strcat(ExpID,'_');

% Restarts the video
v.CurrentTime = 0;

% Initiates counting object
total_in_image_set = 0;

% Loops through frames of the video, randomly selects a position, and
% captures an image
while ticker < number_of_images+1

    % Reads image frame
    im = readFrame(v);
    x_dim = size(im,2);
    y_dim = size(im,1);
    % Plots image
    im_display = imshow(im);
    hold on

    % Pulls all coordinates at this frame
    frame_pos = cords{frame};

    % Calculates number of mosquitoes
    num_mosquitoes_tracked = size(frame_pos,1);


    image_plot = scatter(frame_pos(:,1),frame_pos(:,2),'Filled','m');
    rand_pos = randi(length(frame_pos));
    query_pos = frame_pos(rand_pos,:);
    tf = ismember(final_pts,query_pos,'rows');
    tf_all = ismember(final_pts,frame_pos,'rows');
    final_cords = final_pts(tf_all,:);
    exists = any(tf);

    % Determines if point is part of final_pts (included in final metrics)
    % and skips if it is not, otherwise it saves as a representative image
    if exists == 1
    % The position is in final_pts
    'found';

    % Generates the full size tracking results image
    xlim([1 x_dim])
    ylim([1 y_dim])
    all_circles = scatter(final_cords(:,1),final_cords(:,2),200, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none');
    im_full = getframe(f);
    imwrite(im_full.cdata,strcat(pwd,'/',output,'/',image_file_base,'full_',num2str(ticker),'.jpg'));
    delete(all_circles);
    % Plots a large black circle around the main mosquito
    mos_circle = scatter(query_pos(:,1),query_pos(:,2),10000, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none');

    % Crops the image
    xlim([query_pos(1)-50 query_pos(1)+50]);
    ylim([query_pos(2)-50 query_pos(2)+50]);

    % Captures image and saves
    im_for_saving = getframe(f);
    imwrite(im_for_saving.cdata,strcat(pwd,'/',output,'/',image_file_base,num2str(ticker),'.jpg'));

    % Increases when an image is saved
    ticker = ticker+1;

    % Clears the plot window
    delete(mos_circle);

    % Add to counter
    total_in_image_set = total_in_image_set + num_mosquitoes_tracked;
    
    else
    % The position plotted is not in final_pts
    'not found';
    end
    
    % Updates the figure window
    drawnow

    % Updates for the next frame
    frame = frame+1;

    % Clears the plot window
    delete(image_plot);
    delete(im_display);
end

% Print total number of mosquitoes in the image set
total_in_image_set

close all