function Reconstruct_gallop_crawl(coeffs,scores,inputs,meanFrame,p,id)
f1=figure;
f1.Position = [100 100 1450 450];
% how many vectors are used for the reconstruction
neigen=size(coeffs,2);
%% it assumes that number of inputs and number of eigs are the same
ninput=size(inputs,1);
colormap(flipud(colormap('gray')))
reconstruction=nan(ninput,size(meanFrame,2));

for t=1:ninput
    reconstruction(t,:)=inputs(t,:)*coeffs'+meanFrame;
end
mini=min(reconstruction(:));
maxi=max(reconstruction(:));
mkdir(['..\Output_files\frames\PC_rec_' num2str(id)])
for t=1:ninput
    for i=1:neigen
        subplot(neigen,3,3*i-2)
        plot(inputs(1:t,i),'k')
        box off
        xlim([0 ninput])
        ylabel(['a_' num2str(i)])
        ylim([min(inputs(:,i))-1 max(inputs(:,i))+1])
    end

    ax2=subplot(neigen,3,(1:neigen)*3-1);
    hold on 
    plot3(scores(:,1),scores(:,2),scores(:,3),'Color',[0.7 0.7 0.7],'Linewidth',2)
    plot3([min(scores(:,1)) max(scores(:,1))],[0 0],[0 0],'Color',[0.5 0.5 0.5]*0,'Linewidth',2)
    plot3([0 0],[min(scores(:,2)) max(scores(:,2))],[0 0],'Color',[0.5 0.5 0.5]*0,'Linewidth',2)
    plot3([0 0],[0 0],[min(scores(:,3)) max(scores(:,3))],'Color',[0.5 0.5 0.5]*0,'Linewidth',2)
    plot3(inputs(1:t,1),inputs(1:t,2),inputs(1:t,3),'-k')
    plot3(inputs(t,1),inputs(t,2),inputs(t,3),'.','Color',[0.9 0.1 0.1],'MarkerSize',24)
    text(min(scores(:,1)),0,5,'PC 1','FontSize',14,'Color',[0.5 0.5 0.5]*0)
    text(-1,min(scores(:,2)),-5,'PC 2','FontSize',14,'Color',[0.5 0.5 0.5]*0)
    text(-5,0,max(scores(:,3))+2,'PC 3','FontSize',14,'Color',[0.5 0.5 0.5]*0)
    axis off
    view(16.2272,20.3)
    
    
    im=reshape(reconstruction(t,:)',p.HB,p.WB);
    subplot(neigen,3,(1:neigen)*3)
    imagesc(round(im))
    yticks([])
    xticks([])
    clim([0 1])
    %box off
    if t==1 || t==round(ninput/2)
        pause
    end
    axis off
    %print(['..\Output_files\frames\PC_rec_' num2str(id) '\TR_im' num2str(t)],'-dpng','-r0')
    pause(0.1)
    cla(ax2)
    
end


end