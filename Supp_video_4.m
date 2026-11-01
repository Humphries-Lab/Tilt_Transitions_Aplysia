function Supp_video_4(VideoName)

load(['.\Output_files\' VideoName '_tr.mat'],'p','All_f','coeffs','scores')

Good_fit=Reconstruct_video(coeffs(:,1:2),scores(:,1:3),All_f,p);

disp(['Mean goodness of fit across videos = ' num2str(mean(Good_fit,'omitnan')) ' +- ' num2str(std(Good_fit,'omitnan'))])
end

function Good_fit=Reconstruct_video(coeffs,scores,All_f,p)

meanFrame=mean(All_f);
%% it assumes that number of inputs and number of eigs are the same
% how many vectors are used for the reconstruction
neigen=size(coeffs,2);
ninput=size(scores,1);
reconstruction=nan(ninput,size(meanFrame,2));

for t=1:ninput
    reconstruction(t,:)=round(scores(t,1:neigen)*coeffs'+meanFrame);
end

%total_pixels=p.HB*p.WB;
pixels_animal=sum(All_f,2);

%percent_correct=(total_pixels-sum(abs(All_f-reconstruction),2))/total_pixels;
percent_correct=(pixels_animal-sum(abs(All_f-reconstruction),2))./pixels_animal;

Good_fit=mean(percent_correct);

disp('--------------')
disp(['Goodness of fit (percentage of correct pixels) = ' num2str(Good_fit)])


f1=figure;
f1.Position = [100 100 1450 450];
colormap(flipud(colormap('gray')))
counter=1;
mkdir('..\Output_files\frames\video_rec')

for t=1:10:ninput
    im0=reshape(All_f(t,:)',p.HB,p.WB);
    im=reshape(reconstruction(t,:)',p.HB,p.WB);

    %%  plot tracking
    subplot(neigen,3,(1:neigen)*3-2);
    imagesc(im0)
    yticks([])
    xticks([])
    clim([0 1])
    axis off
    title(['Tracking (t = ' num2str(t/29.7,'%.2f') ' s)'])

    ax2=subplot(neigen,3,(1:neigen)*3-1);
    hold on

    plot3(scores(1:t,1),scores(1:t,2),scores(1:t,3),'Color',[0.5 0.5 0.5],'Linewidth',2)
    plot3(scores(t,1),scores(t,2),scores(t,3),'.','Color',[0.9 0.1 0.1],'MarkerSize',24)

    % axes
    plot3([min(scores(:,1)) max(scores(:,1))],[0 0],[0 0],'Color',[0.5 0.5 0.5]*0,'Linewidth',2)
    plot3([0 0],[min(scores(:,2)) max(scores(:,2))],[0 0],'Color',[0.5 0.5 0.5]*0,'Linewidth',2)
    plot3([0 0],[0 0],[min(scores(:,3)) max(scores(:,3))],'Color',[0.5 0.5 0.5]*0,'Linewidth',2)
    text(min(scores(:,1)),0,5,'PC 1','FontSize',14,'Color',[0.5 0.5 0.5]*0)
    text(8,min(scores(:,2)),5,'PC 2','FontSize',14,'Color',[0.5 0.5 0.5]*0)
    text(-5,0,max(scores(:,3))+2,'PC 3','FontSize',14,'Color',[0.5 0.5 0.5]*0)
    axis off
    view(-192.9816,12)

    subplot(neigen,3,(1:neigen)*3)
    imagesc(im)
    yticks([])
    xticks([])
    clim([0 1])
    title('Low-D reconstruction')


    title(['Percentage of correct pixels = ' num2str(percent_correct(t),'%.2f')])
    axis off
    %print(['..\Output_files\frames\video_rec\TR_im' num2str(counter)],'-dpng','-r0')
    pause(0.1)
    cla(ax2)
    counter=counter+1;

    % example for figure
    % if t==2731
    %     pause
    % end

end
end