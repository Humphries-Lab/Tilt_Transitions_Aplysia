function Figure1_Transitions_match


figure

Figure_1_behaviour
Figure_1_Neural


end

function Figure_1_behaviour
% FIGURE_1_BEHAVIOUR Visualizes manually classified locomotion cycles and
% transitions between behavioural epochs.
%
% Figure_1_behaviour
%
% Identifies all available tracking files, extracts the manually assigned
% behavioural epoch for each locomotion cycle, and generates two
% visualizations:
%
% 1. A cycle-by-cycle representation of manually classified behavioural
% epochs across videos.
% 2. A transition matrix showing the frequency of transitions between
% galloping, transitional, and crawling epochs.
%
% The function relies on Modes_features to retrieve behavioural epochs
% and transitions_ocurrence to calculate the transition counts for each
% video.
%
% INPUT
% None. Tracking files are automatically detected in
% ..\Output_files\ using the *_tr.mat naming convention.
%
% OUTPUT
% None. The function creates the figure directly in the current
% MATLAB figure window.
%
% BEHAVIOURAL EPOCHS
% The colour scheme corresponds to:
% Gray : No behaviour
% Purple : Galloping
% Yellow : Transition
% Aqua : Crawling
%

epoch_colours=[125 125 125; ...
    90 19 138;...
    172 143 37;...
    26 161 149; ...
    240 242 133]./255; % Gray=no behaviour, purple=galloping, yellow=transition, aqua=crawling

ff=dir('.\Output_files\*_tr.mat*');
nfiles=size(ff,1);

Mtransitions=zeros(3,3);
max_cycles=40;
meanEpoch=nan(nfiles,max_cycles);

for f=1:nfiles

    VideoName=ff(f).name(1:end-7);

    % Retrieve the manually assigned behavioural epoch for each cycle.
    [~,~,~,~,~,~,epochsNoNan]=Modes_features(VideoName);

    % Accumulate behavioural transitions across videos.
    Mtransitions=Mtransitions+transitions_ocurrence(VideoName);

    meanEpoch(f,1:numel(epochsNoNan))=epochsNoNan';

end

%% Manual classification of cycles

axe=subplot(3,3,1);
meanE2=meanEpoch;

% Order videos according to the number of cycles classified as galloping.
[~,idx]=sort(sum(meanE2==1,2));
meanE2=meanE2(idx,:);

% Display unclassified cycles as the background colour.
meanE2(isnan(meanE2))=0;
imagesc(meanE2)
colormap(axe,[1,1,1;epoch_colours(2:4,:)])
xlabel('N cycle')
xlim([-0.5 20.5])
box off

disp('Cycles of each locomotion modes')
disp(['Crawl = ' num2str(nnz(meanE2(:)==3))])
disp(['Intermediate = ' num2str(nnz(meanE2(:)==2))])
disp(['Gallop = ' num2str(nnz(meanE2(:)==1))])

%% Transitions between manually classified epochs

% Convert transition counts into row-wise proportions.
Mtransitions=Mtransitions./sum(Mtransitions,2);

axe2=subplot(6,3,[10 13 16]);
imagesc(1:3,1:3,Mtransitions)
colorbar
colormap(axe2,gray)
xlabel('Towards')
ylabel('From')
xticks(1:3)
yticks(1:3)
xticklabels({'Gallop','Transition','Crawl'})
yticklabels({'Gallop','Transition','Crawl'})
clim([0 1])

axis square

% Annotate each matrix cell with its transition probability.
for i=1:3
    for j=1:3
        text(j,i,[num2str(round(Mtransitions(i,j)*100)) '%'],'Color',[0.5 0.5 0.5])
    end
end

end


function Figure_1_Neural
% FIGURE_1_NEURAL Loads a single recording session, clusters units by
% activity correlation and visualises neural dynamics against
% automatically detected epochs.
%
% Figure_1_Neural
%
% Loads spike times and stimulus onset for a session, bins spikes from
% stimulus onset to the end of the recording, discards low-firing units,
% and smooths the resulting matrix. Units are then clustered by
% pairwise correlation and displayed as a raster ordered by cluster
% membership. The function also runs Detect_epochs on the same
% recording to identify behavioural epochs from the neural data, plots
% the low-dimensional (PCA) trajectory over time and in 3D, and
% compares the automatically detected epochs against manually scored
% behaviour.
%
% The function relies on spikest2vector_AP to bin spike times,
% median_ISI to estimate the smoothing kernel, filter_spikes to smooth
% the binned matrix, clustering to group units by correlation,
% rasterplot_groups to display the raster, Detect_epochs to segment the
% recording into epochs, plot_PCA_over_time and plot_PCA_3d_transitions
% to visualise the resulting trajectory, and compare_Neural2Behaviour
% to relate epochs to manually scored behaviour.
%
% INPUT
% None. The session path is set within the function.
%
% OUTPUT
% None. The function creates the figure directly in the current
% MATLAB figure window.

session = '.\Neural_Recordings\Mar0916_1.mat';
params_bin=50; %% ms
load(session,'spks','stim_time')
stim=round((str2double(stim_time(1))))*60;% in s
session_end=floor(max(spks(:,2)));
%From stimulus
matrix=spikest2vector_AP(spks,stim+10,session_end,params_bin);
min_spikes=5*size(matrix,2)*params_bin/1000/60; %min spikes per min
spPerN=sum(matrix,2);
matrix(spPerN<min_spikes,:)=[];
meanISI=median_ISI(spks,stim);% in seconds
sig=round(meanISI*1000/params_bin);%in bins
[total_matrix_1]=filter_spikes(sig,matrix);

% cluster neurons by firing patterns 
[units_clusters,~]=clustering(corr(total_matrix_1'));
[G1(:,2),G1(:,1)]=sort(units_clusters);
colour_neurons_group=bone(max(G1(:,2))+4);
colour_neurons_group(end-3:end,:)=[];
colour_neurons_group=colour_neurons_group(randperm(max(G1(:,2))),:);
%% raster
subplot(5,2,[2 4]);
hold on
nunits=size(matrix,1);
rasterplot_groups(matrix,params_bin,G1(:,2),colour_neurons_group)
ylim([0 nunits])
xlim([0 size(matrix,2)*params_bin/1000])
hold off
xlabel('Time [s]')
ylabel('N neuron')

%% Detect epochs of this recording
params.bin=50; %ms
params.use_adaptive_filter=0;
params.do_plot=1;
params.normalisation=0;
params.start=1; % 0 from the beginning of recording, 1 from stim +5
params.varExpTh=80;
params.min_seg=10; % in s
params.rec_thresh=5;
params.varExpTh_cycle=80;

%% detect epochs of this recording and plot
Data=Detect_epochs(session,params);

subplot(5,4,15);
plot_PCA_over_time(Data,params)

subplot(5,4,19)
plot_PCA_3d_transitions(Data)

%% Summary of automatically defined epochs and transitions
compare_Neural2Behaviour
end
