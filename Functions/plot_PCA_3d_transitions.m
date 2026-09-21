function plot_PCA_3d_transitions(Data)
% PLOT_PCA_3D_TRANSITIONS Plots the neural trajectory in 3D PCA space,
% coloured by epoch.
%
% plot_PCA_3d_transitions(Data)
%
% Draws the trajectory traced by the top three principal components,
% with each epoch plotted in its own colour to illustrate transitions
% between behavioural states in state space.
%
% INPUT
% Data - structure returned by Detect_epochs, containing the PCA
% scores, epoch group assignment per bin and the associated
% colourmap.
%
% OUTPUT
% None. The function adds the plot to the current figure.

ngroups=max(Data.grps);

hold on
% plot trajectory with segments coloured by dynamical epoch
for igrps=1:ngroups
    plot3(Data.scores(Data.group_bin==igrps,1),Data.scores(Data.group_bin==igrps,2),Data.scores(Data.group_bin==igrps,3),'Color',Data.colour_groups(igrps,:))
end
end