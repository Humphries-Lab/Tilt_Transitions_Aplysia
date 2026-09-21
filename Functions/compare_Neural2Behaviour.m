function compare_Neural2Behaviour
%COMPARE_NEURAL2BEHAVIOUR Compare neural epoch sequences across recordings.
%
% This function organises the epoch sequences detected in each recording,
% groups recordings according to the number of detected neural states, and
% visualises the resulting behavioural patterns. It also estimates the
% transition probabilities between three putative behavioural stages:
% First, Middle, and Last.
%
% The input structure is expected to contain one epoch sequence per
% recording. Epoch labels are assumed to be positive integers, with the
% largest label corresponding to the final state in the sequence.
%
% The analysis produces two representations:
%   - Pattern2: epoch sequences reduced to three behavioural stages for
%     transition analysis.
%   - Pattern3: epoch sequences represented using the original state
%     structure while aligning the first and last states across recordings.
%
% The function also displays the transition-probability matrix and the
% behavioural pattern matrix.

%% Input data

% Load the detected neural epochs for all recordings.
load('.\Output_files\Epochs_all_Neural_Recordings.mat','epochs_all')

N_rec=size(epochs_all,2);
Pattern=zeros(N_rec,50);
ngrps=zeros(N_rec,1);
ncycles=zeros(N_rec,1);

% Organise the recordings into a common matrix. Each row corresponds to a
% recording, and each column represents a successive cycle.
for i=1:N_rec
    ngrps(i)=max(epochs_all{i});
    ncycles(i)=size(epochs_all{i},1);
    Pattern(i,1:ncycles(i))=epochs_all{i}';
end

% Sort recordings by the number of detected states. Within each group,
% recordings are subsequently ordered by the number of cycles so that
% recordings with similar sequence lengths are displayed together.
[ngrps,idx]=sort(ngrps);
maxGrps=ngrps(end);
Pattern=Pattern(idx,:);
ncycles=ncycles(idx);

counter=0;
tmp=unique(ngrps);

for i_grps=1:numel(tmp)
    [~,idx2]=sort(ncycles(ngrps==tmp(i_grps)));
    Pattern(ngrps==tmp(i_grps),:)=Pattern(idx2+counter,:);
    counter=counter+sum(ngrps==tmp(i_grps));
end

disp(['Total number of cycles across recordings = ' num2str(sum(ncycles))])

% Define the colour map used to display the behavioural patterns. White is
% reserved for the zero-padded portion of each sequence.
colours=[1 1 1;plasma(max(ngrps))];
colours(end,:)=[255,230,0]./255;

%% Compute transition matrix

% Pattern2 contains the reduced three-state representation used to
% calculate transitions between putative behavioural stages.
Pattern2=Pattern*nan;
Mtransitions=zeros(3,3);

%% Define behaviour-like patterns (up to 2 transitions)

for i=1:N_rec

    % Collapse the detected states into a common First-Middle-Last
    % representation. Recordings containing a single state are treated as
    % a single behavioural state and assigned to the Last category.

    if ngrps(i)==1

        Pattern2(i,:)=Pattern(i,:)*3;

    elseif ngrps(i)==2

        Pattern2(i,:)=Pattern(i,:);
        Pattern2(i,Pattern(i,:)==2)=3;

    elseif ngrps(i)==3

        Pattern2(i,:)=Pattern(i,:);

    else

        % For sequences containing more than three states, retain the first
        % and last states while combining all intermediate states into the
        % Middle category.
        idx_middle=Pattern(i,:)>1 & Pattern(i,:)<ngrps(i);
        tmp=Pattern(i,:);
        tmp(idx_middle)=2;
        tmp(Pattern(i,:)==ngrps(i))=3;
        Pattern2(i,:)=tmp;

    end

    % Exclude zero-padding before calculating transitions.
    Mtransitions=Mtransitions+transitions_occurrence(Pattern2(i,Pattern2(i,:)>0));

end

% Convert transition counts to row-wise transition probabilities.
Mtransitions=Mtransitions./sum(Mtransitions,2);

% Display the transition-probability matrix.
ax1=subplot(5,4,20);
imagesc(1:3,1:3,Mtransitions)
colorbar
colormap(ax1,gray)

xlabel('Towards')
ylabel('From')

xticks(1:3)
yticks(1:3)

xticklabels({'First','Middle','Last'})
yticklabels({'First','Middle','Last'})

clim([0 1])
axis square

% Overlay transition probabilities as percentages.
for i=1:3
    for j=1:3
        text(j,i,[num2str(round(Mtransitions(i,j)*100)) '%'], ...
            'Color',[0.5 0.5 0.5])
    end
end

%% Colour assignation by putative behaviour

% Pattern3 retains the relative ordering of the detected states while
% assigning a common colour to the final state across recordings.
Pattern3=Pattern*nan;

for i=1:N_rec

    % A recording containing only one state is treated as a single
    % behavioural state and assigned the colour corresponding to the final
    % state. For recordings with multiple states, only the final state is
    % remapped; intermediate states retain their original labels.

    if ngrps(i)==1

        Pattern3(i,:)=Pattern(i,:)*maxGrps;

    else

        Pattern3(i,:)=Pattern(i,:);
        Pattern3(i,Pattern(i,:)==ngrps(i))=maxGrps;

    end

end

% Plot the behavioural pattern matrix.
ax7=subplot(5,4,16);
imagesc(Pattern3)

colormap(ax7,colours)

c=colorbar;
c.Ticks=1:maxGrps;
c.Limits=[1,maxGrps];
c.Location='east';

c.TickLabels={'First','Middle','Middle','Middle','Last'};

box off

xlabel('Cycle number')
ylabel('Recording number')

xlim([0,50])

save('.\Output_files\Epochs_all_Neural_Recordings.mat','Pattern3','-append')
%Key_paramters_all_rec(colours,Pattern3)

end


function Mtransitions=transitions_occurrence(epochs)
%TRANSITIONS_OCURENCE Count transitions between successive neural states.
%
% The function receives a sequence of behavioural-state labels and
% returns a 3-by-3 matrix in which rows represent the current state and
% columns represent the subsequent state. Diagonal entries therefore
% represent successive cycles assigned to the same state.

Mtransitions=zeros(3,3);
Ncycles=numel(epochs);

for i=1:Ncycles-1

    Mtransitions(epochs(i),epochs(i+1))= ...
        Mtransitions(epochs(i),epochs(i+1))+1;

end

end