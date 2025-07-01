%% This script is used to make small videos at final coordinate positions to visually asses tracking performance
% Ranks the tracks in track_set from longest to shortest
num_cells = size(track_set, 2);
lengths_and_indices = zeros(num_cells, 2);

for i = 1:num_cells
    lengths_and_indices(i, 1) = size(track_set{i}, 1);
    lengths_and_indices(i, 2) = i;
end

sorted_data = sortrows(lengths_and_indices, 1, 'descend');
ranked_indices = sorted_data(:, 2);

% This is a counting variable used increase with every captured video
ticker = 1;

% This is a counting variable for the current frame
frame = 1;

% This can be modified for your specific experiment/condition and will be
% the base string in output image filenames
image_file_base = strcat(ExpID,'_');

% Loops through frames of the video, randomly selects a position, and
% captures an image
while ticker < number_of_videos+1
    % Generates a figure called 'f'
    f = figure;
    output_filename = strcat(pwd,'/',output,'/',image_file_base,num2str(ticker),'.mp4')
    plotting_coordinates = track_set{1,ranked_indices(ticker)};
    starting_pos = plotting_coordinates(1,:);
    v_out = VideoWriter(output_filename,"MPEG-4")
    v_out.FrameRate = 10
    v_out.Quality = 100
    open(v_out)
    for i = 1:num_cells
        current_coords_full = cords{i};
    
        if any(ismember(current_coords_full, starting_pos, 'rows'))
            found_index = i;
            break;
        end
    end

    v.CurrentTime = (found_index-1)/FR;

    for ii = 1:size(plotting_coordinates,1)
    % Reads image frame
    im = readFrame(v);
    x_dim = size(im,2);
    y_dim = size(im,1);
    % Plots image
    im_display = imshow(im);
    hold on

    query_pos = plotting_coordinates(ii,:);
    tf = sum(ismember(final_pts,query_pos,'rows'));
    image_plot = scatter(query_pos(1,1),query_pos(1,2),'Filled','w');
    if tf == 1
    big_outline = scatter(query_pos(1,1),query_pos(1,2),20000, 'o', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'none');
    status_label = text(query_pos(1,1)+10,query_pos(1,2)+10,'Walking/Probing','Color','r');
    else
    big_outline = scatter(query_pos(1,1),query_pos(1,2),20000, 'o', 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'none');
    status_label = text(query_pos(1,1)+10,query_pos(1,2)+10,'Stationary','Color','w');
    end
    % Crops the image
    xlim([query_pos(1)-50 query_pos(1)+50]);
    ylim([query_pos(2)-50 query_pos(2)+50]);

    % Captures image and saves
    im_for_saving = getframe(f);
    writeVideo(v_out,im_for_saving.cdata);
    % Updates the figure window
    drawnow

    % Updates for the next frame
    frame = frame+1;

    % Clears the plot window
    delete(image_plot);
    delete(im_display);
    delete(big_outline);
    delete(status_label);
    end
    close(v_out)
    close(f)
        % Increases when an image is saved
    ticker = ticker+1;
end


close all