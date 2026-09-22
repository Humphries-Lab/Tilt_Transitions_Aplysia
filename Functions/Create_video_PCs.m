function Create_video_PCs(coeffs,scores,inputs,meanFrame,p)
%CREATE_VIDEO_PCS Visualise PCA reconstruction of image frames.
%
%   CREATE_VIDEO_PCS(coeffs,scores,inputs,meanFrame,p,id) reconstructs each
%   frame from the supplied principal-component representation and
%   interactively displays the reconstruction alongside the corresponding
%   PCA trajectory and the temporal evolution of the PC coefficients.
%
%   Inputs
%   ------
%   coeffs    : PCA coefficient matrix. Each column represents one
%               principal component used for reconstruction.
%   scores    : PCA scores describing the trajectory of the frames in
%               principal-component space.
%   inputs    : PC scores used to reconstruct each frame. Rows correspond
%               to successive frames.
%   meanFrame : Mean image vector added to each PCA reconstruction.
%   p         : Structure containing the frame dimensions, with fields
%               p.HB and p.WB specifying the image height and width.
%   id        : Identifier used to name the output frame directory.
%
%   Description
%   -----------
%   The function reconstructs each frame from the selected principal
%   components and displays the reconstruction together with two views of
%   the PCA representation:
%
%   - the temporal evolution of the PC coefficients;
%   - the trajectory through the first three principal components;
%   - the reconstructed image at the current time point.
%
%   The visualisation is updated sequentially for each input frame,
%   allowing the reconstruction and its position in PCA space to be
%   followed over time.
%
%   Notes
%   -----
%   The function assumes that the number of rows in inputs corresponds to
%   the number of frames and that the number of columns in inputs matches
%   the number of principal components in coeffs.


f1=figure;
f1.Position = [100 100 1450 450];

% Determine the number of principal components used for reconstruction.
neigen=size(coeffs,2);

% The reconstruction is performed for each input frame using the selected
% principal components and the mean frame.
ninput=size(inputs,1);
colormap(flipud(colormap('gray')))
reconstruction=nan(ninput,size(meanFrame,2));

for t=1:ninput
    reconstruction(t,:)=inputs(t,:)*coeffs'+meanFrame;
end



for t=1:ninput

    %% plot values of the scores used up to frame t
    for i=1:neigen
        subplot(neigen,3,3*i-2)
        plot(inputs(1:t,i),'k')
        box off
        xlim([0 ninput])
        ylabel(['a_' sprintf('%d',i)])
        ylim([min(inputs(:,i))-1 max(inputs(:,i))+1])
    end

    % Show the full PCA trajectory in grey and highlight the portion that
    % has been traversed up to the current frame in black.
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
    
    
    % Reshape the reconstructed vector into its original image dimensions
    % and display the current frame alongside its PCA representation.
    im=reshape(reconstruction(t,:)',p.HB,p.WB);
    subplot(neigen,3,(1:neigen)*3)
    imagesc(round(im))
    yticks([])
    xticks([])
    clim([0 1])
    axis off

    pause(0.1)
    cla(ax2)
    
end

end
