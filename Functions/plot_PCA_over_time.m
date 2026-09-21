function plot_PCA_over_time(Data,params)
% PLOT_PCA_OVER_TIME Plots the top three principal component scores
% over time, overlaid with the automatically detected epochs.
%
% plot_PCA_over_time(Data, params)
%
% Displays PC1-3 as time series and shades the background according to
% the epoch each time bin was assigned to, with white boundary lines
% marking epoch transitions.
%
% INPUT
% Data - structure returned by Detect_epochs, containing the PCA
% scores, epoch group assignment per bin, segment boundaries and
% the associated colourmap.
% params - structure containing the bin size (ms) used for the
% analysis.
%
% OUTPUT
% None. The function adds the plot to the current figure.

nsegments=numel(Data.segment_s);
xtime=(1:size(Data.total_matrix,2))*params.bin/1000;

% plot PCA
hold on
plot(xtime,Data.scores(:,1),'k')
plot(xtime,Data.scores(:,2),'r')
plot(xtime,Data.scores(:,3),'b')
ylim([min(Data.scores(:)) max(Data.scores(:))])
legend('PC 1','PC 2','PC 3')
xlim([0 xtime(end)])
xlabel('Time [s]')
ylabel('PCs')

% plot epochs
im=imagesc([1 Data.startbin(end)]*params.bin/1000,[min(Data.scores(:)) max(Data.scores(:))],Data.group_bin');
im.AlphaData=0.1;
ax = gca;
colormap(ax,Data.colour_groups)

% plot cycles
stairs(reshape([Data.startbin;Data.startbin],2*(nsegments+1),1)*params.bin/1000,reshape([min(Data.scores(:))*ones(1,nsegments+1);max(Data.scores(:))*ones(1,nsegments+1)],2*(nsegments+1),1),'w')
end