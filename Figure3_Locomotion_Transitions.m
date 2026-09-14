function Figure3_Locomotion_Transitions
% Figure3_Locomotion_Transitions
% Quantifies and plots locomotion parameters across experimental videos.
%
% The function loads preprocessed tracking data for each video and
% visualizes arching, contraction rate, and cycle period.


% example videos
Video={'5gc_short.avi',...
    '00025_animal1.avi',...
    '4gc.avi',...
    '00079_6.avi'};

figure

for i=1:length(Video)
    Plot_locomotion_parameters(Video{i},i)

end

end

function Plot_locomotion_parameters(VideoName,column)
% Plot_locomotion_parameters
% Loads tracking data and plots cycle-resolved locomotion parameters.
%
% INPUTS
%   VideoName - Name of the video associated with the tracking data.
%   column    - Subplot column assigned to the video.

load(['..\Output_files\' VideoName '_tr.mat'],'p')

FrameRate=29.9700;
cyclesS=p.cycles-p.cycles(1);
t=(1:numel(p.epochs2))/FrameRate;% in S
arching=-p.animal_shape.arching;


% Filter arching and width measurements to reduce frame-to-frame noise.
arching=movmedian(arching,5);
p.animal_shape.width=movmedian(p.animal_shape.width,5);

Mina=nan(numel(cyclesS)-1,1);
t_max=nan(numel(cyclesS)-1,1);
ConR=nan(numel(cyclesS)-1,1);
startbin=nan(numel(cyclesS)-1,1);

for i=1:numel(cyclesS)-1
    % define cycles
    cycle_idx=find(cyclesS(i)<t & t<=cyclesS(i+1));
    startbin(i)=cycle_idx(1);

    % calculate max arching during cycle
    [Mina(i),idx_max]=max(arching(cycle_idx));
    t_max(i)=t(idx_max+cycle_idx(1));

    % calculate rate of contraction during cycle
    Maxw=max(p.animal_shape.width(cycle_idx));
    Minw=min(p.animal_shape.width(cycle_idx));
    ConR(i)=100*(Maxw-Minw)/Maxw; % in percentage

end


% Calculate Period of cyle
Period=diff(p.cycles);


%% Plot
% Arching
subplot(3,4,column)
hold on
plot(t_max,Mina,'k.-')

% Detect abrupt change in arching.
ipt = findchangepts(Mina);
Pchange=isAbrupt(Mina,ipt);

if Pchange>4
plot(t_max(ipt),Mina(ipt),'*')
end

ylabel('Arching')
box off
imagesc([0 t(end)],[min(arching) max(arching)],p.epochs2+1, 'AlphaData', .3)
colormap(p.epoch_colours(2:4,:))

% contraction
subplot(3,4,4+column)

hold on
plot(t_max,ConR,'k.-')
ipt= findchangepts(ConR);
Pchange=isAbrupt(ConR,ipt);
if Pchange>4
    plot(t_max(ipt),ConR(ipt),'*')
end
ylabel('Contraction Rate [%]')
box off

imagesc([0 t(end)],[min(ConR) max(ConR)],p.epochs2+1, 'AlphaData', .3)
colormap(p.epoch_colours(2:4,:))

% Period
subplot(3,4,8+column)
hold on
plot(t_max,Period,'k.-')
box off
ipt = findchangepts(Period);
Pchange=isAbrupt(Period,ipt);
if Pchange>4
plot(t_max(ipt),Period(ipt),'*')
end

xlabel('Time [s]')
ylabel('Cycle period [s]')
ylim([0 15])

imagesc([0 t(end)],[0 15],p.epochs2+1, 'AlphaData', .3)
colormap(p.epoch_colours(2:4,:))

end


function Pchange=isAbrupt(Period,ipt)
% isAbrup
% Quantifies the relative change in the local cycle-period derivative
% at a detected change point.

Pchange=abs(Period(ipt-1)-Period(ipt))/mean(abs(diff(Period))); %change in derivativative should be large

end
