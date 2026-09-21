function [max_eig_re,max_eig_imag,midT]=LDS_per_segment(Data,params)
%% aim: fit each segment to an LDS and see how the eigenvalues change
%extrapoints=round((Data.startbin(2:end)+Data.startbin(1:end-1))/2);
%Data.startbin=sort([Data.startbin;extrapoints],'ascend');

segment_length=30*1000/params.bin; % a minute
slidW=0.1*1000/params.bin;
nsegments=floor((size(Data.total_matrix,2)-2*segment_length)/slidW);


[~,sc,] = pca(Data.total_matrix');

% align to the center of the last cycle
sc=sc-mean(sc(end-segment_length:end,:));
ndim=Data.ndim;
tsegment=zeros(nsegments,1);
max_eig_re=nan(nsegments,1);
max_eig_imag=nan(nsegments,1);
midT=nan(nsegments,1);
r2=nan(nsegments,1);
do_plot=0;

if do_plot
figure
end

t1_bin=-slidW+1;


for nseg=1:nsegments-1
    t1_bin=t1_bin+slidW;
    t2_bin=t1_bin+segment_length;

   Y=sc(t1_bin:t2_bin,1:ndim);
   
   [EigsA,r2(nseg),r1]=LDS(Y);
   midT(nseg)=((t1_bin+t2_bin)/2)*params.bin/1000;
%% only save values if the model is good enough
if r2(nseg)>=0.5
    max_eig_re(nseg)=real(max(EigsA));
    max_eig_imag(nseg)=abs(imag(max(EigsA)));
end


    tsegment(nseg)=((t2_bin-t1_bin)/2+t1_bin)*params.bin/1000;
    %orbit_amplitude=exp(max_eig_re*1000/params.bin) * 100 - 100;
%     orbit_amplitude2=exp(max_eig_re2*1000/params.bin) * 100 - 100;
%     orbit_amplitude3=exp(max_eig_re3*1000/params.bin) * 100 - 100;
    if do_plot
    subplot(2,3,1)
    plot(Y(:,1),'k')
    hold on 
    plot(Y(:,2),'r')
    plot(Y(:,3),'b')
    plot(r1(:,1),'.-k')
    plot(r1(:,2),'.-r')
    plot(r1(:,3),'.-b')
    hold off
    
    subplot(2,3,4)
    plot3(Y(:,1),Y(:,2),Y(:,3),'k')
    hold on
    plot3(r1(:,1),r1(:,2),r1(:,3),'r')
    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')
    end

end

if do_plot
subplot(2,3,2)
    plot(tsegment,max_eig_re)
    xlabel('Time [s]')
    ylabel('Max real eig')
    box off
    xlim([0 Data.startbin(end)*params.bin/1000])
    plot(midT,movmedian(max_eig_re,10,'omitnan'),'k')
    
    subplot(2,3,3)
    plot(tsegment,r2)
    xlabel('Time [s]')
    ylabel('R2')
    box off
    xlim([0 Data.startbin(end)*params.bin/1000])
    
    subplot(2,3,5)
   
    plot(tsegment,(2*pi./max_eig_imag)*params.bin/1000,'o-')
    xlabel('Time [s]')
    ylabel('Period')
    box off
    
    hold on 
    %plot(tsegment,diff(Data.startbin)*2*params.bin/1000,'k')
    xlim([0 Data.startbin(end)*params.bin/1000])
    
    
    subplot(2,3,6)
    %plot(tsegment,movmean(orbit_amplitude,5,'omitnan'))
    hold on
  %   plot(tsegment,orbit_amplitude,'o-')
%   plot(tsegment,movmean(orbit_amplitude3,5))
    xlabel('Time [s]')
    ylabel('Amplitude')
    legend('All','im only','re only')
    box off
    plot([0 Data.startbin(end)*params.bin/1000],[0 0])
    xlim([0 Data.startbin(end)*params.bin/1000])
    keyboard

end

end