function Figure1_transitions_match


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

ff=dir('..\Output_files*_tr.mat*');
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
xlim([0.5 20.5])
box off

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

%% raster

%% PCA example

%% Automatically defined epochs

%% Putative transitions

end