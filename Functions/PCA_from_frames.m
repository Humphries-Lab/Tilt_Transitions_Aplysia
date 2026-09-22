function [coeffs,scores,bestPCarch,bestPClength,locomotion,nbestPC,explained,diff_freq]=PCA_from_frames(All_f,FrameRate,p,do_plot)
%PCA_FROM_FRAMES Extract principal components from behavioural image frames.
%
%   [coeffs,scores,bestPCarch,bestPClength,locomotion,nbestPC,explained,...
%    diff_freq] = PCA_FROM_FRAMES(All_f,FrameRate,p,do_plot) performs
%   principal component analysis (PCA) on a time series of image frames and
%   identifies the principal components that best correspond to manually
%   measured locomotion features.
%
%   Inputs
%   ------
%   All_f     : Matrix containing the image frames, with each row
%               representing a time point and each column a pixel or frame
%               feature.
%   FrameRate : Sampling rate of the frames, in frames per second.
%   p         : Structure containing animal measurements and video
%               information. The fields required by this function are
%               p.animal_shape.width, p.animal_shape.arching,
%               p.animal_shape.top, p.animal_shape.height,
%               p.animal_shape.bottom, p.VideoName and p.start_t.
%   do_plot   : Logical flag indicating whether diagnostic plots and PCA
%               summary information should be displayed.
%
%   Outputs
%   -------
%   coeffs       : PCA coefficients for the first 10 principal components.
%   scores       : Projection of the frames onto the first 10 principal
%                  components.
%   bestPCarch   : Standardised PC score with the strongest correlation
%                  with the manually measured arching behaviour.
%   bestPClength : Standardised PC score with the strongest correlation
%                  with the manually measured length behaviour.
%   locomotion   : Matrix containing the five locomotion measurements used
%                  for comparison with the PCA scores. [length, arching,top,height,bottom]
%   nbestPC      : Indices of the principal components selected for
%                  arching and length, respectively.
%   explained    : Percentage of variance explained by each principal
%                  component returned by MATLAB's PCA.
%   diff_freq    : Frequencies of the manually measured length behaviour
%                  and its corresponding PCA component.
%
%   Notes
%   -----
%   If PCA results for the current video are already available, they are 
%   loaded from the corresponding output file rather than recalculated.
%
%
%   When plotting is enabled, the function displays the three-dimensional
%   PCA trajectory, the first three PC scores over time, and comparisons
%   between the selected PCs and the corresponding behavioural measurements.

% Smooth each pixel over time to reduce short-timescale fluctuations.
% Fifteen frames correspond to approximately 0.5 seconds for this FrameRate.
All_f=movmean(All_f,round(FrameRate/2));

%% Locomotion measurements
locomotion=[p.animal_shape.width,...
    p.animal_shape.arching,...
    p.animal_shape.top,...
    p.animal_shape.height,...
    p.animal_shape.bottom];

% PCA of the frame data can be computationally expensive, so reuse existing
% results for this video when they are available.
load(['.\Output_files\' p.VideoName '_tr.mat'],'coeffs','scores','explained')

if exist('explained','var')==0
    [coeffs,scores,~,~,explained]=pca(All_f);
    
    coeffs=coeffs(:,1:10);
    scores=scores(:,1:10);

    % Save the calculated PCA results so that they can be reused.
    save(['..\Output_files\' p.VideoName '_tr.mat'],'coeffs','scores','explained','-append')

end

%% Test correlation between PC 1-5 and behavioural measurements
ndim=5;

% Select the PC that has the strongest relationship with the measured
% locomotion feature (Best PC length). Its sign is adjusted so that the correlation is
% positive, making the resulting trajectory easier to compare visually.
corr_length=corr(scores(:,1:ndim),locomotion(:,1));
[~,idxlength]=max(abs(corr_length));
bestPClength=zscore(scores(:,idxlength)*sign(corr_length(idxlength)));

% Select the PC that has the strongest relationship with arching (Best PC arching).
corr_arch=corr(scores(:,1:ndim),locomotion(:,2));
[~,idxarch]=max(abs(corr_arch));
bestPCarch=zscore(scores(:,idxarch)*sign(corr_arch(idxarch)));
nbestPC=[idxarch,idxlength];


%% Zscore for frequency analyses and plotting
locomotion=zscore(locomotion);

%% Compare frequency of manual curation with frequency of best PCA length
freq_length=max_freq(locomotion(:,1),FrameRate);
freq_PC=max_freq(bestPClength,FrameRate);

diff_freq=[freq_length freq_PC];


if do_plot
    xtime=p.start_t+(1:size(All_f,1))/FrameRate;

    %% Trajectory coloured by time
    subplot(4,4,4)
    hold on
    plot_traj_time(scores)
    box off
    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

    %% Display PCA summary
    disp('----------------------')
    disp(['Total dimensions = ' num2str(size(All_f,2))])
    disp(['First 2 dims correspond to % of total dims = ' sprintf('%.2f',100*2./size(All_f,2))])
    disp(['First 2 dim explain % of total var = ' sprintf('%.2f',explained(1))  ' ' sprintf('%.2f',explained(2))])
    disp(['Number of dim explain 80% = ' num2str(find(cumsum(explained)>=80,1,'First'))])
    disp('----------------------')

 
    %% Scores over time
    subplot(4,4,6);
    plot(xtime,scores(:,1),'r')
    hold on
    plot(xtime,scores(:,2),'b')
    plot(xtime,scores(:,3),'g')

    xlim([xtime(1) xtime(end)])
    ylim([min(scores(:)) max(scores(:))])
    xlabel('Time [s]')
    box off   
    legend('PC1','PC2','PC3')
    

    
    %% PC 1 - Length
    subplot(4,4,9)
    plot(xtime,locomotion(:,1),'k')
    hold on
    plot(xtime,bestPClength,'r')
    text(xtime(10),0,['corr = ' sprintf('%.2f',abs(corr_length(idxlength)))])
    box off
  
    %% PC 2 - Arching
    subplot(4,4,13)
    plot(xtime,locomotion(:,2),'k')
    hold on
    plot(xtime,bestPCarch,'b')
    box off
    text(xtime(10),0,['corr = ' sprintf('%.2f',abs(corr_arch(idxarch)))])
    xlabel('Time [s]')

end

end


function plot_traj_time(scores)
%PLOT_TRAJ_TIME Plot a 3-D trajectory coloured according to time.
%
%   PLOT_TRAJ_TIME(scores) plots the trajectory described by the columns of
%   scores in three-dimensional space. The trajectory is divided into
%   temporal segments and coloured progressively using the parula
%   colormap, providing a visual indication of its progression through
%   time.
%
%   Input
%   -----
%   scores : Matrix containing the trajectory coordinates. The first three
%            columns are interpreted as the x-, y-, and z-coordinates,
%            respectively, with each row representing one time point.
%

Ncolours=100;
npoints=size(scores,1);
segmentT=round(npoints./Ncolours);
colour_time=parula(Ncolours);

hold on

% Mark the initial point
plot3(scores(1,1),scores(1,2),scores(1,3),'o','Color',colour_time(1,:),'MarkerFaceColor',colour_time(1,:))

for t=1:Ncolours
    % Assign consecutive trajectory points to each colour segment.
    idx=segmentT*(t-1)+1:t*segmentT+1;
    if sum(idx>npoints)==0
        plot3(scores(idx,1),scores(idx,2),scores(idx,3),'Color',colour_time(t,:))
    else
        % the last segment might have fewer points
        plot3(scores(idx(1):end,1),scores(idx(1):end,2),scores(idx(1):end,3),'Color',colour_time(t,:),'LineWidth',2)
    end

end
end


function maxf=max_freq(x,Fs)
%MAX_FREQ Estimate the dominant frequency above a 40-second period limit.
%
%   maxf = MAX_FREQ(x,Fs) returns the frequency (in Hz) corresponding to
%   the largest Fourier-transform magnitude of the signal x, considering
%   only frequencies whose periods are no longer than 40 seconds.
%
%   Inputs
%   -------
%   x  : Input signal.
%   Fs : Sampling frequency of x, in Hz.
%
%   Output
%   -------
%   maxf : Frequency of the largest spectral component within the analysed
%          frequency range, in Hz.
%
%   Notes
%   -----
%   The mean is removed from x before calculating the Fourier transform.
%   The frequency spectrum is centred around zero, and components below
%   the minimum frequency corresponding to a 40-second period are excluded.
%
%   Example
%   -------
%   maxf = max_freq(x, Fs);

% Set the lowest frequency to consider, corresponding to a maximum
% allowable period of 40 seconds.
minFreq=1/40;

% Remove the DC component so that the mean level of the signal does not
% dominate the frequency spectrum.
x=x-mean(x);
y = fft(x);
z = fftshift(y);
ly = length(y);

% Construct the centred frequency axis and locate the first frequency
% corresponding to a period of 40 seconds or shorter.
f = (-ly/2:ly/2-1)*Fs/ly;
minfidx=find(f>=minFreq,1,'first');

% Find the frequency with the largest Fourier-transform magnitude among
% the frequencies above the minimum threshold.
[~,i]=max(abs(z(minfidx:end)));

maxf=abs(f(i+minfidx-1));
end
