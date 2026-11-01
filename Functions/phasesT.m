function y_deg=phasesT(p10,tiltax,startbin)
% computes the difference in phase between two oscilations (p10 and tiltax)
% for each cycle defined in startbin
nsegments=numel(startbin)-1;
Nt=numel(p10);
y_deg=nan(nsegments,1);

% for each cycle compute phases and differences
for s=1:nsegments
    t1_bin=startbin(s);
    t2_bin=startbin(s+1);
    if t2_bin>Nt
        continue
    end
    t2_bin=startbin(s+1)-1;
    % compute phases
    phase_tilt=phase(tiltax(t1_bin:t2_bin)-mean(tiltax(t1_bin:t2_bin)),20,0); % 20 samples per second using 50 ms bins
    phase_p10=phase(p10(t1_bin:t2_bin)-mean(p10(t1_bin:t2_bin)),20,0); % 20 samples per second using 50 ms bins

    % compute difference
    y_deg(s)=atan2(sin(phase_tilt-phase_p10),cos(phase_tilt-phase_p10))*180/pi;


    % choose between equivalent phases to minimise noise within trials
    ydeg_tmp=[y_deg(s)+360 y_deg(s) y_deg(s)-360];
    if s>1
        [~,imin]=min(abs(mean(y_deg(1:(s-1)),'omitnan')-ydeg_tmp));
    else
        [~,imin]=min(abs(ydeg_tmp));
    end
    y_deg(s)= ydeg_tmp(imin);

    if y_deg(s)<0
        y_deg(s)=y_deg(s)+360;
    end

end

end