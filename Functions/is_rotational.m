function [output,Summary,scorestruct]=is_rotational(total_matrix,do_plot)
%% try repeting the proccess for 3 thresholds and take the median
bin=50;
if do_plot
    figure
end
[~,~,~,~,explained2] = pca(total_matrix);
ndim=find(cumsum(explained2)>=80,1,'First');
if mod(ndim,2)
    if ndim==1
        ndim=ndim+3;
    else
        ndim=ndim+1;
    end
end

% if ndim==2
%     ndim=4;
% end
xtime=(1:size(total_matrix,1))*bin;
jPCA_params.params=false;
jPCA_params.numPCs = ndim;  % default anyway, but best to be specific
jPCA_params.suppressBWrosettes = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressHistograms = true;  % these are useful sanity plots, but lets ignore them for now
jPCA_params.suppressText=true;
Data(1).A=total_matrix;
Data(1).times=xtime';
[scorestruct,Summary] = jPCA(Data, xtime, jPCA_params);

% if there is not rotational structure, then divide the recording into 50
% segments
output=sum(Summary.varCaptEachJPC(1:2))>=0.1;
score=scorestruct.proj;
if do_plot
    ax1=subplot(2,2,1);
    plot(xtime,score(:,1))
    hold on
    plot(xtime,score(:,2))
    plot(xtime,score(:,3))
    box off
    xlabel('Time [s]')
    legend('PC 1', 'PC 2','PC 3')
    ylabel('Projection onto PCs')
    title([ 'JPCA = ' num2str(sum(Summary.varCaptEachJPC(1:2))) ' PCA = ' num2str(sum(Summary.varCaptEachPC(1:2)))])
    
   
    ax2=subplot(2,2,2);
    %plot_trajectories_colour(ax2,score(:,1:3),10)
    hold off
    xlabel('PC 1')
    ylabel('PC 2')
    zlabel('PC 3')
    colorbar('Ticks',[0,1],'TickLabels',{'0', num2str(size(score,1)*bin/1000)})
    
    
    subplot(2,2,3)
plot(Summary.varCaptEachJPC,'.-')
hold on 
plot(Summary.varCaptEachPC,'.-')
box off
xlabel('PC Number')
ylabel('Variance Explained')

subplot(2,2,4)
plot(cumsum(Summary.varCaptEachJPC),'.-')
hold on 
plot(cumsum(Summary.varCaptEachPC),'.-')
box off
xlabel('PC Number')
ylabel('Cumulative variance')
end


pause(0.01)


clear recurrence spks
end