function recurrence_time=calculate_time_of_rec(tmp,sig)
nt=size(tmp,1);
recurrence_time=zeros(nt,1);
recurrence_timeb=zeros(nt,1);
    for t=1:nt
        %find the first white square
        idx_in=find(diff(tmp(t,t:end))<0,1,'First'); 
        idx=find(diff(tmp(t,t:end))>0,1,'First');
        %% now backwards
        %imagesc(tmp(t,1:t-1))
        idx_inb=find(diff(fliplr(tmp(t,1:t)))<0,1,'First');
        idxb=find(diff(fliplr(tmp(t,1:t)))>0,1,'First')-idx_inb;
        if ~isempty(idx) && idx>sig(t)
            recurrence_time(t)=idx+idx_in;
        else
            recurrence_time(t)=nan;
        end
        
        if ~isempty(idxb) && idxb>sig(t)
            recurrence_timeb(t)=idxb+idx_inb;
        else
            recurrence_timeb(t)=nan;
        end
        
    end
%     plot(recurrence_time,'g')
%     hold on 
%     plot(recurrence_timeb,'b')
    recurrence_time=nanmean([recurrence_time,recurrence_timeb],2);
end