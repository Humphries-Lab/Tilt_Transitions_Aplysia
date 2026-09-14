function join_frames% create the video writer with 1 fps
% load the images
d='.\';
 ff = dir([d '*.png']);
 nr_files=size(ff,1);
 images = cell(nr_files,1);
 for i=1:nr_files
 images{i} = imread([d 'Im' num2str(i) '.png']);
 end
 
 writerObj = VideoWriter('Model_sim.mp4','MPEG-4');
 writerObj.FrameRate = 30;
 writerObj.Quality=100;
 % set the seconds per image
 secsPerImage = ones(1,nr_files);
 % open the video writer
 open(writerObj);
 % write the frames to the video
 for u=1:length(images)
     % convert the image to a frame
     frame = im2frame(images{u});
     
     for v=1:secsPerImage(u) 
         writeVideo(writerObj, frame);
     end
 end
 % close the writer object
 close(writerObj);
end