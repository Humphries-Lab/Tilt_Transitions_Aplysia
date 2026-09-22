function Supp_video_PCs
%SUPP_VIDEO_PCS Reconstruct video frames from the leading PCA components.
%
%   SUPP_VIDEO_PCS loads the pre-computed frame data associated with the
%   specified video, performs principal component analysis, and reconstructs
%   frames using the first two principal components.
%
%   The analysis uses the stored frame data and metadata from the
%   corresponding *_tr.mat file. Plotting during the PCA step is disabled.
%
%   Notes
%   -----
%   The frame rate is explicitly set to 29.97 frames per second. The
%   reconstruction is performed independently for PC 1 and PC 2.
%

VideoName='00081_5.avi';
load(['.\Output_files\' VideoName '_tr.mat'],'p','All_f')
FrameRate = 29.97;%VideoReader(VideoName,'CurrentTime',p.start_t);
do_plot=0;

[coeffs,scores]=PCA_from_frames(All_f,FrameRate,p,do_plot);

meanFrame=mean(All_f);

%% Simulate moving along PC1
nPC=1;
t=linspace(min(scores(:,nPC)),max(scores(:,nPC)),40)';
t=[t;flipud(t)];
inputs=zeros(numel(t),3);
inputs(:,nPC)=t;
Create_video_PCs(coeffs(:,1:3),scores,inputs,meanFrame,p)

%% Simulate moving along PC2
nPC=2;
t=linspace(min(scores(:,nPC)),max(scores(:,nPC)),40)';
t=[t;flipud(t)];
inputs=zeros(numel(t),3);
inputs(:,nPC)=t;
Create_video_PCs(coeffs(:,1:3),scores,inputs,meanFrame,p)

end