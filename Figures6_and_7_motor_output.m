function Figures6_and_7_motor_output
%FIGURES6_AND_7_MOTOR_OUTPUT Generate Figures 6 and 7 and report summary statistics.
%
%   FIGURES6_AND_7 loads the compiled P10 analysis results and generates
%   the visualisations and summary statistics associated with Figures 6
%   and 7.
%
%   Figure 6 presents cycle-level relationships between P10 and ganglion
%   amplitude and period, together with the corresponding correlation
%   measures and an example recording. Figure 7 combines an example
%   recording with the distribution of phase differences between P10 and
%   jPC 3.
%
%   The function also reports summary statistics for the cycle-level
%   correlations, phase differences, and within-recording phase
%   variability. A paired statistical test is used to assess whether the
%   phase differences differ from zero.
%
%   INPUTS
%       None.
%
%   OUTPUTS
%       None. Figures are created in the current MATLAB session and summary
%       statistics are printed to the command window.
%
%   NOTES
%       The function expects the compiled results and example recording
%       files to be available in the relative Output_files directory.
%
%   EXAMPLE
%       Figures6_and_7
%

load('.\Output_files\p10_results.mat','p10_results_all')


[Key_features,corr_features_all,R_tilt_Ventral,~,Phase_diff_Ventral,std_phase_Ventral]=get_p10_results(p10_results_all);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Figure 6
%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('_____________ Figure 6____________________')
disp(['Total number of cycles across recordings ' num2str(sum(~isnan(Key_features(:,1))),'%.2f')])
disp(['Mean corr amplitude =' num2str(mean(corr_features_all(:,2)),'%.2f')])
disp(['Mean corr tilt =' num2str(mean(corr_features_all(:,3)),'%.2f')])

figure 


subplot(2,3,3)
plot(Key_features(:,3),Key_features(:,4),'.k')
hold on
xlabel('P10 Amplitude [Hz]')
ylabel('Ganglion Amplitude')
box off
axis square
title(['Corr = ' num2str(corr(Key_features(:,3),Key_features(:,4),'rows','complete'),'%.2f')])

subplot(2,3,6)
plot([0 90],[0 90],'Color',[0.5 0.5 0.5])
plot(Key_features(:,1),Key_features(:,2),'.k')
xlabel('P10 period [s]')
ylabel('Ganglion period [s]')
box off
xlim([0 90])
ylim([0 90])
axis square
MAE=median(abs(Key_features(:,1)-Key_features(:,2)),'omitnan');
title(['Corr = ' num2str(corr(Key_features(:,1),Key_features(:,2),'rows','complete'),'%.2f') ' MAE = ' num2str(MAE,'%.2f')])


subplot(2,3,4)
hold on
plot(1:2,corr_features_all(:,[2 3]))
ylim([-1 1])
xlim([0.5 3.5])
ylabel('Correlation to p10 amplitude')
xticks([1 2 3])
xticklabels({'Amplitude','Tilt'})
axis square


session = '.\Output_files\p10_results\Jul1119_1_processed.mat';
plot_example_Figure6(session)

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Figure 7
%%%%%%%%%%%%%%%%%%%%%%%%%%

figure

session='.\Output_files\p10_results\Mar2316_1_processed.mat';
plot_example_Figure7(session)

Phase_diff=Phase_diff_Ventral;
Phase_diff(Phase_diff<0)=Phase_diff(Phase_diff<0)+360;
Phase_diff(Phase_diff>360)=Phase_diff(Phase_diff>360)-360;

subplot(3,2,6)
histogram(Phase_diff(:),0:18:360,'Normalization','Probability')

box off
axis square
xlabel('Phase difference p10 vs jPC 3 [\circ]')
ylabel('Fraction of cycles')


%% stats phase diff
disp('_____________ Figure 7____________________')
disp(['Mean corr tilt jpc3 = ' num2str(mean(R_tilt_Ventral,'omitnan'),'%.2f') ' +- ' num2str(std(R_tilt_Ventral,'omitnan'),'%.2f')])

disp(['Mean Phase diff = ' num2str(mean(Phase_diff(:),'omitnan'),'%.2f') ' +- ' num2str(std(Phase_diff(:),'omitnan'),'%.2f')])

Phase_diff(Phase_diff>180)=Phase_diff(Phase_diff>180)-360;
Phase_nan=Phase_diff(~isnan(Phase_diff));

[~,pval]=ttest(Phase_nan);

disp(['p-value difference phases = ' num2str(pval)])
disp(['Mean std phase within recording = ' num2str(mean(std_phase_Ventral(:)),'%.2f')])


end


function [Key_features,corr_features,R_tilt,JPC3_var,Phase_diff,std_phase]=get_p10_results(p10_results_all)
%GET_P10_RESULTS Compile P10-related features and correlation measures.
%
%   [KEY_FEATURES,CORR_FEATURES,R_TILT,JPC3_VAR,PHASE_DIFF,STD_PHASE] =
%   GET_P10_RESULTS(P10_RESULTS_ALL) combines cycle-level measurements and
%   summary statistics from multiple P10 recordings into arrays suitable
%   for subsequent analysis.
%
%   The function aggregates period, amplitude, tilt, firing-rate
%   correlations, phase differences, tilt correlations, and the variance
%   associated with the third jPC. Cycle-level measurements from all
%   recordings are concatenated into a common feature matrix, while
%   recording-level measures are retained separately.
%
%   INPUTS
%       p10_results_all - Structure array containing the P10 analysis
%                         results for each recording. Each element must
%                         contain the fields used by this function,
%                         including Period, Amplitude, Tilt, FR_gang,
%                         phase_diff, std_phase, R_tilt, and Var_jPCs.
%
%   OUTPUTS
%       Key_features  - Concatenated cycle-level period, amplitude, and
%                       tilt measurements.
%
%       corr_features - Recording-level correlations between P10 and
%                       ganglion measurements for period, amplitude, tilt,
%                       and firing rate, respectively.
%
%       R_tilt        - Tilt correlation coefficient for each recording.
%
%       JPC3_var      - Variance associated with the third jPC for each
%                       recording.
%
%       Phase_diff    - Phase-difference measurements for each recording,
%                       padded with NaN where recordings contain fewer
%                       measurements than the allocated array length.
%
%       std_phase     - Standard deviation of phase for each recording.
%
%   EXAMPLE
%       [Key_features,corr_features,R_tilt,JPC3_var,Phase_diff,std_phase] = ...
%           plot_p10_results(p10_results_all)



Nrec=numel(p10_results_all);

R_tilt=nan(Nrec,1);

std_phase=nan(Nrec,1);

Period=nan(1000,2);
Amplitude=nan(1000,2);
Tilt=nan(1000,2);
counter=1;


corr_period_cycle=nan(Nrec,1);
corr_Amp_cycle=nan(Nrec,1);
corr_Tilt_cycle=nan(Nrec,1);
corr_FR_cycle=nan(Nrec,1);

Phase_diff=nan(Nrec,100);
JPC3_var=nan(Nrec,1);




for i=1:Nrec

    std_phase(i)=p10_results_all(i).std_phase;

    R_tilt(i)=p10_results_all(i).R_tilt;
    JPC3_var(i)=p10_results_all(i).Var_jPCs(3);


    %% Period, amplitude and tilt
    Ncycles=size(p10_results_all(i).Period,1);

    Period(counter:counter+Ncycles-1,:)=p10_results_all(i).Period;
    Amplitude(counter:counter+Ncycles-1,:)=p10_results_all(i).Amplitude;
    Tilt(counter:counter+Ncycles-1,:)=p10_results_all(i).Tilt;
    counter=counter+Ncycles;

    Ntmp=numel(p10_results_all(i).phase_diff);
    Phase_diff(i,1:Ntmp)=p10_results_all(i).phase_diff';

    corr_period_cycle(i)=corr(p10_results_all(i).Period(:,1),p10_results_all(i).Period(:,2),'rows','complete');
    corr_Amp_cycle(i)=corr(p10_results_all(i).Amplitude(:,1),p10_results_all(i).Amplitude(:,2),'rows','complete');
    corr_Tilt_cycle(i)=corr(p10_results_all(i).Tilt(:,1),p10_results_all(i).Tilt(:,2),'rows','complete');
    corr_FR_cycle(i)=corr(p10_results_all(i).FR_gang(:,1),p10_results_all(i).FR_gang(:,2),'rows','complete');

end


Key_features=[Period,Amplitude,Tilt];
corr_features=[corr_period_cycle,corr_Amp_cycle,corr_Tilt_cycle,corr_FR_cycle];

end

function plot_example_Figure6(session)
%PLOT_EXAMPLE_FIGURE6 Generate the example plots shown in Figure 6.
%
%   PLOT_EXAMPLE_FIGURE6(SESSION) loads the data stored in SESSION and
%   generates the principal visualisations used to illustrate the
%   relationship between population dynamics, P10 firing rate, amplitude,
%   tilt, and rotation period.
%
%   The figure combines a three-dimensional PCA representation with
%   time-resolved comparisons between P10 and ganglion activity. Summary
%   statistics describing the correspondence between the signals are
%   displayed directly in the relevant panel titles.
%
%   INPUTS
%       session - Path to a MATLAB data file containing the Data structure.
%                 The structure must contain the p10_results data required
%                 by the plots and summary statistics.
%
%   OUTPUTS
%       This function does not return any variables. It adds the Figure 6
%       visualisation to the current MATLAB figure.
%
%   NOTES
%       The function requires PLOT_PCA_3D_TRANSITIONS to generate the PCA
%       representation.
%
%   EXAMPLE
%       plot_example_Figure6(session)
%

load(session,'Data')

subplot(2,3,1)

plot_PCA_3d_transitions(Data)
view(-11,-50)
xlabel('PC 1')
ylabel('PC 2')
zlabel('PC 3')

p10_results=Data.p10_results;

%% Amplitude 
subplot(2,3,2)
plot(p10_results.xtime,p10_results.p10,'k')
hold on
box off
plot(p10_results.xtimeb(1:p10_results.Ncycles),p10_results.AmpGan,'Color',[0.2 1 0.9],'LineWidth',2)
plot(p10_results.xtimeb(1:p10_results.Ncycles),p10_results.tilt,'Color',[0.9,0.3,0.2],'LineWidth',2)
ylabel('Firing rate [Hz]')
legend('P 10 Firing rate','Amplitude','Tilt')
title(['Corr Amplitude ganglion, P10 = ' num2str(p10_results.corr_amplitude_p10,'%.2f')])


%% Period 

subplot(2,3,5)
plot(p10_results.tp10,p10_results.Cycle_P10,'k')
hold on
plot(p10_results.xtimeb(1:p10_results.Ncycles),p10_results.cycleGan,'.-','Color',[0.5 0.5 0.5])
xlabel('Time from stimulus [s]')
ylabel('Rotation period')
legend('P 10','Ganglion')
box off
title(['corr = ' num2str(p10_results.corr_period_p10,'%.2f'),', MAE = ' num2str(p10_results.mean_per_p10,'%.2f')])


end

function plot_example_Figure7(session)
%PLOT_EXAMPLE_FIGURE7 Generate the example plots shown in Figure 7.
%
%   PLOT_EXAMPLE_FIGURE7(SESSION) loads the data stored in SESSION and
%   generates the trajectory, phase, and phase-difference plots used to
%   illustrate the analysis in Figure 7.
%
%   The figure combines the jPC trajectory coloured by dynamical epoch,
%   the distribution of the mean tilt phase, and trajectories coloured by
%   both tilt and p10 firing rate. The final panel shows the phase
%   difference across successive cycles.
%
%   INPUTS
%       session - Path to a MATLAB data file containing the Data structure.
%                 The structure must include the fields required by the
%                 plotting and analysis functions used below.
%
%   OUTPUTS
%       This function does not return any variables. It creates the Figure 7
%       visualisation in the current MATLAB figure.
%
%   NOTES
%       The function requires the auxiliary function
%       PLOT_TRAJECTORIES_P10 and the analysis function AVERAGE_PHASE.
%
%   EXAMPLE
%       plot_example_Figure7(session)
%

load(session,'Data')

jscores= Data.p10_results.jscores;
jscores=jscores(1:numel(Data.group_bin),:);

nbinsp10=10; % number of bins to plot colours tilt in p10
nt=floor(numel(jscores(:,1))*50/1000);
nsegments=numel(Data.startbin)-1;

% plot jpcs trajectory coloured by dynamical epoch
subplot(3,2,1)
ngroups=max(Data.group_bin);
colour_group=plasma(ngroups);
colour_group(end,:)=[255,230,0]./255;

hold on

for igrps=1:ngroups

    plot3(jscores(Data.group_bin==igrps,1),jscores(Data.group_bin==igrps,2),jscores(Data.group_bin==igrps,3),'Color',colour_group(igrps,:))
end
xlabel('jPC 1')
ylabel('jPC 2')
zlabel('jPC 3')

subplot(3,2,2)
hold on
do_plot=1;
phase_tilt = average_phase(nsegments,Data.startbin,Data.p10_results.tiltax,do_plot);

% plot histogram of phases and compute the statistics
axes('Position', [0.82, 0.64, 0.1, 0.1]);
polarhistogram(phase_tilt,20)

subplot(3,2,3)
plot_trajectories_p10([jscores(:,1:2), Data.p10_results.tiltax],nbinsp10,nt,Data.p10_results.tiltax)
xlabel('jPC 1')
ylabel('jPC 2')
title('Tilt')

subplot(3,2,4)
plot_trajectories_p10([jscores(:,1:2), Data.p10_results.tiltax],nbinsp10,nt,Data.p10)
xlabel('jPC 1')
ylabel('jPC 2')
title('p10 FR')

subplot(3,2,5)
hold on
plot(Data.p10_results.phase_diff)
ylim([-50 400])
ylabel('Phase difference [deg]')
xlabel('Cycle number')
box off

end


function plot_trajectories_p10(trajectory,nbinsp10,nt,p10)
%PLOT_TRAJECTORIES_P10 Plot a 3-D trajectory coloured according to p10.
%
%   PLOT_TRAJECTORIES_P10(TRAJECTORY,NBINSP10,NT,P10) plots the trajectory
%   in three dimensions and represents the variation of p10 along the
%   trajectory using a discretised copper colour scale.
%
%   The trajectory is divided into NT segments. Each segment is assigned a
%   colour according to the mean discretised p10 value within that segment,
%   allowing changes in p10 to be visualised spatially along the trajectory.
%   The initial trajectory point is highlighted separately, and the final
%   portion is plotted using the terminal colour of the scale.
%
%   INPUTS
%       trajectory  - N-by-3 array containing the x, y and z coordinates of
%                     the trajectory.
%       nbinsp10    - Number of bins used to discretise p10 for colouring.
%       nt          - Number of trajectory segments.
%       p10         - Vector of p10 values associated with the trajectory.
%
%   OUTPUTS
%       This function does not return any variables. It adds the trajectory
%       plot and colour bar to the current MATLAB figure.
%
%   EXAMPLE
%       plot_trajectories_p10(trajectory,20,10,p10)
%

colours=flipud(copper(nbinsp10+1));
normp10=p10-min(p10);
p10bin=floor(nbinsp10*normp10/max(normp10))+1; % discretise p10 into nbins
segments=round(size(trajectory,1)./nt);

plot3(trajectory(1,1),trajectory(1,2),trajectory(1,3),'o','MarkerFaceColor',colours(p10bin(1),:),'MarkerEdgeColor',colours(p10bin(1),:))
hold on

% plot a little segment with a colour corresponding to p10 intensity

for i=1:nt-1
    idx=(i-1)*segments+1:i*segments+1;
    ic=floor(mean(p10bin(idx)))+1;
    plot3(trajectory(idx,1),trajectory(idx,2),trajectory(idx,3),'Color',colours(ic,:))
end

plot3(trajectory(idx(end)+1:end,1),trajectory(idx(end)+1:end,2),trajectory(idx(end)+1:end,3),'Color',colours(end,:))

colormap(colours)
H=colorbar;
H.Ticks=[0 1];
H.TickLabels={0, num2str(max(p10),'%.2f')};
end
