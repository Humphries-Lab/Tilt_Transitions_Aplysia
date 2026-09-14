function [Mina,ConR,Period,epochs,features,icycle,epochsNoNan]=Modes_features(VideoName)
% MODES_FEATURES Extracts cycle-level locomotion features from tracked video data.
%
% [Mina,ConR,Period,epochs,features,icycle,epochsNoNan] = ...
% Modes_features(VideoName)
%
% Loads tracking data and locomotion annotations associated with VideoName,
% aligns the annotations with the tracking start time, and extracts
% cycle-level measurements of animal arching, body-width contraction, and
% cycle period. Cycles affected by occlusion are excluded from the
% cycle-level outputs.
%
% INPUT
% VideoName : Character vector or string containing the video filename.
% The corresponding tracking file is expected in
% ..\Output_files\ and the locomotion annotations in the
% current directory.
%
% OUTPUT
% Mina : Maximum arching value for each valid locomotion cycle.
% ConR : Percentage contraction in body width for each valid cycle.
% Period : Duration of each valid locomotion cycle, in seconds.
% epochs : Behavioural epoch assigned to each valid cycle.
% features : Structure containing the frame-level arching and width
% traces, together with the original cycle timestamps.
% icycle : Cumulative locomotion-cycle index for tracked cycles.
% epochsNoNan : Copy of the behavioural epoch vector before filtering.
%
%
%


load(['..\Output_files\' VideoName '_tr.mat'],'p')
info = xlsread(['Locomotion_' VideoName(1:end-4) '.xlsx']);

% Align locomotion annotations with the start of the tracking interval.
TimeEvents=info(:,1)*60+info(:,2);
info(TimeEvents<p.start_t,:)=[];
locomotion=info(:,4);
icycle=cumsum(locomotion(locomotion==1));
tracking=info(locomotion==1,6)>0;
tracking(end)=[];
icycle=icycle(tracking);

FrameRate=29.9700;
cyclesS=p.cycles-p.cycles(1);
t=(1:numel(p.epochs2))/FrameRate;

% Arching is inverted so that larger values represent greater arching.
arching=-p.animal_shape.arching;

% Smooth tracking-derived measurements while preserving local features.
arching=movmedian(arching,5);
p.animal_shape.width=movmedian(p.animal_shape.width,5);

Mina=nan(numel(cyclesS)-1,1);
ConR=nan(numel(cyclesS)-1,1);
startbin=nan(numel(cyclesS)-1,1);
t_max=nan(numel(cyclesS)-1,1);

for i=1:numel(cyclesS)-1
cycle_idx=find(cyclesS(i)<t & t<=cyclesS(i+1));
startbin(i)=cycle_idx(1);

% Maximum arching reached within the cycle.
[Mina(i),idx_max]=max(arching(cycle_idx));
t_max(i)=t(idx_max+cycle_idx(1));

% Relative decrease in body width within the cycle.
Maxw=max(p.animal_shape.width(cycle_idx));
Minw=min(p.animal_shape.width(cycle_idx));
ConR(i)=100*(Maxw-Minw)/Maxw;


end

% Calculate cycle duration and assign the corresponding behavioural epoch.
Period=diff(p.cycles);
epochs=p.epochs(1:end-1);
epochsNoNan=epochs;

% Exclude cycles associated with occluded or untracked periods.
Mina=Mina(tracking);
ConR=ConR(tracking);
Period=Period(tracking);
epochs=epochs(tracking);

features.width=p.animal_shape.width;
features.arch=arching;
features.period=p.cycles;

end