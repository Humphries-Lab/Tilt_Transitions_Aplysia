function Figure4_Model
%% FIGURE4_MODEL
% Simulate locomotion changes driven by low-dimensional neural activity.
%
% The model tests three hypotheses:
%   1. Neural amplitude affects animal length.
%   2. Neural period affects locomotion period.
%   3. Neural trajectory tilt affects locomotion mode.

%% Parameters

figureHandle = figure('units','normalized','outerposition',[0 0 1 1]);
figure(figureHandle)

timeBinMs = 50;
timeMs = (timeBinMs:timeBinMs:50000)';

transitionTimeSec = 28.5;
PeriodSec = 10; 
numTimePoints = numel(timeMs);
millisecondsPerSecond = 1000;

crawlcolour = [26 161 149]./255;
gallopcolour = [90 19 138]./255;


%% Crawl model and PCA

crawlNeuralActivity = LowDModelcrawl(timeMs,millisecondsPerSecond);
[pcaCoefficients,pcaScores,~,~,~] = pca(crawlNeuralActivity);


%% Gallop model

gallopStrength = 1;

gallopNeuralActivity = LowDModelgallop( ...
    crawlNeuralActivity,timeMs,millisecondsPerSecond, ...
    PeriodSec,gallopStrength);


%% Gallop-to-crawl transition

transitionNeuralActivity = create_example_trial( ...
    timeMs,transitionTimeSec,millisecondsPerSecond);


%% Neural trajectories

neuralOutputCrawl = pcaScores(1:numTimePoints,1:3);
neuralOutputGallop = (gallopNeuralActivity - mean(crawlNeuralActivity)) * pcaCoefficients;
neuralOutputTransition = (transitionNeuralActivity - mean(crawlNeuralActivity)) * pcaCoefficients;

neuralOutputReference = neuralOutputGallop;


%% Hypothesis 1: neural amplitude

neuralOutputAmplitude = neuralOutputReference(:,1:3)*0.5;
neuralOutputAmplitude(:,3) = mean(neuralOutputReference(:,3)) + neuralOutputAmplitude(:,3);


%% Hypothesis 2: neural period

neuralOutputSlow = interp1(1:numTimePoints,neuralOutputReference,1:0.5:numTimePoints);


%% Neural activity to muscle lengths

muscleLengthReference = muscle_extension2D_simp(neuralOutputReference);
muscleLengthAmplitude = muscle_extension2D_simp(neuralOutputAmplitude);
muscleLengthSlow = muscle_extension2D_simp(neuralOutputSlow);
muscleLengthTransition = muscle_extension2D_simp(neuralOutputTransition);


%% Muscle lengths to skeletons

skeletonReference(:,1,1:4) = [0 cumsum(muscleLengthReference(1,1:end-1))];
skeletonReference(:,2,1:4) = [0 0 0 0];

skeletonAmplitude(:,1,1:4) = [0 cumsum(muscleLengthAmplitude(1,1:end-1))];
skeletonAmplitude(:,2,1:4) = [0 0 0 0];

skeletonTransition(:,1,1:4) = [0 cumsum(muscleLengthTransition(1,1:end-1))];
skeletonTransition(:,2,1:4) = [0 0 0 0];

skeletonSlow(:,1,1:4) = [0 cumsum(muscleLengthSlow(1,1:end-1))];
skeletonSlow(:,2,1:4) = [0 0 0 0];


%% Animal geometry

skeletonReferenceComputed = compute_animal_sketelon(skeletonReference,muscleLengthReference);
animalLengthReference = skeletonReferenceComputed(:,1,4) - skeletonReferenceComputed(:,1,1);

skeletonAmplitudeComputed = compute_animal_sketelon(skeletonAmplitude,muscleLengthAmplitude);
animalLengthAmplitude = skeletonAmplitudeComputed(:,1,4) - skeletonAmplitudeComputed(:,1,1);

skeletonSlowComputed = compute_animal_sketelon(skeletonSlow,muscleLengthSlow(1:size(muscleLengthReference,1),:));
animalLengthSlow = skeletonSlowComputed(:,1,4) - skeletonSlowComputed(:,1,1);

skeletonTransitionComputed = compute_animal_sketelon(skeletonTransition,muscleLengthTransition(:,:));
animalLengthTransition = skeletonTransitionComputed(:,1,4) - skeletonTransitionComputed(:,1,1);


%% Representative time points

minLengthTimeIndex = (millisecondsPerSecond/timeBinMs)*(2.2+PeriodSec/2);
maxLengthTimeIndex = (millisecondsPerSecond/timeBinMs)*2.2;

minArchTimeIndex = (millisecondsPerSecond/timeBinMs)*(23.4+PeriodSec);
maxArchTimeIndex = (millisecondsPerSecond/timeBinMs)*23.4;


%% Neural trajectories

% Hypothesis 1: amplitude affects animal length.
subplot(2,4,1)

plot3(neuralOutputReference(:,1),neuralOutputReference(:,2),neuralOutputReference(:,3),'Color',gallopcolour)
hold on
plot3(neuralOutputAmplitude(:,1),neuralOutputAmplitude(:,2),neuralOutputAmplitude(:,3),'Color',[0.5 0.5 0.5])

plot3(neuralOutputReference(maxLengthTimeIndex,1),neuralOutputReference(maxLengthTimeIndex,2),neuralOutputReference(maxLengthTimeIndex,3),'.','Color',gallopcolour,'MarkerSize',12)
plot3(neuralOutputReference(minLengthTimeIndex,1),neuralOutputReference(minLengthTimeIndex,2),neuralOutputReference(minLengthTimeIndex,3),'.','Color',gallopcolour,'MarkerSize',12)

xlabel('PC 1')
ylabel('PC 2')
zlabel('PC 3')
zlim([min(pcaScores(:,1)) max(pcaScores(:,2))])


% Hypothesis 2: neural period affects locomotion period.
subplot(2,4,2)

plot(timeMs/millisecondsPerSecond,neuralOutputReference(:,1),'Color',gallopcolour)
hold on
plot(timeMs/millisecondsPerSecond,neuralOutputSlow(1:numTimePoints,1),'Color','r')

xlabel('Time [s]')
ylabel('PC 1')
zlim([min(pcaScores(:,1)) max(pcaScores(:,2))])
xlim([0 50])
box off


% Hypothesis 3: trajectory tilt affects locomotion mode.
subplot(2,4,3)

hold on

plot3(neuralOutputTransition(:,1),neuralOutputTransition(:,2),neuralOutputTransition(:,3),'Color',gallopcolour)
plot3(neuralOutputTransition(maxArchTimeIndex,1),neuralOutputTransition(maxArchTimeIndex,2),neuralOutputTransition(maxArchTimeIndex,3),'.','Color',gallopcolour,'MarkerSize',12)

plot3(neuralOutputCrawl(:,1),neuralOutputReference(:,2),neuralOutputCrawl(:,3),'Color',crawlcolour)
plot3(neuralOutputTransition(minArchTimeIndex,1),neuralOutputTransition(minArchTimeIndex,2),neuralOutputTransition(minArchTimeIndex,3),'.','Color',crawlcolour,'MarkerSize',12)

xlabel('PC 1')
ylabel('PC 2')
zlabel('PC 3')
zlim([-max(neuralOutputTransition(:,3)) max(neuralOutputTransition(:,3))])
view(-42,12)


%% Animal shape insets

% Crawl: maximum length.
axes('Position',[0.18 0.62 0.05 0.07]);
create_video(skeletonReferenceComputed,maxLengthTimeIndex)
xlim([-0.5 6])
ylim([-1 2])
axis off

% Crawl: minimum length.
axes('Position',[0.19 0.85 0.05 0.07]);
create_video(skeletonReferenceComputed,minLengthTimeIndex)
xlim([-0.5 6])
ylim([-1 2])
axis off

% Gallop: minimum arching.
axes('Position',[0.67 0.65 0.05 0.07]);
create_video(skeletonTransitionComputed,minArchTimeIndex)
xlim([-0.5 6]+6)
ylim([-1 2])
axis off

% Gallop: maximum arching.
axes('Position',[0.54 0.88 0.05 0.07]);
create_video(skeletonTransitionComputed,maxArchTimeIndex)
xlim([-0.5 6]+4)
ylim([-1 2])
axis off


%% Lower panels

% Example animal configuration.
subplot(4,4,12)
create_video(skeletonTransitionComputed,13)
box off
xlim([-0.5 8])
ylim([-0.1 3])
xlabel('X')
ylabel('Y')


% Muscle lengths.
subplot(4,4,16)
plot(timeMs/millisecondsPerSecond,muscleLengthReference)
legend('M tail','M middle','M neck','M lift')
box off
ylim([0 max(muscleLengthReference,[],'all')])
xlabel('Time [s]')
xlim([0 max(timeMs)/millisecondsPerSecond])


%% Arching

subplot(4,4,13)
hold on
plot(timeMs(1:end-1)/millisecondsPerSecond,skeletonAmplitudeComputed(:,2,3),'Color',[0.5 0.5 0.5])
xlabel('Time [s]')
ylabel('Arching')
box off
ylim([-0.1 max(skeletonTransitionComputed(:,2,3),[],'all')])

subplot(4,4,14)
hold on
plot(timeMs(1:end-1)/millisecondsPerSecond,skeletonSlowComputed(:,2,3),'r')
ylim([-0.1 max(skeletonTransitionComputed(:,2,3),[],'all')])
box off

subplot(4,4,15)
hold on
plot((1:size(skeletonTransitionComputed,1))*timeBinMs/millisecondsPerSecond,skeletonTransitionComputed(:,2,3),'Color',gallopcolour)
ylim([-0.1 max(skeletonTransitionComputed(:,2,3),[],'all')])
box off


%% Animal length

subplot(4,4,9)
plot(timeMs(1:end-1)/millisecondsPerSecond,animalLengthReference,'Color',gallopcolour)
hold on
plot(timeMs(1:end-1)/millisecondsPerSecond,animalLengthAmplitude,'Color',[0.5 0.5 0.5])
box off
ylim([0 6])
ylabel('Animal width [cm]')

subplot(4,4,10)
plot(timeMs(1:end-1)/millisecondsPerSecond,animalLengthReference,'Color',gallopcolour)
hold on
plot(timeMs(1:end-1)/millisecondsPerSecond,animalLengthSlow,'r')
box off
ylim([0 6])

subplot(4,4,11)
plot(timeMs(1:end-1)/millisecondsPerSecond,animalLengthReference,'Color',gallopcolour,'LineWidth',2)
hold on
plot((1:size(animalLengthTransition,1))*timeBinMs/millisecondsPerSecond,animalLengthTransition,'--','Color',crawlcolour)
box off
ylim([0 6])


%% Supplementary video
%colours_video = [gallopcolour;[0 0 0];[1 0 0];gallopcolour];
%create_video_comparison( ...
    % timeMs/millisecondsPerSecond, ...
    % neuralOutputReference,neuralOutputAmplitude, ...
    % neuralOutputSlow,neuralOutputTransition, ...
    % skeletonReferenceComputed,skeletonAmplitudeComputed, ...
    % skeletonSlowComputed,skeletonTransitionComputed, ...
    % colours_video)

end


function skeleton = compute_animal_sketelon(initialSkeleton,muscleLengths)
% Convert muscle lengths into animal skeleton coordinates.

skeleton = zeros(size(muscleLengths,1)-1,2,size(initialSkeleton,3));
skeleton(1,:,:) = initialSkeleton;

for timeIndex = 2:size(muscleLengths,1)-1

    % Head.
    skeleton(timeIndex,1,4) = skeleton(timeIndex-1,1,4) + max(muscleLengths(timeIndex,3)-muscleLengths(timeIndex-1,3),0);
    skeleton(timeIndex,2,4) = 0;

    % Neck.
    liftHeight = max(muscleLengths(timeIndex,4),0);
    skeleton(timeIndex,2,3) = liftHeight;
    skeleton(timeIndex,1,3) = skeleton(timeIndex,1,4) - sqrt(muscleLengths(timeIndex,3).^2-skeleton(timeIndex,2,3).^2);

    % Middle.
    skeleton(timeIndex,2,2) = liftHeight;
    skeleton(timeIndex,1,2) = skeleton(timeIndex,1,3) - muscleLengths(timeIndex,2);

    % Tail.
    skeleton(timeIndex,2,1) = 0;
    skeleton(timeIndex,1,1) = skeleton(timeIndex,1,2) - sqrt(muscleLengths(timeIndex,1).^2-skeleton(timeIndex,2,2).^2);

end

end


function create_video(skeletonData,timeIndex)
% Plot animal geometry for the specified time point(s).

bodycolour = [244 227 215]./255;

for currentTimeIndex = timeIndex

    % Body outline.
    backSkeleton = skeletonData(currentTimeIndex,:,:);
    backSkeleton(1,2,2) = backSkeleton(1,2,2)+1.5;
    backSkeleton(1,2,3) = backSkeleton(1,2,3)+1;

    footSkeleton = skeletonData(currentTimeIndex,:,:);
    footSkeleton(1,2,2) = max(footSkeleton(1,2,2)-0.01,0);
    footSkeleton(1,2,3) = max(footSkeleton(1,2,3)-0.01,0);

    xCoordinates = squeeze(skeletonData(currentTimeIndex,1,:));
    yCoordinates = squeeze(skeletonData(currentTimeIndex,2,:));

    bodyPolygon = polyshape([squeeze(backSkeleton(1,1,1:end-1));flipud(squeeze(footSkeleton(1,1,:)))]',[squeeze(backSkeleton(1,2,1:end-1));flipud(squeeze(footSkeleton(1,2,:)))]');

    plot(bodyPolygon,'Facecolor',bodycolour,'Edgecolor',bodycolour,'FaceAlpha',1)
    hold on

    plot(squeeze(skeletonData(currentTimeIndex,1,:)),squeeze(skeletonData(currentTimeIndex,2,:)),'.-k','LineWidth',2)
    plot(xCoordinates(1:2),yCoordinates(1:2),'LineWidth',2)
    plot(xCoordinates(2:3),yCoordinates(2:3),'LineWidth',2)
    plot(xCoordinates(3:4),yCoordinates(3:4),'LineWidth',2)
    plot(xCoordinates,yCoordinates,'.k','MarkerSize',16)

    xlim([-1 20])
    ylim([-0.1 5])

    pause(0.001)
    % print(['.\Model\Im' num2str(currentTimeIndex)],'-dpng','-r0')

    hold off

end

end


function transitionNeuralActivity = create_example_trial(timeMs,transitionTimeSec,millisecondsPerSecond)
% Generate a gallop-to-crawl transition trial.

locomotionPeriodSec = 10;
transitionIndex = find(timeMs/millisecondsPerSecond>transitionTimeSec,1,'first');

crawlNeuralActivity = LowDModelcrawl(timeMs,millisecondsPerSecond);

gallopStrength = 1;

gallopSegment = LowDModelgallop(crawlNeuralActivity(1:transitionIndex,:),timeMs(1:transitionIndex),millisecondsPerSecond,locomotionPeriodSec,gallopStrength);

transitionNeuralActivity = [gallopSegment;crawlNeuralActivity(transitionIndex+1:end,:)];

end


function crawlScores = LowDModelcrawl(timeMs,millisecondsPerSecond)
% Generate the low-dimensional crawl trajectory.

numTimePoints = numel(timeMs);
crawlScores = zeros(numTimePoints,3);

locomotionPeriodSec = 10;

firstComponentPhase = pi;
crawlScores(:,1) = 2.*cos(timeMs*2*pi/(locomotionPeriodSec*millisecondsPerSecond)+firstComponentPhase);

secondComponentPhase = pi/2;
crawlScores(:,2) = 2.*cos(timeMs*2*pi/(locomotionPeriodSec*millisecondsPerSecond)+secondComponentPhase);

end


function gallopScores = LowDModelgallop(crawlScores,timeMs,millisecondsPerSecond,locomotionPeriodSec,gallopStrength)
% LOWDMODELGALLOP Add the gallop-related neural component to crawl activity.
%
% INPUTS:
%   crawlScores            - Neural activity for the crawl model [N x 3].
%   timeMs                 - Time vector [N x 1], in milliseconds.
%   millisecondsPerSecond  - Conversion factor from milliseconds to seconds.
%   locomotionPeriodSec    - Locomotion cycle period, in seconds.
%   gallopStrength         - Amplitude of the gallop component. Can be a
%                            scalar or a time-varying vector.
%
% OUTPUTS:
%   gallopScores           - Neural activity including the gallop component
%                            [N x 3]. The first two components are unchanged
%                            from crawlScores, while the third component
%                            represents gallop activity.

gallopScores = crawlScores;

thirdComponentPhase = -2*pi/3;

% gallopStrength = linspace(2,0,numel(timeMs))';

gallopScores(:,3) = (1.*cos(timeMs*2*pi/(locomotionPeriodSec*millisecondsPerSecond)+thirdComponentPhase)+1).*gallopStrength;

end

function muscleLengths = muscle_extension2D_simp(neuralOutput)
% MUSCLE_EXTENSION2D_SIMP Convert neural activity into muscle lengths.
%
% INPUTS:
%   neuralOutput - Low-dimensional neural activity [N x 3].
%                 Columns correspond to the three neural dimensions.
%
% OUTPUTS:
%   muscleLengths - Muscle lengths [N x 4]. Columns correspond to:
%                   1. Tail muscle
%                   2. Middle-body muscle
%                   3. Neck muscle
%                   4. Lifting/arching muscle
%
% The neural activity is mapped to muscle lengths using sigmoidal
% nonlinearities. The first three muscle lengths have a minimum length
% of 0.5, while the fourth component controls body arching.

minimumMuscleLength = 0.5;

muscleLengths = [ ...
    minimumMuscleLength+1./(1+exp(-0.15*neuralOutput(:,1)-0.2*neuralOutput(:,2))), ... % tail
    minimumMuscleLength+2./(1+exp(-0.05*neuralOutput(:,1)-0.2*neuralOutput(:,2))), ... % middle
    minimumMuscleLength+2.5./(1+exp(neuralOutput(:,1)+0.5*neuralOutput(:,2))), ... % neck
    1./(1+exp(9-4*neuralOutput(:,3)))]; %lifting

end

function create_video_comparison(timeSec,referenceNeuralOutput,amplitudeNeuralOutput,slowNeuralOutput,transitionNeuralOutput,referenceSkeleton,amplitudeSkeleton,slowSkeleton,transitionSkeleton,plotcolours)
% CREATE_VIDEO_COMPARISON Animate the four model hypotheses.
%
% INPUTS:
%   timeSec                 - Time vector [N x 1], in seconds.
%   referenceNeuralOutput  - Reference neural trajectory [N x 3] in PC space.
%   amplitudeNeuralOutput  - Neural trajectory with altered amplitude [N x 3].
%   slowNeuralOutput       - Neural trajectory with slower dynamics [N x 3].
%   transitionNeuralOutput - Neural trajectory for the gallop-to-crawl
%                            transition [N x 3].
%   referenceSkeleton      - Reference animal skeleton [N-1 x 2 x 4].
%   amplitudeSkeleton      - Animal skeleton for altered neural amplitude
%                            [N-1 x 2 x 4].
%   slowSkeleton            - Animal skeleton for slower neural dynamics
%                            [N-1 x 2 x 4].
%   transitionSkeleton     - Animal skeleton for the gallop-to-crawl
%                            transition [N-1 x 2 x 4].
%   plotcolours             - RGB colours [4 x 3] used for the four model
%                            conditions.
%
% OUTPUTS:
%   None.
%
% The function creates an animated 4-by-4 figure. Each row represents one
% model hypothesis and shows the neural trajectory, animal length, animal
% arching, and corresponding animal configuration.
%
% The four conditions are:
%   1. Reference gallop
%   2. Altered neural amplitude
%   3. Slower neural dynamics
%   4. Gallop-to-crawl transition

close all
figure('units','normalized','outerposition',[0 0 1 1])

referenceAnimalLength = referenceSkeleton(:,1,4)-referenceSkeleton(:,1,1);
amplitudeAnimalLength = amplitudeSkeleton(:,1,4)-amplitudeSkeleton(:,1,1);
slowAnimalLength = slowSkeleton(:,1,4)-slowSkeleton(:,1,1);
transitionAnimalLength = transitionSkeleton(:,1,4)-transitionSkeleton(:,1,1);

numVideoFrames = numel(timeSec)-1;
maximumTimeSec = timeSec(end);
maximumAnimalLength = 6;
maximumArching = max(transitionSkeleton(:,2,2)+0.1);

allNeuralOutputs = [referenceNeuralOutput;amplitudeNeuralOutput;slowNeuralOutput;transitionNeuralOutput];
pcAxisLimits = [min(allNeuralOutputs);max(allNeuralOutputs)]';

for frameIndex = 1:numVideoFrames

    %% Reference gallop

    referencePCAxes = subplot(4,4,1);
    hold on

    plot3(referenceNeuralOutput(1:frameIndex,1),referenceNeuralOutput(1:frameIndex,2),referenceNeuralOutput(1:frameIndex,3),'Color',plotcolours(1,:))
    plot3(referenceNeuralOutput(frameIndex,1),referenceNeuralOutput(frameIndex,2),referenceNeuralOutput(frameIndex,3),'.','MarkerSize',12,'MarkerFacecolor',plotcolours(1,:),'MarkerEdgecolor',plotcolours(1,:))

    xlim(pcAxisLimits(1,:))
    ylim(pcAxisLimits(2,:))
    zlim([-pcAxisLimits(3,2) pcAxisLimits(3,2)])
    view(-37.5,30)

    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

    xticks([])
    yticks([])
    zticks([])

    text(-6,-1.1,'Gallop (reference)','Rotation',90)


    subplot(4,4,2)
    plot(timeSec(1:frameIndex),referenceAnimalLength(1:frameIndex),'Color',plotcolours(1,:))
    xlim([0 maximumTimeSec])
    ylim([0 maximumAnimalLength])
    title('Length')
    box off


    subplot(4,4,3)
    plot(timeSec(1:frameIndex),referenceSkeleton(1:frameIndex,2,3),'Color',plotcolours(1,:))
    xlim([0 maximumTimeSec])
    ylim([-0.1 maximumArching])
    title('Arching')
    box off


    subplot(4,4,4)
    create_video(referenceSkeleton,frameIndex)


    %% Changed neural amplitude

    amplitudePCAxes = subplot(4,4,5);
    hold on

    plot3(amplitudeNeuralOutput(1:frameIndex,1),amplitudeNeuralOutput(1:frameIndex,2),amplitudeNeuralOutput(1:frameIndex,3),'Color',plotcolours(2,:))
    plot3(amplitudeNeuralOutput(frameIndex,1),amplitudeNeuralOutput(frameIndex,2),amplitudeNeuralOutput(frameIndex,3),'.','MarkerSize',12,'MarkerFacecolor',plotcolours(2,:),'MarkerEdgecolor',plotcolours(2,:))

    xlim(pcAxisLimits(1,:))
    ylim(pcAxisLimits(2,:))
    zlim([-pcAxisLimits(3,2) pcAxisLimits(3,2)])
    view(-37.5,30)

    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

    xticks([])
    yticks([])
    zticks([])

    text(-6,-1.1,-1,'Gallop (less contracted)','Rotation',90)


    subplot(4,4,6)
    plot(timeSec(1:frameIndex),amplitudeAnimalLength(1:frameIndex),'Color',plotcolours(2,:))
    xlim([0 maximumTimeSec])
    ylim([0 maximumAnimalLength])
    box off


    subplot(4,4,7)
    plot(timeSec(1:frameIndex),amplitudeSkeleton(1:frameIndex,2,3),'Color',plotcolours(2,:))
    xlim([0 maximumTimeSec])
    ylim([-0.1 maximumArching])
    box off


    subplot(4,4,8)
    create_video(amplitudeSkeleton,frameIndex)


    %% Slower neural dynamics

    slowPCAxes = subplot(4,4,9);
    hold on

    plot3(slowNeuralOutput(1:frameIndex,1),slowNeuralOutput(1:frameIndex,2),slowNeuralOutput(1:frameIndex,3),'Color',plotcolours(3,:))
    plot3(slowNeuralOutput(frameIndex,1),slowNeuralOutput(frameIndex,2),slowNeuralOutput(frameIndex,3),'.','MarkerSize',12,'MarkerFacecolor',plotcolours(3,:),'MarkerEdgecolor',plotcolours(3,:))

    xlim(pcAxisLimits(1,:))
    ylim(pcAxisLimits(2,:))
    zlim([-pcAxisLimits(3,2) pcAxisLimits(3,2)])
    view(-37.5,30)

    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

    xticks([])
    yticks([])
    zticks([])

    text(-6,-1.1,'Gallop (slower)','Rotation',90)


    subplot(4,4,10)
    plot(timeSec(1:frameIndex),slowAnimalLength(1:frameIndex),'Color',plotcolours(3,:))
    xlim([0 maximumTimeSec])
    ylim([0 maximumAnimalLength])
    box off


    subplot(4,4,11)
    plot(timeSec(1:frameIndex),slowSkeleton(1:frameIndex,2,3),'Color',plotcolours(3,:))
    xlim([0 maximumTimeSec])
    ylim([-0.1 maximumArching])
    box off


    subplot(4,4,12)
    create_video(slowSkeleton,frameIndex)


    %% Gallop-to-crawl transition

    transitionPCAxes = subplot(4,4,13);
    hold on

    plot3(transitionNeuralOutput(1:frameIndex,1),transitionNeuralOutput(1:frameIndex,2),transitionNeuralOutput(1:frameIndex,3),'Color',plotcolours(4,:))
    plot3(transitionNeuralOutput(frameIndex,1),transitionNeuralOutput(frameIndex,2),transitionNeuralOutput(frameIndex,3),'.','MarkerSize',12,'MarkerFacecolor',plotcolours(4,:),'MarkerEdgecolor',plotcolours(4,:))

    xlim(pcAxisLimits(1,:))
    ylim(pcAxisLimits(2,:))
    zlim([-pcAxisLimits(3,2) pcAxisLimits(3,2)])
    view(-37.5,30)

    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

    xticks([])
    yticks([])
    zticks([])

    text(-6,-1.1,'Gallop to crawl','Rotation',90)


    subplot(4,4,14)
    plot(timeSec(1:frameIndex),transitionAnimalLength(1:frameIndex),'Color',plotcolours(4,:))
    xlim([0 maximumTimeSec])
    ylim([0 maximumAnimalLength])
    xlabel('Time [s]')
    box off


    subplot(4,4,15)
    plot(timeSec(1:frameIndex),transitionSkeleton(1:frameIndex,2,3),'Color',plotcolours(4,:))
    xlim([0 maximumTimeSec])
    ylim([-0.1 maximumArching])
    xlabel('Time [s]')
    box off


    subplot(4,4,16)
    create_video(transitionSkeleton,frameIndex)


    %% Update frame

    pause(0.0001)

    % print(['.\Model\Im' num2str(frameIndex)],'-dpng','-r0')

    cla(referencePCAxes)
    cla(amplitudePCAxes)
    cla(slowPCAxes)
    cla(transitionPCAxes)

end

end

