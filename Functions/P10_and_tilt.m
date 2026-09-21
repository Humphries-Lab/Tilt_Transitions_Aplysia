function [phase_diff,R_tilt,circular_std,tiltax]=P10_and_tilt(jscores,group_bin,p10,tilt,startbin)
%P10_AND_TILT Estimate the neural tilt axis and its phase relationship with P10.
%
%   [PHASE_DIFF,R_TILT,CIRCULAR_STD,TILTAX] =
%   P10_AND_TILT(JSCORES,GROUP_BIN,P10,TILT,STARTBIN) estimates the neural
%   trajectory axis associated with tilt, quantifies its correspondence
%   with the measured tilt signal, and calculates the phase difference
%   between the P10 signal and the resulting neural trajectory.
%
%   The jPC scores are first restricted to the samples represented by
%   GROUP_BIN. The third jPC is then used as the initial estimate of the
%   tilt axis. The trajectory is divided into cycles using STARTBIN, and
%   the mean phase of the tilt axis is calculated for each cycle.
%
%   The consistency of the tilt-axis phase across cycles is quantified
%   using circular standard deviation. The estimated neural tilt is then
%   compared with the measured tilt for both possible axis orientations.
%   The orientation giving the larger absolute correlation is retained,
%   with the tilt axis inverted when necessary.
%
%   Finally, the phase difference between P10 and the selected tilt axis
%   is calculated for each cycle. Both possible orientations of the tilt
%   axis are considered, and the orientation producing the smaller mean
%   phase difference is retained.
%
%   INPUTS
%       jscores   - Matrix of jPC scores. The first three columns contain
%                   the jPC coordinates used to describe the neural
%                   trajectory.
%
%       group_bin - Vector assigning each sample to a dynamical group.
%                   Its length determines the portion of JSCORES and P10
%                   used in the analysis.
%
%       p10       - P10 firing-rate signal associated with the trajectory.
%
%       tilt      - Measured tilt signal used to identify the orientation
%                   of the neural tilt axis and assess its correlation.
%
%       startbin  - Vector containing the boundaries of the cycles used
%                   for phase estimation. Consecutive elements define the
%                   cycle intervals passed to AVERAGE_PHASE and PHASEST.
%
%   OUTPUTS
%       phase_diff    - Phase difference between P10 and the selected tilt
%                       axis for each cycle, in degrees.
%
%       R_tilt       - Correlation coefficient between the measured tilt
%                      and the cycle-wise phase of the selected neural
%                      tilt axis.
%
%       circular_std - Circular standard deviation of the cycle-wise tilt
%                      phase, expressed in degrees.
%
%       tiltax       - Neural tilt axis used for the final phase-difference
%                      calculation. This corresponds to the third jPC,
%                      with its sign adjusted when required.
%
%   NOTES
%       The third jPC is used as the initial tilt-axis estimate. The sign
%       of a principal component is arbitrary, so both orientations are
%       explicitly considered when comparing the neural axis with the
%       measured tilt and when calculating the P10 phase difference.
%
%       The function requires the auxiliary functions AVERAGE_PHASE and
%       PHASEST.
%
%   EXAMPLE
%       [phase_diff,R_tilt,circular_std,tiltax] = ...
%           P10_and_tilt(jscores,group_bin,p10,tilt,startbin)
%

jscores=jscores(1:numel(group_bin),:);
p10=p10(1:numel(group_bin));
nsegments=numel(startbin)-1;


% defining the tilt axis as jPC3
tiltax=jscores(:,3);


%% Testing that the tilt axis has a consistent phase
do_plot=0;
[phase_tilt,tilt_cycles,tilt_cyclesmin] = average_phase(nsegments,startbin,tiltax,do_plot);


% using wikipedia notation https://en.wikipedia.org/wiki/Directional_statistics#Standard_deviation
C = mean(cos(phase_tilt));
S = mean(sin(phase_tilt));
R = sqrt(S.^2+C.^2);
circular_std = sqrt(-2*log(R))*180/pi;

%% Correlation between tilt and jPC3 estimation
R_tilt=corr(tilt_cycles,tilt');
R_tiltmin=corr(tilt_cyclesmin,tilt');

[R_tilt,imax]=max(abs([R_tilt R_tiltmin]));


% because tilt axis sign is arbitrary, we try both signs to determine
% which one is the correct orientation to the phase of p10. 

if imax==2
    tiltax=-tiltax;
end


phase_diff=phasesT(p10,tiltax,startbin);

phase_diff2=phasesT(p10,-tiltax,startbin);

if mean(phase_diff2,'omitnan')<mean(phase_diff,'omitnan')
    phase_diff=phase_diff2;
end

end
