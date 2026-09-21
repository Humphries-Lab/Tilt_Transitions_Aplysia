function [filtered_matrix,shiftbase]=filter_spikes(sigma,peaks)
%% filter_spikes filters the spike trains in the matrix peaks using a Gaussian filter of standard deviation sigma
%% Inputs
%
% sigma corresponds to the standard deviation of the Gaussian filter [bins]
%
% peaks matrix of dimensions [Neurons,Times]. Each element
% corresponds to the FR of neuron i at time j.
% 
%% Outputs
%
% filtered_matrix = matrix filtered using the Gaussian filtered. This
% matrix is shorter (in time) than the input matrix due to the aligning
% after filtering. The tail at the end of the matrix of lenght shiftbase
% is removed. 
%
% shiftbase is the number of bins that the spike trains were shifted due to
% the filtering process. 
%
% Andrea Colins Rodriguez
% 07/08/2025

xfilter = -5*sigma:1:5*sigma';  % x-axis values of the discretely sampled Gaussian, out to 5xSD
shiftbase=floor(numel(xfilter)/2);
w = (1/(sqrt(2*pi*sigma^2)))*exp(-((xfilter.^2*(1/(2*sigma^2))))); % y-axis values of the Gaussian
w = w ./sum(w);
filtered_matrix= filter(w,1,peaks,[],2);
filtered_matrix= filtered_matrix(:,shiftbase+1:end); % this remove the tail at the end of the recording, so spikes and filtered spikes are aligned to the first bin
end