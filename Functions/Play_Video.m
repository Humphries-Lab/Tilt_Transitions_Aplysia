function Play_Video(VideoName)
%% Playback of the original video next to the Aplysia tracking results.
%
% This function replays the video [VideoName] together with the output of 
% Track_Video: the raw frame, the tracked silhouette, the behavioral epochs 
% and the time course of arching and length. Every frame is read, but only 
% one out of every 5 is drawn (hence the "x5" label in the figure).
%
% INPUTS:
%   VideoName: String. Filename of the video (e.g., 'animal_F_time_30_480_850.mp4').
%              The video must be in .\Example_videos\ and its tracking data
%              in .\Output_files\[VideoName]_tr.mat (variables p and All_f
%              saved after running Track_Video).
%
% OUTPUTS:
%   None. The animation is displayed in a figure. Frames can be exported
%   with the commented print command in the main loop.

%% Overview
%   Step 1: Loading of the tracking data and the video
%   Step 2: Time axis, plot limits and figure setup
%   Step 3: Main drawing loop


%% 1. Loading of the tracking data and the video
if isfile(['.\Output_files\' VideoName '_tr.mat'])
    load(['.\Output_files\' VideoName '_tr.mat'],'p','All_f')
else
    disp('Video doesnt exist')
    return
end

% All_f and p.animal_shape are indexed from p.start_t, so the reader starts
% at the same time point used by Track_Video
V = VideoReader(['.\Example_videos\' VideoName],'CurrentTime',p.start_t);

Nframes=size(All_f,1);
left2right=1:V.Width;

% Video-specific settings: for this example the playback ends at the fourth 
% cycle time and the image is cropped horizontally around the animal
if strcmp(VideoName,'animal_F_time_30_480_850.mp4')
    p.cycles=p.cycles(1:4);
    Nframes=round((p.cycles(end)-p.start_t)*V.FrameRate);
    p.epochs2=p.epochs2(1:Nframes);
    left2right=150:round(V.Width/2.2);
end


%% 2. Time axis, plot limits and figure setup

% Time in seconds relative to p.start_t (cycle times are shifted below)
xtime=(1:Nframes)/V.FrameRate;

% Sign flipped to follow the arching convention of the Track_Video plots
p.animal_shape.arching=-p.animal_shape.arching;

% Vertical crop applied in Track_Video, to display the same region that was tracked
fromP=round(V.Height*p.fromp);
toP=round(V.Height*p.topP);

% Fixed axes limits computed over the whole recording, so the axes do not
% rescale during playback
ylimsArch=[min(p.animal_shape.arching) max(p.animal_shape.arching)*1.1];
ylimswidth=[min(p.animal_shape.width)*0.9 max(p.animal_shape.width)*1.1];

% Inverted gray colormap: the silhouette is shown in black over white
fig1=figure;
mygray=flipud(colormap(gray));

set(fig1, 'Color',[0 0 0]);

% Vertical lines marking each cycle. Duplicating the x values makes stairs
% draw vertical segments, from -1 to the top of the length axis. The same
% coordinates are used for both traces and clipped by their ylim
p.cycles=p.cycles-p.start_t;
xcycles=reshape([p.cycles';p.cycles'],2*numel(p.cycles),1);
ycycles=reshape([-ones(1,numel(p.cycles));ylimswidth(2)*1.1*ones(1,numel(p.cycles))],2*numel(p.cycles),1);

counter=1;
% Keeps the black background when the figure is exported with print
set(gcf, 'InvertHardcopy', 'off')


%% 3. Main drawing loop
for t=1:Nframes
    % A frame is read at every iteration to keep the video synchronized 
    % with All_f, even when it is not drawn
    Frame=readFrame(V);
    Frame=Frame(fromP:toP,left2right,:);

    if mod(t,5)==1
        % Top left: raw video
        subplot(2,2,1)
        hold on
        image(Frame)
        box off
        axis image
        axis off
        set(gca, 'YDir','reverse')
        text(0.01,0.9,'x5','Color','white','FontSize',16,'FontWeight','normal','Units','normalized','HorizontalAlignment','left');
        hold off

        % Top right: tracked silhouette. Row t of All_f is reshaped back
        % into the image it had in Track_Video (p.HB x p.WB)
        subplot(2,2,2)
        Tracking=reshape(All_f(t,:)',p.HB,p.WB);
        imagesc(Tracking)
        hold on
        axis image
        colormap(mygray)
        axis off
        set(gca, 'YDir','reverse')
        hold off
        title('Tracking', 'Color','white','FontSize',14,'FontWeight','normal','FontName','Arial');

        % Behavioral epochs as a color strip, positioned manually between
        % the images and the time series
        ax1=axes('Position',[0.1300 0.55 0.7750 0.05]);
        imagesc([xtime(1) xtime(end)],[0 1],p.epochs2);
        colormap(ax1,p.epoch_colours(min(p.epochs)+1:max(p.epochs)+1,:))
        axis off

        % Arching up to the current frame. The x axis is hidden because it
        % is shared with the length trace below
        ax2=subplot(4,1,3);
        ax2.Color='none';
        fontname(ax2,'Arial')
        hold on
        box off
        xlim([xtime(1) xtime(end)])
        ylim(ylimsArch)
        stairs(xcycles,ycycles,'Color',[0.5 0.5 0.5])
        plot(ax2,xtime(1:t),p.animal_shape.arching(1:t),'w')
        text(0.99,0.95,'Arching [a.u.]','Color','white','FontSize',14,'FontWeight','normal','Units','normalized','HorizontalAlignment','right');
        set(gca,'xtick',[]);
        set(gca,'xcolor','none')
        set(gca,'ycolor','white')
        hold off

        % Length (animal_shape.width, the horizontal elongation) up to the 
        % current frame
        ax3=subplot(4,1,4);
        ax3.Color='none';
        hold on
        box off
        xlim([xtime(1) xtime(end)])
        ylim(ylimswidth)
        stairs(xcycles,ycycles,'Color',[0.5 0.5 0.5])

        text(0.99,0.95,'Length [pixels]','Color','white','FontSize',14,'FontWeight','normal','Units','normalized','HorizontalAlignment','right');
        xlabel('Time [s]','FontSize',14)
        fontname(ax3,'Arial')
        set(gca,'xcolor','white')
        set(gca,'ycolor','white')
        plot(ax3,xtime(1:t),p.animal_shape.width(1:t),'w')

        hold off

        % To export the drawn frames (e.g., to build a video externally),
        % uncomment the print command. [counter] numbers the exported images
        %print(['..\Output_files\frames\video_example0\TR_im' num2str(counter)],'-dpng','-r0')
        counter=counter+1;
        pause(0.001)
        clf % The axes are created again at every drawn frame
    end


end

close(fig1)
end