function y_deg=phasesT(p10,tiltax,startbin)
nsegments=numel(startbin)-1;
Nt=numel(p10);
y_deg=nan(nsegments,1);
for s=1:nsegments
    t1_bin=startbin(s);
    t2_bin=startbin(s+1);
    if t2_bin>Nt
       continue
    end
    %t2_bin=startbin(s+1)-1;

    %[~,itilt]=max(tiltax(t1_bin:t2_bin));
    %[~,ip10]=max(p10(t1_bin:t2_bin));
    %y_rad=pi*(ip10-itilt)./(t2_bin-t1_bin);
    x=zscore(tiltax(t1_bin:t2_bin));
    y=zscore(p10(t1_bin:t2_bin));
    [c,lags] = xcorr(x./norm(x),y./norm(y),startbin(s+1)-startbin(s));
    [~,imax]=max(c);

    
    if corr(x,circshift(y',lags(imax)))>0.3
       
        y_rad=2*pi*lags(imax)./(startbin(s+1)-startbin(s));
    else 
         y_rad=nan;
    end
    
    
   
    %y_rad=acos(dot(tiltax(t1_bin:t2_bin),p10(t1_bin:t2_bin))/(norm(tiltax(t1_bin:t2_bin))*norm(p10(t1_bin:t2_bin))));

   

    y_deg(s)=y_rad*360/(2*pi);

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
        
        if y_deg(s)==0
            disp('')
        end

end

% if mean(y_deg,'omitnan')<0
%     y_deg=y_deg+180;
% end

end