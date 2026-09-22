function [coeffs,scores,PCarch,PCwidth,behaviour,nPCparams,mean_arch,explained,diff_freq]=PCA_from_frames(All_f,FrameRate,p,do_plot)

% mean filter first
All_f=movmean(All_f,15);

behaviour=[p.animal_shape.width,p.animal_shape.arching,p.animal_shape.top,p.animal_shape.height,p.animal_shape.bottom];

%behaviour=movmedian(behaviour,10);
%nPC=2; % number of eigenvectors to plot

load(['.\Output_files\' p.VideoName '_tr.mat'],'coeffs','scores','explained')

if exist('explained','var')==0
    [coeffs,scores,~,~,explained]=pca(All_f);
    % save PCs
    coeffs=coeffs(:,1:10);
    scores=scores(:,1:10);

    %save(['..\Output_files\' p.VideoName '_tr.mat'],'coeffs','scores','explained','-append')

end



xtime=p.start_t+(1:size(All_f,1))/FrameRate;

%% Test correlation between PC 1-4 and behavioural measurements
ndim=5;

%width
corr_width=corr(scores(:,1:ndim),behaviour(:,1));
[~,idxwidth]=max(abs(corr_width));
PCwidth=zscore(scores(:,idxwidth)*sign(corr_width(idxwidth)));

%arch
corr_arch=corr(scores(:,1:ndim),behaviour(:,2));
[~,idxarch]=max(abs(corr_arch));
PCarch=zscore(scores(:,idxarch)*sign(corr_arch(idxarch)));
nPCparams=[idxarch,idxwidth];


mean_arch=mean(behaviour(:,2));
behaviour=zscore(behaviour);


%% compare frequency of manual curation with frequency of PCA
freq_length=max_freq(behaviour(:,1),FrameRate);
freq_PC(1)=max_freq(PCwidth,FrameRate);


%diff_freq=1./freq_length-1./freq_PC;
diff_freq=[freq_length median(freq_PC)];
if do_plot
   
    %% Trajectory coloured by time
    subplot(4,4,4)
    hold on
    plot_traj_time(scores)
    box off
    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')

    %% display results
    disp('----------------------')
    disp(['Total dimensions = ' num2str(size(All_f,2))])
    disp(['First 2 dims correspond to % of total dims = ' num2str(100*2./size(All_f,2))])
    disp(['First 2 dim explain % of total var = ' num2str(explained(1))  ' ' num2str(explained(2))])
    disp(['Number of dim explain 80% = ' num2str(find(cumsum(explained)>=80,1,'First'))])
    disp('----------------------')

 
    %% scores over time
    subplot(4,4,6);
    plot(xtime,scores(:,1),'r')
    hold on
    plot(xtime,scores(:,2),'b')
    plot(xtime,scores(:,3),'g')

    xlim([xtime(1) xtime(end)])
    ylim([min(scores(:)) max(scores(:))])
    xlabel('Time [s]')
    box off
    
    legend('PC1','PC2','PC3','cycles')
    

    
    %% PC 1 - Length
    subplot(4,4,9)
    plot(xtime,behaviour(:,1),'k')
    hold on
    plot(xtime,PCwidth,'r')
    text(xtime(10),0,['corr = ' num2str(abs(corr_width(idxwidth)))])
    box off
    %title([' Behaviour = ' num2str(freq_length) '  PC = ' num2str(median(freq_PC))])

    %% PC 2 - Arching
    subplot(4,4,13)
    plot(xtime,behaviour(:,2),'k')
    hold on
    plot(xtime,PCarch,'b')
    box off
    text(xtime(10),0,['corr = ' num2str(abs(corr_arch(idxarch)))])
    xlabel('Time [s]')

  
 

    %% eigenvectors

    % for iPC=1:nPC
    %     PCs=reshape(coeffs(:,iPC),p.HB,p.WB);
    %     ax=subplot(4,4,6+iPC);
    %     imagesc(PCs)
    %     title(['Eigenvector = ' num2str(iPC)])
    %     box off
    %     colormap(ax,'gray')
    %     clim([min(coeffs(:,1:nPC),[],'all') max(coeffs(:,1:nPC),[],'all')])
    %     colorbar
    % end

end



end

function plot_traj_time(scores)
Ncolours=100;
npoints=size(scores,1);
segmentT=round(npoints./Ncolours);
colour_time=parula(Ncolours);



hold on
plot3(scores(1,1),scores(1,2),scores(1,3),'o','Color',colour_time(1,:),'MarkerFaceColor',colour_time(1,:))

for t=1:Ncolours
    idx=segmentT*(t-1)+1:t*segmentT+1;
    if sum(idx>npoints)==0
        plot3(scores(idx,1),scores(idx,2),scores(idx,3),'Color',colour_time(t,:))
    else
        plot3(scores(idx(1):end,1),scores(idx(1):end,2),scores(idx(1):end,3),'Color',colour_time(t,:),'LineWidth',2)
    end

end
end

function maxf=max_freq(x,Fs)
% impose they cannot be longer than a minute
minFreq=1/40; % the maximum period is 60 seconds

x=x-mean(x);
y = fft(x);
z = fftshift(y);
ly = length(y);
f = (-ly/2:ly/2-1)*Fs/ly;
minfidx=find(f>=minFreq,1,'first');
%maxfidx=find(f<=minFreq,1,'last')
[~,i]=max(abs(z(minfidx:end)));

maxf=abs(f(i+minfidx-1));
end