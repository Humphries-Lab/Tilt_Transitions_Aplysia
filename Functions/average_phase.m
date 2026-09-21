function [phase_tilt,tilt_cycles,tilt_cyclesmin] = average_phase(nsegments,startbin,tiltax,do_plot)
tilt_cycles=nan(nsegments,1);
tilt_cyclesmin=nan(nsegments,1);
phase_tilt = nan(nsegments,1);

norm_time = linspace(0,1,20);
tilt_norm = nan(20,nsegments);

for s=1:nsegments
    t1_bin=startbin(s);
    t2_bin=startbin(s+1)-1;
    Nel=t2_bin-t1_bin+1;

    % plot the tilt in each cycle 
    % to perform a fair comparison across cycles we need to scale them in
    % time

    time_norm = linspace(0,1,Nel);

    tilt_norm(:,s)  = interp1(time_norm',zscore(tiltax(t1_bin:t2_bin)),norm_time);

    phase_tilt(s)=phase(tiltax(t1_bin:t2_bin)-mean(tiltax(t1_bin:t2_bin)),20,0); % 20 samples per second using 50 ms bins

    if do_plot
        plot(time_norm,zscore(tiltax(t1_bin:t2_bin)),'Color',[0.5 0.5 0.5])
    end
    tilt_cycles(s)=max(tiltax(t1_bin:t2_bin));
    tilt_cyclesmin(s)=max(-tiltax(t1_bin:t2_bin));
end

if do_plot
% mean zscore tilt within a cycle
errorbar(norm_time,mean(tilt_norm,2,'omitnan'),std(tilt_norm,[],2),'.-k','LineWidth',2)
ylabel('zscore tilt')
xlabel('Normalised time within cycle')

end

end